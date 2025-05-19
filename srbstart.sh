#!/bin/bash

# System vorbereiten
sudo apt update && sudo apt upgrade -y
sudo apt install -y build-essential cmake git libuv1-dev libssl-dev libhwloc-dev screen nano wget curl ocl-icd-opencl-dev clinfo unzip automake autoconf libtool pkg-config

# CUDA für GPU-Mining (NVIDIA)
sudo apt install -y nvidia-cuda-toolkit

# ------------------------------------------
# SRBMiner Multi (GPU + CPU Miner) installieren
# ------------------------------------------

wget https://github.com/doktor83/SRBMiner-Multi/releases/download/2.8.7/SRBMiner-Multi-2-8-7-Linux.tar.gz
mkdir -p SRBMiner-Multi && tar -xvzf SRBMiner-Multi-2-8-7-Linux.tar.gz -C SRBMiner-Multi --strip-components=1

# ------------------------------------------
# Startskript für GPU Mining
# ------------------------------------------

cat <<EOF > ~/start_gpu_mining.sh
#!/bin/bash
cd ~/SRBMiner-Multi
./SRBMiner-MULTI --algorithm progpow_zano --gpu --pool eu-de01.miningrigrentals.com:3344 --wallet watis23.351544 --password x
EOF
chmod +x ~/start_gpu_mining.sh

# ------------------------------------------
# Startskript für CPU Mining
# ------------------------------------------

cat <<EOF > ~/start_cpu_mining.sh
#!/bin/bash
cd ~/SRBMiner-Multi
./SRBMiner-MULTI --disable-gpu --algorithm mike --pool eu-de01.miningrigrentals.com:3333 --wallet watis23.352997 --password x
EOF
chmod +x ~/start_cpu_mining.sh

# ------------------------------------------
# Watchdog-Skript für GPU Miner
# ------------------------------------------

cat <<EOF > ~/watchdog_gpu.sh
#!/bin/bash
DISCORD_WEBHOOK="https://discord.com/api/webhooks/1367828277015609365/-MJNVcnMn8v4HeETQxqfAbh5qraJ7Y5oZwDuLL9cwHYdBg-cmUOaN5zkA0Bq4Cu46qAS"
if pgrep -f "SRBMiner-MULTI.*--gpu" > /dev/null
then
  echo "GPU-Miner läuft."
else
  echo "GPU-Miner NICHT gefunden. Starte neu..."
  screen -dmS mining_gpu ~/start_gpu_mining.sh
  curl -H "Content-Type: application/json" -X POST -d '{"content": "⚠️ GPU-Miner wurde automatisch neu gestartet."}' \$DISCORD_WEBHOOK
fi
EOF
chmod +x ~/watchdog_gpu.sh

# Cronjob für Watchdog (alle 5 Minuten)
(crontab -l 2>/dev/null; echo "*/5 * * * * /root/watchdog_gpu.sh") | crontab -

# ------------------------------------------
# Miner starten in Screen
# ------------------------------------------

screen -dmS mining_gpu ~/start_gpu_mining.sh
screen -dmS mining_cpu ~/start_cpu_mining.sh

# Discord-Nachricht über erfolgreichen Start
curl -H "Content-Type: application/json" -X POST -d '{"content": "✅ Mining gestartet: GPU (progpow_zano) + CPU (mike) laufen in Screens."}' https://discord.com/api/webhooks/DEIN_WEBHOOK_LINK

# Benutzerhinweise
echo "✅ GPU-Mining (progpow_zano) läuft in Screen 'mining_gpu'"
echo "✅ CPU-Mining (Yescrypt/mike) läuft in Screen 'mining_cpu'"
echo "👉 Mit 'screen -r mining_gpu' oder 'screen -r mining_cpu' kannst du reinschauen."
echo "✅ Mit CTRL+A und D kannst du die Screens verlassen."
