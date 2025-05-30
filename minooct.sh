#!/bin/bash

# System vorbereiten
sudo apt update && sudo apt upgrade -y
sudo apt install -y build-essential cmake git libuv1-dev libssl-dev libhwloc-dev screen nano wget curl ocl-icd-opencl-dev clinfo unzip automake autoconf libtool pkg-config

# CUDA für GPU-Mining (NVIDIA)
sudo apt install -y nvidia-cuda-toolkit

# ------------------------------------------
# lolMiner (GPU Miner für Octopus) installieren
# ------------------------------------------

cd ~
wget https://github.com/Lolliedieb/lolMiner-releases/releases/download/1.95a/lolMiner_v1.95a_Lin64.tar.gz
mkdir -p lolMiner && tar -xvzf lolMiner_v1.95a_Lin64.tar.gz -C lolMiner --strip-components=1

# Discord Webhook definieren (hier als Platzhalter, bitte ersetzen)
DISCORD_WEBHOOK="https://discord.com/api/webhooks/1367828277015609365/-MJNVcnMn8v4HeETQxqfAbh5qraJ7Y5oZwDuLL9cwHYdBg-cmUOaN5zkA0Bq4Cu46qAS"

# Startskript für GPU Mining (Octopus Algo z. B. Conflux)
cat <<EOF > ~/start_gpu_mining.sh
#!/bin/bash
cd ~/lolMiner
./lolMiner --algo OCTOPUS --pool eu-de02.miningrigrentals.com:3315 --user watis23.351497 --tls 0
EOF
chmod +x ~/start_gpu_mining.sh

# ------------------------------------------
# CPU Miner (cpuminer-opt-rplant) installieren
# ------------------------------------------

cd ~
wget https://github.com/rplant8/cpuminer-opt-rplant/releases/download/5.0.43/cpuminer-opt-linux-5.0.43.tar.gz
mkdir -p cpuminer-opt
tar -xvzf cpuminer-opt-linux-5.0.43.tar.gz -C cpuminer-opt
chmod +x cpuminer-opt/cpuminer-avx2

# Startskript für CPU Mining (yespowerSUGAR Algo)
cat <<EOF > ~/start_cpu_mining.sh
#!/bin/bash
cd ~/cpuminer-opt
./cpuminer-avx2 -a minotaurx -o stratum+tcp://eu-de01.miningrigrentals.com:3333 -u watis23.352843 -p x
EOF
chmod +x ~/start_cpu_mining.sh

# ------------------------------------------
# Watchdog-Skript zur Überwachung von GPU-Miner (lolMiner)
# ------------------------------------------
cat <<EOF > ~/watchdog_gpu.sh
#!/bin/bash
DISCORD_WEBHOOK="https://discord.com/api/webhooks/1367828277015609365/-MJNVcnMn8v4HeETQxqfAbh5qraJ7Y5oZwDuLL9cwHYdBg-cmUOaN5zkA0Bq4Cu46qAS"
if pgrep -f "lolMiner.*--algo OCTOPUS" > /dev/null
then
  echo "GPU-Miner läuft bereits."
else
  echo "GPU-Miner NICHT gefunden. Starte neu..."
  screen -dmS mining_gpu ~/start_gpu_mining.sh
  curl -H "Content-Type: application/json" -X POST -d '{"content": "⚠️ GPU-Miner wurde automatisch neu gestartet."}' \$DISCORD_WEBHOOK
fi
EOF
chmod +x ~/watchdog_gpu.sh

# Cronjob einrichten (alle 5 Minuten Watchdog ausführen)
(crontab -l 2>/dev/null; echo "*/5 * * * * /root/watchdog_gpu.sh") | crontab -

# Start GPU Mining in Screen
screen -dmS mining_gpu ~/start_gpu_mining.sh

# Start CPU Mining in Screen
screen -dmS mining_cpu ~/start_cpu_mining.sh

# Erfolgsnachricht an Discord senden
curl -H "Content-Type: application/json" -X POST -d '{"content": "✅ Vast.ai Mining Setup abgeschlossen. GPU (lolMiner) & CPU (cpuminer-avx2) wurden gestartet."}' $DISCORD_WEBHOOK

# Hinweis für den Benutzer
echo "✅ GPU-Mining (Octopus via lolMiner) läuft in Screen 'mining_gpu'"
echo "✅ CPU-Mining (yespowerSUGAR via cpuminer-opt-rplant) läuft in Screen 'mining_cpu'"
echo "👉 Mit 'screen -r mining_gpu' oder 'screen -r mining_cpu' kannst du reinschauen."
echo "✅ Mit CTRL+A und D kannst du die Screens verlassen."
