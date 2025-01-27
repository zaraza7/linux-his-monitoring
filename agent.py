import os
import time
import requests

# Lektoriaus serverio informacija
SERVER_URL = "http://10.216.1.117:5000/update"
SECRET_TOKEN = "password123"  # Pasirinktas autentifikavimo raktas
HISTORY_FILE = os.path.expanduser("~/.bash_history")  # Bash istorijos failas
CHECK_INTERVAL = 5  # Intervalas tarp patikrinimų (sekundėmis)


def get_last_command(last_position):
    """
    Nuskaito paskutinę komandą iš Bash istorijos, jei ji nauja.
    :param last_position: Paskutinė istorijos failo pozicija.
    :return: (nauja komanda, nauja pozicija) arba (None, paskutinė pozicija).
    """
    current_size = os.path.getsize(HISTORY_FILE)
    if current_size > last_position:
        with open(HISTORY_FILE, "r") as file:
            file.seek(last_position)  # Pereiti į paskutinę žinomą vietą
            new_commands = file.readlines()  # Skaityti naujas eilutes
        last_position = current_size
        if new_commands:
            return new_commands[-1].strip(), last_position
    return None, last_position


def send_command(command):
    """
    Siunčia naują komandą į lektoriaus serverį.
    :param command: Komanda, kuri bus siunčiama.
    """
    data = {"token": SECRET_TOKEN, "commands": [command]}
    try:
        requests.post(SERVER_URL, json=data)
    except requests.RequestException:
        pass  # Jei siuntimas nepavyko, nieko nedarome


def main():
    """
    Pagrindinis agento procesas: stebi istorijos failą ir siunčia naujas komandas į serverį.
    """
    last_position = 0  # Paskutinė skaityta failo pozicija
    while True:
        try:
            # Tikrinti, ar yra naujų komandų
            new_command, last_position = get_last_command(last_position)
            if new_command:  # Jei rasta nauja komanda
                send_command(new_command)
            time.sleep(CHECK_INTERVAL)  # Intervalas tarp patikrinimų
        except KeyboardInterrupt:
            break  # Agentas išjungiamas klaviatūros kombinacija
        except Exception as e:
            time.sleep(CHECK_INTERVAL)  # Jei atsirado klaida, palaukti prieš tęsiant


if __name__ == "__main__":
    main()
