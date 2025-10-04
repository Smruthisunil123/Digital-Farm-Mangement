#!/bin/bash

echo "Starting ML Services for Digital Farm Management Portal..."

# Create a virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    echo "Creating Python virtual environment..."
    python3 -m venv venv
fi

# Activate the virtual environment
source venv/bin/activate

# Install dependencies
echo "Installing dependencies from requirements.txt..."
pip install -r requirements.txt

# Run the Flask API
echo "Launching Flask API server..."
export FLASK_APP=src/api.py
flask run --host=0.0.0.0 --port=5001