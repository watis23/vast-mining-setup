#!/bin/bash

# ------------------------------------------
# Automatische System-Konfiguration
# ------------------------------------------

export DEBIAN_FRONTEND=noninteractive

# needrestart auf automatisch setzen
sudo sed -i 's/^#\$nrconf{restart} =.*/\$nrconf{restart} = "a";/' /etc/needrestart/needrestart.conf 2>/dev/null || true

# System vorbereiten
sudo apt update && sudo apt upgrade -y
sudo apt install -y build-essential cmake git libuv1-dev libssl-dev libhwloc-dev screen nano wget curl ocl-icd-opencl-dev clinfo unzip automake autoconf libtool pkg-config

# CUDA für GPU-Mining (NVIDIA)
sudo apt install -y nvidia-cuda-toolkit

# ------------------------------------------
# SRBMiner Multi (CPU + GPU Miner) installieren
# ------------------------------------------

cd ~
wget https://github.com/doktor83/SRBMiner-Multi/releases/download/2.8.7/SRBMiner-Multi-2-8-7-Linux.tar.gz
mkdir -p SRBMiner-Multi && tar -xvzf SRBMiner-Multi-2-8-7-Linux.tar.gz -C SRBMiner-Multi --strip-components=1
chmod +x SRBMiner-Multi/SRBMiner-MULTI

# Startskript für GPU Mining (z. B. skydoge auf RPlant)
cat <<EOF > ~/start_gpu_mining.sh
#!/bin/bash
cd ~/SRBMiner-Multi
./SRBMiner-MULTI --algorithm phihash --gpu-id 0 --pool stratum+tcp://stratum-eu.rplant.xyz:7134 --wallet Ph9bwPwgigZhoB2B3oKSUhyV2JsxfrBjuZ --password m=solo
EOF
chmod +x ~/start_gpu_mining.sh

# Startskript für CPU Mining (z. B. randomy/CoreCoin)
cat <<EOF > ~/start_cpu_mining.sh
#!/bin/bash
cd ~/SRBMiner-Multi
./SRBMiner-MULTI --algorithm randomy --disable-gpu --pool corecoin.luckypool.io:3118 --wallet cb36da5291136005e804b7ac8f368f236b2d83b533a5 --password x
EOF
chmod +x ~/start_cpu_mining.sh

# ------------------------------------------
# Watchdog-Skript für GPU Miner
# ------------------------------------------

cat <<EOF > ~/watchdog_gpu.sh
#!/bin/bash
DISCORD_WEBHOOK="https://discord.com/api/webhooks/DEIN_WEBHOOK"
if pgrep -f "SRBMiner-MULTI.*--algorithm skydoge" > /dev/null
then
  echo "✅ GPU-Miner läuft."
else
  echo "⚠️ GPU-Miner NICHT gefunden. Starte neu..."
  screen -dmS mining_gpu ~/start_gpu_mining.sh
  curl -H "Content-Type: application/json" -X POST -d "{\"content\": \"⚠️ GPU-Miner wurde automatisch neu gestartet.\"}" \$DISCORD_WEBHOOK
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
curl -H "Content-Type: application/json" -X POST -d '{"content": "✅ Mining gestartet: GPU (skydoge) + CPU (randomy) laufen in Screens."}' https://discord.com/api/webhooks/DEIN_WEBHOOK

# Benutzerhinweise
echo "✅ GPU-Mining (skydoge) läuft in Screen 'mining_gpu'"
echo "✅ CPU-Mining (randomy/CoreCoin) läuft in Screen 'mining_cpu'"
echo "👉 Mit 'screen -r mining_gpu' oder 'screen -r mining_cpu' kannst du reinschauen."
echo "✅ Mit CTRL+A und D kannst du die Screens verlassen."
