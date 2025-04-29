#!/bin/bash

# Update & Tools installieren
sudo apt update && sudo apt upgrade -y
sudo apt install -y wget curl nano screen ocl-icd-opencl-dev clinfo build-essential cmake libuv1-dev libssl-dev libhwloc-dev git

# OpenCL installieren
sudo apt install -y ocl-icd-libopencl1 opencl-headers clinfo

# CUDA Toolkit nachinstallieren (optional)
sudo apt install -y nvidia-cuda-toolkit

# ------------------------------------------
# SRBMiner Multi (GPU Miner) installieren
# ------------------------------------------

# SRBMiner herunterladen
wget https://github.com/doktor83/SRBMiner-Multi/releases/download/2.8.4/SRBMiner-Multi-2-8-4-Linux.tar.gz
tar -xvzf SRBMiner-Multi-2-8-4-Linux.tar.gz

# Startskript für GPU Mining erstellen
cat <<EOF > start_gpu_mining.sh
#!/bin/bash
cd ~/SRBMiner-Multi-2-8-4
./SRBMiner-MULTI --algorithm nxlhash --gpu --pool eu.mining4people.com:3356 --wallet nexellia:qqdqky7ktz63zvrnj0gtpwq7te3x02324a9jasa3xk9wk8v7vuf8q6hw9ka6r --password vastworker01
EOF

chmod +x start_gpu_mining.sh

# ------------------------------------------
# XMRig (CPU Miner) installieren
# ------------------------------------------

# XMRig herunterladen
git clone https://github.com/xmrig/xmrig.git
cd xmrig
mkdir build
cd build
cmake ..
make -j$(nproc)

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

# GPU Mining starten
cd ~/SRBMiner-Multi-2-8-4
screen -dmS mining_gpu ./SRBMiner-MULTI --algorithm nxlhash --gpu --pool eu.mining4people.com:3356 --wallet nexellia:qqdqky7ktz63zvrnj0gtpwq7te3x02324a9jasa3xk9wk8v7vuf8q6hw9ka6r --password vastworker01

# CPU Mining starten
cd ~/xmrig/build
screen -dmS mining_cpu ./xmrig -o de.qrl.herominers.com:1166 -u Q0105005459440c331f0c37bcd7f557ef1143db54d8fca2945f501cba45b44fbac4bc0817d9bc32 -p vastworker02 -a rx/0 -k

# ------------------------------------------
# Health-Check: Läuft Mining sauber?
# ------------------------------------------

echo "🔍 Überprüfe, ob beide Miner laufen..."

# GPU Mining Check
if screen -list | grep -q "mining_gpu"; then
    echo "✅ GPU-Miner läuft (Screen: mining_gpu)."
else
    echo "❌ GPU-Miner läuft NICHT!"
fi

# CPU Mining Check
if screen -list | grep -q "mining_cpu"; then
    echo "✅ CPU-Miner läuft (Screen: mining_cpu)."
else
    echo "❌ CPU-Miner läuft NICHT!"
fi
