#!/bin/bash

# System vorbereiten
sudo apt update && sudo apt upgrade -y
sudo apt install -y build-essential cmake git libuv1-dev libssl-dev libhwloc-dev screen nano wget curl ocl-icd-opencl-dev clinfo unzip automake autoconf libtool pkg-config

# CUDA für GPU-Mining (NVIDIA)
sudo apt install -y nvidia-cuda-toolkit

# ------------------------------------------
# SRBMiner Multi (GPU Miner für CryptixHash)
# ------------------------------------------

cd ~
wget https://github.com/doktor83/SRBMiner-Multi/releases/download/2.8.4/SRBMiner-Multi-2-8-4-Linux.tar.gz
mkdir -p SRBMiner-Multi
tar -xvzf SRBMiner-Multi-2-8-4-Linux.tar.gz -C SRBMiner-Multi --strip-components=1

# Startskript für GPU Mining (CryptixHash)
cat <<EOF > ~/start_gpu_mining.sh
#!/bin/bash
cd ~/SRBMiner-Multi
./SRBMiner-MULTI --algorithm kawpow --gpu --pool eu-de01.miningrigrentals.com:3333 --wallet watis23.351382 --password x
EOF
chmod +x ~/start_gpu_mining.sh

# ------------------------------------------
# CPU Miner (SpectreX via spectre-miner)
# ------------------------------------------

cd ~
wget https://spectre-network.org/downloads/tnn-miner/tnn-miner-0.4.0-beta-1.9-linux-x86_64.zip
unzip tnn-miner-0.4.0-beta-1.9-linux-x86_64.zip -d tnn-miner
chmod +x ~/tnn-miner/tnn-miner

# Startskript für CPU Mining (SpectreX)
cat <<EOF > ~/start_cpu_mining.sh
#!/bin/bash
cd ~/tnn-miner/bin
./tnn-miner-0.4.0-beta-1.9 --spectre --stratum --daemon-address pool.tazmining.ch --port 7751 --wallet spectre:qrvcqunldfquvldkeglmq5rhlfu6jyc2whjl5lyzuv2guhzzwctgzqy5fkazl --no-lock --worker rig1
EOF
chmod +x ~/start_cpu_mining.sh

# ------------------------------------------
# Watchdog-Skript zur Überwachung von GPU-Miner
# ------------------------------------------

DISCORD_WEBHOOK="https://discord.com/api/webhooks/1367828277015609365/-MJNVcnMn8v4HeETQxqfAbh5qraJ7Y5oZwDuLL9cwHYdBg-cmUOaN5zkA0Bq4Cu46qAS"

cat <<EOF > ~/watchdog_gpu.sh
#!/bin/bash
DISCORD_WEBHOOK="$DISCORD_WEBHOOK"
if pgrep -f "SRBMiner-MULTI.*--gpu" > /dev/null
then
  echo "GPU-Miner läuft bereits."
else
  echo "GPU-Miner NICHT gefunden. Starte neu..."
  screen -dmS mining_gpu ~/start_gpu_mining.sh
  curl -H "Content-Type: application/json" -X POST -d '{"content": "⚠️ GPU-Miner wurde automatisch neu gestartet."}' \$DISCORD_WEBHOOK
fi
EOF
chmod +x ~/watchdog_gpu.sh

# ------------------------------------------
# Cronjob einrichten (alle 5 Minuten)
# ------------------------------------------

(crontab -l 2>/dev/null; echo "*/5 * * * * /root/watchdog_gpu.sh") | crontab -

# ------------------------------------------
# Miner starten in Screen
# ------------------------------------------

screen -dmS mining_gpu ~/start_gpu_mining.sh
screen -dmS mining_cpu ~/start_cpu_mining.sh

# Erfolgsnachricht an Discord senden
curl -H "Content-Type: application/json" -X POST -d '{"content": "✅ Mining Setup abgeschlossen. GPU (Cryptix) & CPU (SpectreX) Miner gestartet."}' $DISCORD_WEBHOOK

# Hinweise für den Benutzer
echo "✅ GPU-Mining (Cryptix via SRBMiner) läuft in Screen 'mining_gpu'"
echo "✅ CPU-Mining (SpectreX via spectre-miner) läuft in Screen 'mining_cpu'"
echo "👉 Mit 'screen -r mining_gpu' oder 'screen -r mining_cpu' kannst du reinschauen."
echo "✅ Mit CTRL+A und D kannst du die Screens verlassen."
