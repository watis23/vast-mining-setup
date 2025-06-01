#!/bin/bash

# ------------------------------------------
# Automatische System-Konfiguration
# ------------------------------------------

export DEBIAN_FRONTEND=noninteractive

# needrestart auf automatisch setzen (optional, aber sinnvoll)
sudo sed -i 's/^#\$nrconf{restart} =.*/\$nrconf{restart} = "a";/' /etc/needrestart/needrestart.conf 2>/dev/null || true

# System vorbereiten
sudo apt update && sudo apt upgrade -y
sudo apt install -y build-essential cmake git libuv1-dev libssl-dev libhwloc-dev screen nano wget curl ocl-icd-opencl-dev clinfo unzip automake autoconf libtool pkg-config

# CUDA für GPU-Mining (NVIDIA)
sudo apt install -y nvidia-cuda-toolkit

# ------------------------------------------
# WildRig Multi installieren (robust + getestet)
# ------------------------------------------

cd ~
wget -O wildrig.tar.xz https://github.com/andru-kun/wildrig-multi/releases/download/0.43.0/wildrig-multi-linux-0.43.0.tar.xz

# Test: Ist es wirklich eine .tar.xz-Datei?
if ! file wildrig.tar.xz | grep -q 'XZ compressed'; then
    echo "❌ Download fehlgeschlagen oder falsches Format."
    exit 1
fi

# Entpacken (ohne strip-components)
mkdir -p wildrig
tar -xf wildrig.tar.xz -C wildrig

# Umbenennen falls nötig (optional)
chmod +x wildrig/wildrig-multi*

# Prüfen, ob die Binary da ist
if ! ls wildrig/wildrig-multi* &>/dev/null; then
    echo "❌ WildRig-Binary nicht gefunden. Entpacken fehlgeschlagen."
    exit 1
fi

# Startskript für GPU Mining (WildRig)
cat <<EOF > ~/start_gpu_mining.sh
#!/bin/bash
cd ~/wildrig
./wildrig-multi --algo phihash --url stratum+tcp://stratum-eu.rplant.xyz:7134 --user Ph9bwPwgigZhoB2B3oKSUhyV2JsxfrBjuZ --pass x
EOF
chmod +x ~/start_gpu_mining.sh

# ------------------------------------------
# SRBMiner Multi (CPU Miner) installieren
# ------------------------------------------

wget https://github.com/doktor83/SRBMiner-Multi/releases/download/2.8.7/SRBMiner-Multi-2-8-7-Linux.tar.gz
mkdir -p SRBMiner-Multi && tar -xvzf SRBMiner-Multi-2-8-7-Linux.tar.gz -C SRBMiner-Multi --strip-components=1

# Startskript für CPU Mining
cat <<EOF > ~/start_cpu_mining.sh
#!/bin/bash
cd ~/SRBMiner-Multi
./SRBMiner-MULTI --algorithm randomy --disable-gpu --pool corecoin.luckypool.io:3118 --wallet solo:cb36da5291136005e804b7ac8f368f236b2d83b533a5 --password x
EOF
chmod +x ~/start_cpu_mining.sh

# ------------------------------------------
# Watchdog-Skript für GPU Miner
# ------------------------------------------

cat <<EOF > ~/watchdog_gpu.sh
#!/bin/bash
DISCORD_WEBHOOK="https://discord.com/api/webhooks/1367828277015609365/-MJNVcnMn8v4HeETQxqfAbh5qraJ7Y5oZwDuLL9cwHYdBg-cmUOaN5zkA0Bq4Cu46qAS"
if pgrep -f "wildrig-multi-linux.*--algo skydoge" > /dev/null
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
curl -H "Content-Type: application/json" -X POST -d '{"content": "✅ Mining gestartet: GPU (skydoge) + CPU (randomy) laufen in Screens."}' https://discord.com/api/webhooks/DEIN_WEBHOOK_LINK

# Benutzerhinweise
echo "✅ GPU-Mining (skydoge) läuft in Screen 'mining_gpu'"
echo "✅ CPU-Mining (randomy/CoreCoin) läuft in Screen 'mining_cpu'"
echo "👉 Mit 'screen -r mining_gpu' oder 'screen -r mining_cpu' kannst du reinschauen."
echo "✅ Mit CTRL+A und D kannst du die Screens verlassen."
