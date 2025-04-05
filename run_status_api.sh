#!/bin/bash

# Activate the Python virtual environment
source /opt/venv/bin/activate

# Run the status API
echo "[INFO]: Starting status API..."
python3 /api/status_api.py
