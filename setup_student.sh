#!/bin/bash

# Skriptas studento Linux sistemos paruošimui
# Reikalingos root teisės (naudojant sudo)

echo "Pradedamas studento Linux sistemos paruošimas..."

# 1. Įdiegti reikalingas Python priklausomybes
echo "Įdiegiamos reikalingos priklausomybės..."
sudo apt update
sudo apt install -y python3 python3-pip python3-venv

# 2. Įdiegti requests biblioteką
echo "Įdiegiama Python requests biblioteka..."
sudo pip3 install requests

# 3. Pridėti reikalingus nustatymus į .bashrc
echo "Konfigūruojamas .bashrc failas istorijos įrašymui..."
BASHRC_FILE="/home/student/.bashrc"

# Istorijos nustatymai
HISTORY_CONFIG="
# Nustatymai komandų istorijos įrašymui
export HISTFILE=~/.bash_history
export HISTSIZE=1000
export HISTFILESIZE=2000
export PROMPT_COMMAND=\"history -a; \$PROMPT_COMMAND\"
export HISTCONTROL=ignoredups:ignorespace
shopt -s histappend
"

# Patikrinti, ar nustatymai jau yra .bashrc faile, jei ne - pridėti
if ! grep -q "Nustatymai komandų istorijos įrašymui" "$BASHRC_FILE"; then
    echo "$HISTORY_CONFIG" >> "$BASHRC_FILE"
    echo ".bashrc failas atnaujintas."
else
    echo ".bashrc nustatymai jau yra."
fi

# 4. Pradėti naują bash sesiją arba pritaikyti pakeitimus
echo "Pritaikomi pakeitimai dabartinei sesijai..."
source "$BASHRC_FILE"

# 5. Patvirtinti, kad studento sistema paruošta
echo "Studento sistema sėkmingai paruošta agent.py paleidimui!"
