#!/bin/bash

# System vorbereiten
sudo apt update && sudo apt upgrade -y
sudo apt install -y build-essential cmake git libuv1-dev libssl-dev libhwloc-dev screen nano wget curl ocl-icd-opencl-dev clinfo unzip automake autoconf libtool pkg-config

# CUDA für GPU-Mining (NVIDIA)
sudo apt install -y nvidia-cuda-toolkit

# ------------------------------------------
# Cryptix-Miner (GPU Miner) installieren
# ------------------------------------------

wget https://github.com/cryptix-network/cryptix-miner/releases/download/v0.2.8/cryptix-miner-linux64-v-0-2-8.tar
mkdir -p ~/cryptix-miner
tar -xvf cryptix-miner-linux64-v-0-2-8.tar -C ~/cryptix-miner

# Startskript für GPU Mining (Nexellia)
cat <<EOF > ~/start_gpu_mining.sh
#!/bin/bash
cd ~/cryptix-miner
./cryptix-miner -s --mining-address cryptix:qrq59r8pa48dm4a3vjwqnrq2y5squwu2agkcp9vzypq0ngd9hp24w5exahhxh stratum+tcp://stratum.cryptix-network.org:13094
EOF
chmod +x ~/start_gpu_mining.sh

# ------------------------------------------
# XMRig (CPU Miner) installieren
# ------------------------------------------

git clone https://github.com/xmrig/xmrig.git
cd xmrig
mkdir build && cd build
cmake ..
make -j$(nproc)

# Startskript für CPU Mining (XMRig)
cat <<EOF > ~/start_cpu_mining.sh
#!/bin/bash
cd ~/xmrig/build
./xmrig -o eu-de01.miningrigrentals.com:3333 -u watis23.351350 -p vastworker02 -a rx/0 -k
EOF
chmod +x ~/start_cpu_mining.sh

# Watchdog-Skript zur Überwachung von GPU-Miner
cat <<EOF > ~/watchdog_gpu.sh
#!/bin/bash
DISCORD_WEBHOOK="https://discord.com/api/webhooks/DEIN_WEBHOOK_HIER"
if pgrep -f "cryptix-miner.*cryptixhash" > /dev/nu*
