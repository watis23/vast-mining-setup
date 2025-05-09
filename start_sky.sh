#!/bin/bash

# Vorbereitung
sudo apt update && sudo apt upgrade -y
sudo apt install -y build-essential git cmake libuv1-dev libssl-dev libhwloc-dev screen wget curl nano ocl-icd-opencl-dev clinfo unzip automake autoconf libtool pkg-config xz-utils nvidia-cuda-toolkit

# WildRig Multi installieren
cd ~
wget https://github.com/andru-kun/wildrig-multi/releases/download/0.43.0/wildrig-multi-linux-0.43.0.tar.xz
mkdir -p wildrig
tar -xvf wildrig-multi-linux-0.43.0.tar.xz -C wildrig --strip-components=1

# Startskript für GPU Mining (WildRig)
cat <<EOF > ~/start_gpu_mining.sh
#!/bin/bash
cd ~/wildrig
./wildrig-multi --algo skydoge --url stratum+tcp://europe.mining-dutch.nl:9977 --user wat_is.worker1 --pass x >> ~/wildrig.log 2>&1
EOF
chmod +x ~/start_gpu_mining.sh

# XMRig installieren
cd ~
git clone https://github.com/xmrig/xmrig.git
cd xmrig && mkdir build && cd build
cmake ..
make -j\$(nproc)

# Startskript für CPU Mining (XMRig)
cat <<EOF > ~/start_cpu_mining.sh
#!/bin/bash
cd ~/xmrig/build
./xmrig -o eu-de01.miningrigrentals.com:3333 -u watis23.351350 -p x -a rx/0 -k >> ~/xmrig.log 2>&1
EOF
chmod +x ~/start_cpu_mining.sh

# Discord Webhook
DISCORD_WEBHOOK="https://discord.com/api/webhooks/1367828277015609365/-MJNVcnMn8v4HeETQxqfAbh5qraJ7Y5oZwDuLL9cwHYdBg-cmUOaN5zkA0Bq4Cu46qAS"

# Watchdog für GPU-Miner (WildRig)
cat <<EOF > ~/watchdog_gpu.sh
#!/bin/bash
DISCORD_WEBHOOK="$DISCORD_WEBHOOK"
if pgrep -f "wildrig-multi.*--algo skydoge" > /dev/null
then
  echo "GPU-Miner läuft bereits."
else
  echo "GPU-Miner NICHT gefunden. Starte neu..."
  screen -dmS mining_gpu ~/start_gpu_mining.sh
  curl -H "Content-Type: application/json" -X POST -d '{"content": "⚠️ WildRig GPU-Miner wurde automatisch neu gestartet."}' \$DISCORD_WEBHOOK
fi
EOF
chmod +x ~/watchdog_gpu.sh

# Cronjob für Watchdog
(crontab -l 2>/dev/null; echo "*/5 * * * * /root/watchdog_gpu.sh") | crontab -

# Miner starten
screen -dmS mining_gpu ~/start_gpu_mining.sh
screen -dmS mining_cpu ~/start_cpu_mining.sh

# Discord Nachricht
curl -H "Content-Type: application/json" -X POST -d '{"content": "✅ WildRig + XMRig Setup abgeschlossen und gestartet."}' $DISCORD_WEBHOOK

# Info
echo "✅ GPU: WildRig läuft in Screen 'mining_gpu'"
echo "✅ CPU: XMRig läuft in Screen 'mining_cpu'"
echo "👉 screen -r mining_gpu / -r mining_cpu"
