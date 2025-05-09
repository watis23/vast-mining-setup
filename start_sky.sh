#!/bin/bash

# ------------------------------------------
# SYSTEMVORBEREITUNG
# ------------------------------------------
sudo apt update && sudo apt upgrade -y
sudo apt install -y build-essential cmake git libuv1-dev libssl-dev libhwloc-dev screen nano wget curl \
ocl-icd-opencl-dev clinfo unzip automake autoconf libtool pkg-config xz-utils nvidia-cuda-toolkit

# ------------------------------------------
# WILDRIG MULTI INSTALLIEREN (GPU-MINER)
# ------------------------------------------
cd ~
wget https://github.com/andru-kun/wildrig-multi/releases/download/0.43.0/wildrig-multi-linux-0.43.0.tar.xz
mkdir -p wildrig
tar -xvf wildrig-multi-linux-0.43.0.tar.xz -C wildrig --strip-components=1

# ------------------------------------------
# STARTSKRIPT FÜR GPU MINING (WildRig)
# ------------------------------------------
cat <<EOF > ~/start_gpu_mining.sh
#!/bin/bash
cd ~/wildrig
./wildrig-multi --algo skydoge --url stratum+tcp://europe.mining-dutch.nl:9977 --user wat_is.worker1 --pass d=0.033
EOF
chmod +x ~/start_gpu_mining.sh

# ------------------------------------------
# XMRIG INSTALLIEREN (CPU-MINER)
# ------------------------------------------
cd ~
git clone https://github.com/xmrig/xmrig.git
cd xmrig
mkdir build && cd build
cmake ..
make -j\$(nproc)

# ------------------------------------------
# STARTSKRIPT FÜR CPU MINING (XMRig)
# ------------------------------------------
cat <<EOF > ~/start_cpu_mining.sh
#!/bin/bash
cd ~/xmrig/build
./xmrig -o eu-de01.miningrigrentals.com:3333 -u watis23.351350 -p vastworker02 -a rx/0 -k
EOF
chmod +x ~/start_cpu_mining.sh

# ------------------------------------------
# DISCORD-WEBHOOK DEFINIEREN
# ------------------------------------------
DISCORD_WEBHOOK="https://discord.com/api/webhooks/1367828277015609365/-MJNVcnMn8v4HeETQxqfAbh5qraJ7Y5oZwDuLL9cwHYdBg-cmUOaN5zkA0Bq4Cu46qAS"

# ------------------------------------------
# WATCHDOG-SKRIPT FÜR GPU-MINER
# ------------------------------------------
cat <<EOF > ~/watchdog_gpu.sh
#!/bin/bash
DISCORD_WEBHOOK="$DISCORD_WEBHOOK"
if pgrep -f "wildrig-multi.*--algo skydoge" > /dev/null
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
# CRONJOB: WATCHDOG ALLE 5 MINUTEN
# ------------------------------------------
(crontab -l 2>/dev/null; echo "*/5 * * * * /root/watchdog_gpu.sh") | crontab -

# ------------------------------------------
# MINING IN SCREEN-SESSION STARTEN
# ------------------------------------------
screen -dmS mining_gpu ~/start_gpu_mining.sh
screen -dmS mining_cpu ~/start_cpu_mining.sh

# ------------------------------------------
# DISCORD-NACHRICHT: SETUP ABGESCHLOSSEN
# ------------------------------------------
curl -H "Content-Type: application/json" -X POST -d '{"content": "✅ Vast.ai Mining Setup abgeschlossen. GPU (WildRig) & CPU (XMRig) wurden gestartet."}' $DISCORD_WEBHOOK

# ------------------------------------------
# HINWEIS FÜR DEN BENUTZER
# ------------------------------------------
echo "✅ GPU-Mining (WildRig) läuft in Screen 'mining_gpu'"
echo "✅ CPU-Mining (XMRig) läuft in Screen 'mining_cpu'"
echo "👉 Mit 'screen -r mining_gpu' oder 'screen -r mining_cpu' kannst du reinschauen."
echo "✅ Mit CTRL+A und D kannst du die Screens verlassen."
