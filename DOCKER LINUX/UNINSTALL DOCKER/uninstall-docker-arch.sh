#!/bin/bash
set -e

echo "🔥 Arch Linux Docker Complete Uninstall Script"

# Check if pacman exists
if ! command -v pacman &>/dev/null; then
  echo "❌ pacman not found. This script requires Arch-based distributions."
  exit 1
fi

# Stop Docker services
echo "🛑 Stopping Docker services..."
sudo systemctl stop docker.service 2>/dev/null || true
sudo systemctl stop containerd.service 2>/dev/null || true

# Remove all Docker containers, images, volumes, networks
if command -v docker &>/dev/null; then
  echo "🧱 Removing all Docker containers, images, and volumes..."
  sudo docker ps -aq | xargs -r sudo docker stop
  sudo docker system prune -af --volumes || true
fi

# Uninstall Docker packages
echo "📦 Removing Docker packages..."
sudo pacman -Rs --noconfirm docker docker-compose || true

# Remove Snap Docker if exists
sudo snap remove docker 2>/dev/null || true

# Remove Docker directories
echo "🧹 Removing Docker directories and configs..."
sudo rm -rf /var/lib/docker
sudo rm -rf /var/lib/containerd
sudo rm -rf /etc/docker
sudo rm -rf /etc/systemd/system/docker.service.d
sudo rm -rf /var/run/docker.sock
sudo rm -rf /run/docker*
sudo rm -rf ~/.docker

# Remove Docker binaries
echo "🧯 Removing Docker binaries..."
sudo rm -f /usr/bin/docker*
sudo rm -f /usr/bin/dockerd*
sudo rm -f /usr/bin/containerd*
sudo rm -f /usr/bin/ctr*
sudo rm -f /usr/bin/runc
sudo rm -f /usr/local/bin/docker*

# Remove Docker group
echo "👥 Removing Docker group..."
if getent group docker > /dev/null; then
  sudo groupdel docker || true
fi

# Reload systemd daemon
echo "🔄 Reloading systemd daemon..."
sudo systemctl daemon-reexec
sudo systemctl daemon-reload

# Verify removal
echo "🔍 Verifying Docker removal..."
if command -v docker &>/dev/null; then
  echo "❌ Docker still exists — manual cleanup may be required."
else
  echo "✅ Docker completely removed from Arch Linux!"
fi

echo "🧹 Arch Linux Docker cleanup complete!"
