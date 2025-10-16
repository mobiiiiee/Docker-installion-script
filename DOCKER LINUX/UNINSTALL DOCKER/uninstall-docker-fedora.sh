#!/bin/bash
set -e

echo "🔥 Fedora Docker Complete Uninstall Script"

# Check if running on Fedora
if ! grep -qi "fedora" /etc/os-release; then
  echo "❌ This script is for Fedora-based distributions only."
  exit 1
fi

# Stop Docker and containerd
echo "🛑 Stopping Docker services..."
sudo systemctl stop docker.service 2>/dev/null || true
sudo systemctl stop containerd.service 2>/dev/null || true

# Remove all containers, images, volumes, networks
if command -v docker &>/dev/null; then
  echo "🧱 Removing all Docker containers, images, and volumes..."
  sudo docker ps -aq | xargs -r sudo docker stop
  sudo docker system prune -af --volumes || true
fi

# Remove Docker packages
echo "📦 Removing Docker packages..."
sudo dnf remove -y docker docker-client docker-client-latest docker-common docker-latest \
  docker-latest-logrotate docker-logrotate docker-engine docker-ce docker-ce-cli containerd.io \
  docker-compose-plugin docker-buildx-plugin || true

# Remove Snap Docker if exists
sudo snap remove docker 2>/dev/null || true

# Remove Docker directories and configs
echo "🧹 Removing Docker directories..."
sudo rm -rf /var/lib/docker
sudo rm -rf /var/lib/containerd
sudo rm -rf /etc/docker
sudo rm -rf /etc/systemd/system/docker.service.d
sudo rm -rf /var/run/docker.sock
sudo rm -rf /run/docker*
sudo rm -rf ~/.docker

# Remove Docker GPG keys and repo files
echo "🔑 Removing Docker repository files and GPG keys..."
sudo rm -f /etc/yum.repos.d/docker*.repo
sudo rm -f /etc/pki/rpm-gpg/*docker* || true

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
  echo "✅ Docker completely removed from Fedora!"
fi

echo "🧹 Fedora Docker cleanup complete!"
