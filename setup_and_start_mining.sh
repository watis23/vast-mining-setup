#!/bin/bash

# Update & Tools installieren
sudo apt update && sudo apt upgrade -y
sudo apt install -y wget curl nano screen ocl-icd-opencl-dev clinfo

# OpenCL installieren (falls noch nicht vorhanden)
sudo apt install -y ocl-icd-libopencl1 opencl-headers clinfo

# CUDA Libraries nachinstallieren (optional, falls nötig)
sudo apt install -y nvidia-cuda-toolkit

# SRBMiner herunterladen und entpacken
wget https://github.com/doktor83/SRBMiner-Multi/releases/download/2.8.4/SRBMiner-Multi-2-8-4-Linux.tar.gz
tar -xvzf SRBMiner-Multi-2-8-4-Linux.tar.gz
cd SRBMiner-Multi-2-8-4

# Mining-Startskript erstellen
cat <<EOF > start_mining.sh
#!/bin/bash
cd ~/SRBMiner-Multi-2-8-4
./SRBMiner-MULTI \
--algorithm nxlhash --gpu --pool eu.mining4people.com:3356 --wallet nexellia:qqdqky7ktz63zvrnj0gtpwq7te3x02324a9jasa3xk9wk8v7vuf8q6hw9ka6r --password vastworker01
EOF

# Start-Skript ausführbar machen
chmod +x start_mining.sh

# Mining starten in neuer Screen-Session
screen -dmS mining ./start_mining.sh

# Hinweis an den Benutzer
echo "✅ Mining läuft jetzt in der Screen-Session 'mining'."
echo "🔍 Mit 'screen -r mining' kannst du reinschauen."
echo "✅ Mit CTRL+A und D kannst du den Screen verlassen."
