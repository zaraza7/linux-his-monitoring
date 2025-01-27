#!/bin/bash

# Skriptas mokytojo aplinkos paruošimui (CentOS 9 Stream)

echo "Pradedamas mokytojo Linux sistemos paruošimas..."

# 1. Atlikti sistemos atnaujinimus
echo "Atnaujinami sistemos paketai..."
sudo dnf update -y

# 2. Įdiegti Python3 ir Flask priklausomybes
echo "Įdiegiamos reikalingos priklausomybės..."
sudo dnf install -y python3 python3-pip python3-venv

# 3. Patikrinti, ar Flask jau įdiegtas, jei ne - įdiegti
if ! python3 -m flask --version &> /dev/null; then
    echo "Įdiegiama Flask biblioteka..."
    pip3 install flask
else
    echo "Flask jau įdiegtas."
fi

# 4. Pereiti į projekto katalogą
PROJECT_DIR="$HOME/his_monitor/student_monitoring"
if [ ! -d "$PROJECT_DIR" ]; then
    echo "Klaida: Projekto katalogas $PROJECT_DIR neegzistuoja."
    exit 1
fi

echo "Einama į projekto katalogą $PROJECT_DIR..."
cd "$PROJECT_DIR"

# 5. Patikrinti, ar serverio failas egzistuoja
SERVER_FILE="teacher_server.py"
if [ ! -f "$SERVER_FILE" ]; then
    echo "Klaida: $SERVER_FILE failas nerastas kataloge $PROJECT_DIR."
    exit 1
fi

# 6. Patikrinti Flask serverio paleidimą
echo "Bandomas Flask serverio paleidimas..."
if python3 "$SERVER_FILE" &> /dev/null; then
    echo "Serveris sėkmingai paleistas. Sustabdoma testinė sesija."
    pkill -f "$SERVER_FILE"
else
    echo "Klaida paleidžiant serverį. Patikrinkite $SERVER_FILE failą."
    exit 1
fi

# 7. Siūloma pridėti sisteminės tarnybos konfigūraciją (jei reikia automatinio paleidimo)
echo "Ar norite sukurti sisteminės tarnybos failą, kad serveris būtų automatiškai paleidžiamas? (y/n)"
read -r AUTO_START
if [[ "$AUTO_START" == "y" || "$AUTO_START" == "Y" ]]; then
    SERVICE_FILE="/etc/systemd/system/teacher_server.service"
    echo "Kuriamas tarnybos failas: $SERVICE_FILE..."
    sudo bash -c "cat > $SERVICE_FILE <<EOL
[Unit]
Description=Teacher Flask Server
After=network.target

[Service]
User=$(whoami)
WorkingDirectory=$PROJECT_DIR
ExecStart=/usr/bin/python3 $PROJECT_DIR/$SERVER_FILE
Restart=always

[Install]
WantedBy=multi-user.target
EOL"
    echo "Tarnybos failas sukurtas. Aktyvuojama tarnyba..."
    sudo systemctl daemon-reload
    sudo systemctl enable teacher_server
    sudo systemctl start teacher_server
    echo "Tarnyba aktyvuota ir paleista. Patikrinkite serverio būseną: sudo systemctl status teacher_server"
else
    echo "Tarnybos failas nebuvo sukurtas. Serverį paleiskite rankiniu būdu."
fi

# 8. Diegimo užbaigimas
echo "Mokytojo Linux aplinka sėkmingai paruošta!"
echo "Jei serveris nepaleistas kaip tarnyba, paleiskite jį rankiniu būdu:"
echo "cd $PROJECT_DIR && python3 $SERVER_FILE"

