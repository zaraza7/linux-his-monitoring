from flask import Flask, request, jsonify, render_template
from flask_socketio import SocketIO
from datetime import datetime, timedelta

app = Flask(__name__)
socketio = SocketIO(app)

# Studentų duomenys
AUTHORIZED_IPS = [f"10.216.1.{i}" for i in range(101, 111)]  # IP adresų diapazonas
student_logs = {}  # Studentų komandų istorija
student_status = {}  # Studentų būklė (aktyvus/inaktyvus)

# Privalomos komandos
REQUIRED_COMMANDS = ["ls", "pwd", "mkdir test_folder", "echo 'hello world'"]
INACTIVITY_LIMIT = 60  # Sekundės, po kiek studentas laikomas inaktyviu


@app.route("/")
def index():
    """Pagrindinis lektoriaus puslapis."""
    # Patikriname, ar studentai yra aktyvūs
    for student_ip, status in student_status.items():
        last_seen = status.get("last_seen", datetime.now())
        if datetime.now() - last_seen > timedelta(seconds=INACTIVITY_LIMIT):
            student_status[student_ip]["active"] = False

    return render_template("index.html", students=student_logs, status=student_status)


@app.route("/update", methods=["POST"])
def update_logs():
    """Gauti naujas komandas iš studentų agentų."""
    data = request.get_json()
    student_ip = request.remote_addr  # Naudojamas IP kaip unikalus ID
    commands = data.get("commands", [])

    if student_ip not in AUTHORIZED_IPS:
        return jsonify({"status": "unauthorized"}), 403

    if student_ip not in student_logs:
        student_logs[student_ip] = []
    if student_ip not in student_status:
        student_status[student_ip] = {"active": True, "last_seen": datetime.now()}

    # Pridedame naujas komandas
    for cmd in commands:
        student_logs[student_ip].append({"command": cmd, "timestamp": datetime.now().isoformat()})

    # Atnaujiname studento būklę
    student_status[student_ip]["active"] = True
    student_status[student_ip]["last_seen"] = datetime.now()

    # Siunčiame atnaujinimus į web aplinką per SocketIO
    socketio.emit("update_logs", {"student_ip": student_ip, "commands": commands})

    return jsonify({"status": "success"}), 200


@app.route("/analyze/<student_ip>", methods=["GET"])
def analyze_student(student_ip):
    """Analizuojame studento progresą."""
    executed_commands = [log["command"].strip() for log in student_logs.get(student_ip, [])]
    return jsonify({cmd: cmd in executed_commands for cmd in REQUIRED_COMMANDS})


@socketio.on("connect")
def on_connect():
    print("Naujas prisijungimas!")


if __name__ == "__main__":
    socketio.run(app, host="0.0.0.0", port=5000)
