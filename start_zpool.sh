#!/bin/bash

# System vorbereiten
sudo apt update && sudo apt upgrade -y
sudo apt install -y build-essential cmake git libuv1-dev libssl-dev libhwloc-dev screen nano wget curl ocl-icd-opencl-dev clinfo unzip automake autoconf libtool pkg-config libcurl4-openssl-dev

# CUDA für GPU-Mining (NVIDIA)
sudo apt install -y nvidia-cuda-toolkit

# ------------------------------------------
# SRBMiner Multi (GPU Miner) installieren
# ------------------------------------------
wget https://github.com/doktor83/SRBMiner-Multi/releases/download/2.8.4/SRBMiner-Multi-2-8-4-Linux.tar.gz
mkdir -p SRBMiner-Multi && tar -xvzf SRBMiner-Multi-2-8-4-Linux.tar.gz -C SRBMiner-Multi --strip-components=1

# Discord Webhook definieren (hier als Platzhalter, bitte ersetzen)
DISCORD_WEBHOOK="https://discord.com/api/webhooks/1367828277015609365/-MJNVcnMn8v4HeETQxqfAbh5qraJ7Y5oZwDuLL9cwHYdBg-cmUOaN5zkA0Bq4Cu46qAS"

# Startskript für GPU Mining (zpool meowpow)
cat <<EOF > ~/start_gpu_mining.sh
#!/bin/bash
cd ~/SRBMiner-Multi
./SRBMiner-MULTI --algorithm meowpow --gpu --pool meowpow.eu.mine.zpool.ca:1327 --wallet D8EvMrnCARBqi2gQrRy7nrZoPkTUBo4K7S --password c=DOGE
EOF
chmod +x ~/start_gpu_mining.sh

# ------------------------------------------
# cpuminer-opt-rplant (CPU Miner) installieren
# ------------------------------------------
cd ~
wget https://github.com/rplant8/cpuminer-opt-rplant/releases/download/5.0.43/cpuminer-opt-linux.tar.gz
mkdir -p cpuminer-opt && tar -xvzf cpuminer-opt-linux.tar.gz -C cpuminer-opt

# Startskript für CPU Mining (zpool qubit)
cat <<EOF > ~/start_cpu_mining.sh
#!/bin/bash
cd ~/cpuminer-opt
./cpuminer-avx2 --algo qubit --url stratum+tcp://qubit.eu.mine.zpool.ca:4733 --user D8EvMrnCARBqi2gQrRy7nrZoPkTUBo4K7S --pass c=DOGE
EOF
chmod +x ~/start_cpu_mining.sh

# ------------------------------------------
# Watchdog für beide Miner
# ------------------------------------------
cat <<EOF > ~/watchdog_all.sh
#!/bin/bash
DISCORD_WEBHOOK="$DISCORD_WEBHOOK"
RESTARTED=0

if ! pgrep -f "SRBMiner-MULTI.*--gpu" > /dev/null; then
  echo "GPU-Miner NICHT gefunden. Starte neu..."
  screen -dmS mining_gpu ~/start_gpu_mining.sh
  curl -H "Content-Type: application/json" -X POST -d '{"content": "⚠️ GPU-Miner wurde automatisch neu gestartet."}' \$DISCORD_WEBHOOK
  RESTARTED=1
fi

if ! pgrep -f "cpuminer-avx2.*--algo qubit" > /dev/null; then
  echo "CPU-Miner NICHT gefunden. Starte neu..."
  screen -dmS mining_cpu ~/start_cpu_mining.sh
  curl -H "Content-Type: application/json" -X POST -d '{"content": "⚠️ CPU-Miner wurde automatisch neu gestartet."}' \$DISCORD_WEBHOOK
  RESTARTED=1
fi

if [ \$RESTARTED -eq 0 ]; then
  echo "✅ Beide Miner laufen ordnungsgemäß."
fi
EOF
chmod +x ~/watchdog_all.sh

# Cronjob einrichten (alle 5 Minuten Watchdog ausführen)
(crontab -l 2>/dev/null; echo "*/5 * * * * /root/watchdog_all.sh") | crontab -

# Start GPU Mining in Screen
screen -dmS mining_gpu ~/start_gpu_mining.sh

# Start CPU Mining in Screen
screen -dmS mining_cpu ~/start_cpu_mining.sh

# Erfolgsnachricht an Discord senden
curl -H "Content-Type: application/json" -X POST -d '{"content": "✅ Vast.ai Mining Setup abgeschlossen. GPU (SRBMiner) & CPU (cpuminer-opt-rplant) wurden gestartet."}' $DISCORD_WEBHOOK

# Hinweis für den Benutzer
echo "✅ GPU-Mining (meowpow) läuft in Screen 'mining_gpu'"
echo "✅ CPU-Mining (qubit via cpuminer-opt-rplant) läuft in Screen 'mining_cpu'"
echo "👉 Mit 'screen -r mining_gpu' oder 'screen -r mining_cpu' kannst du reinschauen."
echo "✅ Mit CTRL+A und D kannst du die Screens verlassen."
