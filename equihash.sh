#!/bin/bash

# System vorbereiten
sudo apt update && sudo apt upgrade -y
sudo apt install -y build-essential cmake git libuv1-dev libssl-dev libhwloc-dev screen nano wget curl ocl-icd-opencl-dev clinfo unzip automake autoconf libtool pkg-config

# CUDA für GPU-Mining (NVIDIA)
sudo apt install -y nvidia-cuda-toolkit

# ------------------------------------------
# MiniZ Miner (für Equihash 192,7)
# ------------------------------------------

wget https://miniz.cc/releases/v2.2c/miniz-linux-v2.2c.tar.gz -O miniz.tar.gz
mkdir -p MiniZ
tar -xvzf miniz.tar.gz -C MiniZ --strip-components=1
chmod +x MiniZ/miniz

# Discord Webhook definieren
DISCORD_WEBHOOK="https://discord.com/api/webhooks/1367828277015609365/-MJNVcnMn8v4HeETQxqfAbh5qraJ7Y5oZwDuLL9cwHYdBg-cmUOaN5zkA0Bq4Cu46qAS"

# Startskript für GPU Mining (MiniZ Equihash 192,7)
cat <<EOF > ~/start_gpu_mining.sh
#!/bin/bash
cd ~/MiniZ
./miniz --url=watis23.352395:x@eu-de01.miningrigrentals.com:3333 --algo=192_7
EOF
chmod +x ~/start_gpu_mining.sh

# ------------------------------------------
# XMRig (CPU Miner) installieren
# ------------------------------------------

git clone https://github.com/xmrig/xmrig.git
cd xmrig
mkdir build && cd build
cmake ..
make -j\$(nproc)
cd ~

# Startskript für CPU Mining (XMRig)
cat <<EOF > ~/start_cpu_mining.sh
#!/bin/bash
cd ~/xmrig/build
./xmrig -o eu-de01.miningrigrentals.com:3333 -u watis23.351350 -p x -a rx/0 -k
EOF
chmod +x ~/start_cpu_mining.sh

# Watchdog-Skript zur Überwachung von GPU-Miner (MiniZ)
cat <<EOF > ~/watchdog_gpu.sh
#!/bin/bash
DISCORD_WEBHOOK="${DISCORD_WEBHOOK}"
if pgrep -f "miniz.*--algo=192_7" > /dev/null
then
  echo "GPU-Miner (MiniZ) läuft bereits."
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
curl -H "Content-Type: application/json" -X POST -d '{"content": "✅ Vast.ai Mining Setup abgeschlossen. GPU (MiniZ Equihash192_7) & CPU (RandomX) Miner wurden gestartet."}' $DISCORD_WEBHOOK

# Hinweis für den Benutzer
echo "✅ GPU-Mining (MiniZ Equihash192_7) läuft in Screen 'mining_gpu'"
echo "✅ CPU-Mining (RandomX via XMRig) läuft in Screen 'mining_cpu'"
echo "👉 Mit 'screen -r mining_gpu' oder 'screen -r mining_cpu' kannst du reinschauen."
echo "✅ Mit CTRL+A und D kannst du die Screens verlassen."
