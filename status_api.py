#!/usr/bin/python3

import os
import json
from flask import Flask, jsonify

app = Flask(__name__)

LOG_FILE_PATH = "/home/steam/.local/share/Euro Truck Simulator 2/server.log.txt"

# Store the parsed data in memory
data = {
    "serverRunning": False,
    "serverName": "",
    "sessionID": "",
    "slots": 0,
    "connectedPlayers": [],
    "game": "Euro Truck Simulator 2",
    "game_version": ""
}

# Track the last processed position in the log file
last_position = 0

def parse_log():
    global last_position, data

    try:
        # Open the log file and seek to the last known position
        with open(LOG_FILE_PATH, "r") as log_file:
            log_file.seek(last_position)
            lines = log_file.readlines()

            # Update the last known position
            last_position = log_file.tell()

        for line in lines:
            # Skip the first 15 characters (timestamp)
            line = line[15:]

            # Check if the line contains specific markers before processing
            if "[MP] State: running;" in line:
                data["serverRunning"] = True
            if "[MP] Session name: " in line:
                parts = line.split(": ")
                if len(parts) > 2:
                    data["serverName"] = parts[2].strip()
            if "[MP] Session search id:" in line:
                parts = line.split(":")
                if len(parts) > 3:
                    session_info = parts[3].split("/")
                    if len(session_info) > 0:
                        data["sessionID"] = session_info[0].strip()
            if "[MP] Maximum number of players: " in line:
                try:
                    data["slots"] = int(line.split("players: ")[1].strip())
                except (IndexError, ValueError):
                    pass
            if "Euro Truck Simulator 2 init ver." in line:
                parts = line.split("ver.")
                if len(parts) > 1:
                    version_info = parts[1].split(" ")
                    if len(version_info) > 0:
                        data["game_version"] = version_info[0].strip()
            if "connected" in line and "[MP]" in line and "[Chat]" in line:
                parts = line.split("[Chat]")
                if len(parts) > 1:
                    player_info = parts[1].split("connected")
                    if len(player_info) > 0:
                        player = player_info[0].strip()
                        if player not in data["connectedPlayers"]:
                            data["connectedPlayers"].append(player)
            if "disconnected" in line and "[MP]" in line and "[Chat]" in line:
                parts = line.split("[Chat]")
                if len(parts) > 1:
                    player_info = parts[1].split("disconnected")
                    if len(player_info) > 0:
                        player = player_info[0].strip()
                        if player in data["connectedPlayers"]:
                            data["connectedPlayers"].remove(player)

    except FileNotFoundError:
        pass

    return data

@app.route("/status", methods=["GET"])
def status():
    return jsonify(parse_log())

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
