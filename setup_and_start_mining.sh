#!/bin/bash

# System aktualisieren und Tools installieren
sudo apt update && sudo apt upgrade -y
sudo apt install wget screen -y

# SRBMiner herunterladen und entpacken
wget https://github.com/doktor83/SRBMiner-Multi/releases/download/2.8.4/SRBMiner-Multi-2-8-4-Linux.tar.gz
tar -xvzf SRBMiner-Multi-2-8-4-Linux.tar.gz
cd SRBMiner-Multi-2-8-4

# Mining-Startskript erstellen
cat <<EOF > start_mining.sh
#!/bin/bash
cd ~/SRBMiner-Multi-2-8-4
./SRBMiner-MULTI \\
--algorithm nxlhash --gpu --pool eu.mining4people.com:3356 --wallet nexellia:qqdqky7ktz63zvrnj0gtpwq7te3x02324a9jasa3xk9wk8v7vuf8q6hw9ka6r --password vastworker01 \\
--algorithm qrl --cpu --pool de.qrl.herominers.com:1166 --wallet Q0105005459440c331f0c37bcd7f557ef1143db54d8fca2945f501cba45b44fbac4bc0817d9bc32 --password vastworker02
EOF

# Startskript ausführbar machen
chmod +x start_mining.sh

# Mining in einer Screen-Session starten
screen -dmS mining ./start_mining.sh

# Infos ausgeben
echo "✅ Mining läuft jetzt in Screen-Session 'mining'."
echo "👉 Mit 'screen -r mining' kannst du reinschauen."
echo "👉 Mit CTRL+A und D kannst du rausgehen."
