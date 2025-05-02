#!/bin/bash

# System vorbereiten
sudo apt update && sudo apt upgrade -y
sudo apt install -y build-essential cmake git libuv1-dev libssl-dev libhwloc-dev screen nano wget curl ocl-icd-opencl-dev clinfo unzip automake autoconf libtool pkg-config mailutils

# CUDA für GPU-Mining (NVIDIA)
sudo apt install -y nvidia-cuda-toolkit

# ------------------------------------------
# SRBMiner Multi (GPU + CPU Miner) installieren
# ------------------------------------------

wget https://github.com/doktor83/SRBMiner-Multi/releases/download/2.8.4/SRBMiner-Multi-2-8-4-Linux.tar.gz
mkdir -p SRBMiner-Multi && tar -xvzf SRBMiner-Multi-2-8-4-Linux.tar.gz -C SRBMiner-Multi --strip-components=1

# Startskript für GPU Mining (Nexellia)
cat <<EOF > ~/start_gpu_mining.sh
#!/bin/bash
cd ~/SRBMiner-Multi
./SRBMiner-MULTI --algorithm nxlhash --gpu --pool eu.mining4people.com:3356 --wallet nexellia:qqdqky7ktz63zvrnj0gtpwq7te3x02324a9jasa3xk9wk8v7vuf8q6hw9ka6r --password vastworker01
EOF
chmod +x ~/start_gpu_mining.sh

# Startskript für CPU Mining (Yescrypt z. B. Yenten, Myriadcoin, etc.)
cat <<EOF > ~/start_cpu_mining.sh
#!/bin/bash
cd ~/SRBMiner-Multi
./SRBMiner-MULTI --algorithm yescrypt --cpu --pool de.qrl.herominers.com:1166 --wallet Q0105005459440c331f0c37bcd7f557ef1143db54d8fca2945f501cba45b44fbac4bc0817d9bc32 --password srbworker01
EOF
chmod +x ~/start_cpu_mining.sh

# Watchdog-Skript zur Überwachung von GPU-Miner
cat <<EOF > ~/watchdog_gpu.sh
#!/bin/bash
if pgrep -f "SRBMiner-MULTI.*--gpu" > /dev/null
then
  echo "GPU-Miner läuft bereits."
else
  echo "GPU-Miner NICHT gefunden. Starte neu..."
  screen -dmS mining_gpu ~/start_gpu_mining.sh
  echo "SRBMiner GPU-Miner wurde automatisch neu gestartet." | mail -s "⚠️ GPU-Miner Watchdog: Neustart durchgeführt" -email-
fi
EOF
chmod +x ~/watchdog_gpu.sh

# Cronjob einrichten (alle 5 Minuten Watchdog ausführen)
(crontab -l 2>/dev/null; echo "*/5 * * * * /root/watchdog_gpu.sh") | crontab -

# Start GPU Mining in Screen
screen -dmS mining_gpu ~/start_gpu_mining.sh

# Start CPU Mining in Screen
screen -dmS mining_cpu ~/start_cpu_mining.sh

# Erfolgs-Statusmail senden
echo "✅ Vast.ai Mining Setup abgeschlossen. GPU & CPU-Miner wurden gestartet." | mail -s "✅ Mining Setup bereit" -EMAIL-

# Hinweis für den Benutzer
echo "✅ GPU-Mining (Nexellia) läuft in Screen 'mining_gpu'"
echo "✅ CPU-Mining (Yescrypt via SRBMiner) läuft in Screen 'mining_cpu'"
echo "👉 Mit 'screen -r mining_gpu' oder 'screen -r mining_cpu' kannst du reinschauen."
echo "✅ Mit CTRL+A und D kannst du die Screens verlassen."
