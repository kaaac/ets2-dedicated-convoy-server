#!/bin/sh

# Copy default server_packages if they do not exist
cp -n /default_packages/server_packages.sii "${SAVEGAME_LOCATION}"
cp -n /default_packages/server_packages.dat "${SAVEGAME_LOCATION}"

# Set up the Python virtual environment
/bin/bash /api/setup_venv.sh

# Start the status API in the background
/bin/bash /api/run_status_api.sh &

# Generate config and update server
/usr/bin/python3 /ets_server_entrypoint.py

#echo "[INFO]: Starting server..."
exec "$@"