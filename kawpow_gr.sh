#!/bin/bash

# System vorbereiten
sudo apt update && sudo apt upgrade -y
sudo apt install -y build-essential cmake git libuv1-dev libssl-dev libhwloc-dev screen nano wget curl ocl-icd-opencl-dev clinfo unzip automake autoconf libtool pkg-config

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
./SRBMiner-MULTI --algorithm kawpow --gpu --pool eu-de01.miningrigrentals.com:3333 --wallet watis23.351382 --password vastworker01
EOF
chmod +x ~/start_gpu_mining.sh

# Startskript für CPU Mining (Yescrypt z. B. Yenten, Myriadcoin, etc.)
cat <<EOF > ~/start_cpu_mining.sh
#!/bin/bash
cd ~/SRBMiner-Multi
./SRBMiner-MULTI --disable-gpu --algorithm ghostrider --pool eu-de02.miningrigrentals.com:3333 --wallet watis23.352480 --password x
EOF
chmod +x ~/start_cpu_mining.sh

# Start GPU Mining in Screen
screen -dmS mining_gpu ~/start_gpu_mining.sh

# Start CPU Mining in Screen
screen -dmS mining_cpu ~/start_cpu_mining.sh

# Hinweis für den Benutzer
echo "✅ GPU-Mining (Nexellia) läuft in Screen 'mining_gpu'"
echo "✅ CPU-Mining (Yescrypt via SRBMiner) läuft in Screen 'mining_cpu'"
echo "👉 Mit 'screen -r mining_gpu' oder 'screen -r mining_cpu' kannst du reinschauen."
echo "✅ Mit CTRL+A und D kannst du die Screens verlassen."
