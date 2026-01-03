#!/bin/bash

# Godot installation script for Codespaces

set -e

echo "Setting up Godot development environment..."

# Install dependencies
sudo apt-get update
sudo apt-get install -y \
    wget \
    unzip \
    libx11-6 \
    libxcursor1 \
    libxinerama1 \
    libgl1-mesa-glx \
    libglu1-mesa \
    libasound2

# Download Godot 4.x headless (for CI/export)
GODOT_VERSION="4.2.1"
wget https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}-stable/Godot_v${GODOT_VERSION}-stable_linux.x86_64.zip
unzip Godot_v${GODOT_VERSION}-stable_linux.x86_64.zip
sudo mv Godot_v${GODOT_VERSION}-stable_linux.x86_64 /usr/local/bin/godot
sudo chmod +x /usr/local/bin/godot
rm Godot_v${GODOT_VERSION}-stable_linux.x86_64.zip

# Download export templates
mkdir -p ~/.local/share/godot/export_templates/${GODOT_VERSION}.stable
wget https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}-stable/Godot_v${GODOT_VERSION}-stable_export_templates.tpz
unzip Godot_v${GODOT_VERSION}-stable_export_templates.tpz -d ~/.local/share/godot/export_templates/${GODOT_VERSION}.stable
rm Godot_v${GODOT_VERSION}-stable_export_templates.tpz

echo "Godot ${GODOT_VERSION} installed successfully!"
echo "You can edit code in Codespaces and pull to desktop Godot for testing."
