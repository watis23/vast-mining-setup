#!/bin/bash

# System vorbereiten
sudo apt update && sudo apt upgrade -y
sudo apt install -y build-essential cmake git libuv1-dev libssl-dev libhwloc-dev screen nano wget curl ocl-icd-opencl-dev clinfo unzip

# CUDA für GPU-Mining (NVIDIA)
sudo apt install -y nvidia-cuda-toolkit

# XMRig herunterladen und kompilieren (mit CUDA Support)
git clone https://github.com/xmrig/xmrig.git
cd xmrig
mkdir build && cd build
cmake .. -DWITH_CUDA=ON
make -j$(nproc)

# Startskript erstellen für CPU + GPU Mining
cat <<EOF > ~/start_xmrig_full.sh
#!/bin/bash
cd ~/xmrig/build
./xmrig \
  -o eu-01.miningrigrentals.com:3333 \
  -u Pellkopf.317400 \
  -p fullrig01 \
  -a rx/0 \
  --cuda \
  --opencl
EOF

chmod +x ~/start_xmrig_full.sh

# Start in Screen-Session
screen -dmS mining_xmrig_full ~/start_xmrig_full.sh

# Info für Benutzer
echo "✅ XMRig CPU+GPU Mining läuft in 'mining_xmrig_full'"
echo "👉 screen -r mining_xmrig_full"
