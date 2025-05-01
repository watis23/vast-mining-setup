#!/bin/bash

# Update & Tools installieren
sudo apt update && sudo apt upgrade -y
sudo apt install -y wget curl nano screen ocl-icd-opencl-dev clinfo build-essential cmake libuv1-dev libssl-dev libhwloc-dev unzip

# OpenCL installieren
sudo apt install -y ocl-icd-libopencl1 opencl-headers clinfo

# CUDA Toolkit nachinstallieren (optional, falls nötig)
sudo apt install -y nvidia-cuda-toolkit

# ------------------------------------------
# lolMiner (GPU Miner) installieren
# ------------------------------------------

# lolMiner herunterladen und entpacken
wget https://github.com/Lolliedieb/lolMiner-releases/releases/download/1.83/lolMiner_v1.83_Lin64.tar.gz
mkdir -p lolminer && tar -xvzf lolMiner_v1.83_Lin64.tar.gz -C lolminer --strip-components=1

# Startskript für GPU Mining (Pyrin) erstellen
cat <<EOF > start_gpu_mining.sh
#!/bin/bash
cd ~/lolminer
./lolMiner --algo PYRINHASH --pool nushypool.com:40008 --user pyrin:qzl5sr3vs4kldqeru9frd7dgna98eh7m6zc3lxv3nhg0lpggf5gp2w0xdcxyx.rig1
EOF

chmod +x start_gpu_mining.sh

# ------------------------------------------
# XMRig (CPU Miner) installieren
# ------------------------------------------

git clone https://github.com/xmrig/xmrig.git
cd xmrig
mkdir build
cd build
cmake ..
make -j\$(nproc)

# Startskript für CPU Mining erstellen
cat <<EOF > start_cpu_mining.sh
#!/bin/bash
cd ~/xmrig/build
./xmrig -o de.qrl.herominers.com:1166 -u Q0105005459440c331f0c37bcd7f557ef1143db54d8fca2945f501cba45b44fbac4bc0817d9bc32 -p vastworker02 -a rx/0 -k
EOF

chmod +x start_cpu_mining.sh

# ------------------------------------------
# Beide Miner automatisch starten in Screens
# ------------------------------------------

# GPU Mining starten in Screen-Session
screen -dmS mining_gpu ./start_gpu_mining.sh

# CPU Mining starten in Screen-Session
screen -dmS mining_cpu ./start_cpu_mining.sh

# Hinweis an den Benutzer
echo "✅ GPU-Mining (Pyrin) läuft jetzt in Screen 'mining_gpu'."
echo "✅ CPU-Mining (QRL) läuft jetzt in Screen 'mining_cpu'."
echo "🔍 Mit 'screen -r mining_gpu' oder 'screen -r mining_cpu' kannst du reinschauen."
echo "✅ Mit CTRL+A und D kannst du jeweils wieder rausgehen."
