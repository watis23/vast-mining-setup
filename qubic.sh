#!/bin/bash

# System vorbereiten
sudo apt update && sudo apt upgrade -y
sudo apt install -y build-essential cmake git default-jre libuv1-dev libssl-dev libhwloc-dev screen nano wget curl unzip automake autoconf libtool pkg-config

# CUDA für NVIDIA GPU (falls GPU vorhanden)
sudo apt install -y nvidia-cuda-toolkit

# ------------------------------------------
# GPU-Miner (qubic-lite-miner, CUDA)
# ------------------------------------------

cd ~
git clone https://github.com/jtskxx/qubic-lite-miner.git
cd qubic-lite-miner
chmod +x build_cuda.sh && ./build_cuda.sh

# Startskript für GPU-Miner
cat <<EOF > ~/start_qubic_gpu.sh
#!/bin/bash
cd ~/qubic-lite-miner
./qubicMinerCUDA --pool qubic.jetskypool.xyz:3333 --username BBVBBKUYBKHAJFUIDWDZSRLQGGWBWAAYNPIJGZAULGGJLIIWVKWIYOLCVQFI
EOF
chmod +x ~/start_qubic_gpu.sh

# ------------------------------------------
# CPU-Miner (Jetski Java Miner)
# ------------------------------------------

cd ~
git clone https://github.com/jtskxx/qubic-miner.git
cd qubic-miner

# Startskript für CPU-Miner
cat <<EOF > ~/start_qubic_cpu.sh
#!/bin/bash
cd ~/qubic-miner
java -jar target/qubic-miner.jar --pool qubic.jetskypool.xyz:3333 --username BBVBBKUYBKHAJFUIDWDZSRLQGGWBWAAYNPIJGZAULGGJLIIWVKWIYOLCVQFI
EOF
chmod +x ~/start_qubic_cpu.sh

# ------------------------------------------
# Watchdog für GPU-Miner
# ------------------------------------------

cat <<EOF > ~/watchdog_qubic.sh
#!/bin/bash
DISCORD_WEBHOOK="https://discord.com/api/webhooks/1367828277015609365/-MJNVcnMn8v4HeETQxqfAbh5qraJ7Y5oZwDuLL9cwHYdBg-cmUOaN5zkA0Bq4Cu46qAS"
if pgrep -f "qubicMinerCUDA" > /dev/null
then
  echo "Qubic GPU-Miner läuft."
else
  echo "GPU-Miner NICHT gefunden. Starte neu..."
  screen -dmS qubic_gpu ~/start_qubic_gpu.sh
  curl -H "Content-Type: application/json" -X POST -d '{"content": "⚠️ GPU-Miner neu gestartet."}' \$DISCORD_WEBHOOK
fi
EOF
chmod +x ~/watchdog_qubic.sh

# Cronjob (alle 5 Minuten)
(crontab -l 2>/dev/null; echo "*/5 * * * * /root/watchdog_qubic.sh") | crontab -

# Miner starten
screen -dmS qubic_gpu ~/start_qubic_gpu.sh
screen -dmS qubic_cpu ~/start_qubic_cpu.sh

# Discord-Benachrichtigung
curl -H "Content-Type: application/json" -X POST -d '{"content": "✅ Qubic Mining gestartet: GPU + CPU laufen."}' https://discord.com/api/webhooks/DEIN-WEBHOOK

# Hinweise
echo "✅ GPU-Miner läuft in 'screen -r qubic_gpu'"
echo "✅ CPU-Miner läuft in 'screen -r qubic_cpu'"
echo "👉 Screens mit CTRL+A D verlassen."
