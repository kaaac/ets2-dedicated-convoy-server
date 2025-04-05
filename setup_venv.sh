#!/bin/bash

# Create a virtual environment for Python
if [ ! -d "/opt/venv/bin" ]; then
    echo "[INFO]: Creating Python virtual environment..."
    python3 -m venv /opt/venv
    /opt/venv/bin/pip install --upgrade pip
    /opt/venv/bin/pip install flask
    echo "[INFO]: Virtual environment setup complete."
else
    echo "[INFO]: Virtual environment already exists. Skipping setup."
fi
