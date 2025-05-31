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
./wildrig-multi --algo phihash --url stratum+tcp://stratum-eu.rplant.xyz:7134 --user Ph9bwPwgigZhoB2B3oKSUhyV2JsxfrBjuZ --pass x >> ~/wildrig.log 2>&1
EOF
chmod +x ~/start_gpu_mining.sh

# XMRig installieren (CPU Miner)
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
DISCORD_WEBHOOK="https://discord.com/api/webhooks/1378271469565644840/-wI6kV3NIb4q_ZMXWPgmualbnj4HPq2i6_yt3uKhH0YxIFQqjvcI4a8zTpcqThl7s_4V"

# Watchdog für GPU-Miner (WildRig)
cat <<EOF > ~/watchdog_gpu.sh
#!/bin/bash
DISCORD_WEBHOOK="$DISCORD_WEBHOOK"
if pgrep -f "wildrig-multi.*--algo skydoge" > /dev/null
then
  echo "✅ GPU-Miner läuft."
else
  echo "⚠️ GPU-Miner NICHT gefunden. Starte neu..."
  screen -dmS mining_gpu ~/start_gpu_mining.sh
  curl -H "Content-Type: application/json" -X POST -d '{"content": "⚠️ WildRig GPU-Miner wurde automatisch neu gestartet."}' \$DISCORD_WEBHOOK
fi
EOF
chmod +x ~/watchdog_gpu.sh

# Watchdog für CPU-Miner (XMRig)
cat <<EOF > ~/watchdog_cpu.sh
#!/bin/bash
DISCORD_WEBHOOK="$DISCORD_WEBHOOK"
if pgrep -f "xmrig.*-a rx/0" > /dev/null
then
  echo "✅ CPU-Miner läuft."
else
  echo "⚠️ CPU-Miner NICHT gefunden. Starte neu..."
  screen -dmS mining_cpu ~/start_cpu_mining.sh
  curl -H "Content-Type: application/json" -X POST -d '{"content": "⚠️ XMRig CPU-Miner wurde automatisch neu gestartet."}' \$DISCORD_WEBHOOK
fi
EOF
chmod +x ~/watchdog_cpu.sh

# Cronjobs für beide Watchdogs einrichten
(crontab -l 2>/dev/null; echo "*/5 * * * * /root/watchdog_gpu.sh") | crontab -
(crontab -l 2>/dev/null; echo "*/5 * * * * /root/watchdog_cpu.sh") | crontab -

# Miner starten in Screen-Sessions
screen -dmS mining_gpu ~/start_gpu_mining.sh
screen -dmS mining_cpu ~/start_cpu_mining.sh

# Discord Nachricht zum Abschluss
curl -H "Content-Type: application/json" -X POST -d '{"content": "✅ WildRig + XMRig Setup abgeschlossen und gestartet."}' $DISCORD_WEBHOOK

# Info-Ausgabe
echo "✅ GPU: WildRig läuft in Screen 'mining_gpu'"
echo "✅ CPU: XMRig läuft in Screen 'mining_cpu'"
echo "👉 Zugriff: screen -r mining_gpu oder screen -r mining_cpu"
