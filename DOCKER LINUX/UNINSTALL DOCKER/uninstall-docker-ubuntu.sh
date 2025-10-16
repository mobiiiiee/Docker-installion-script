#!/bin/bash
set -e

echo "🔥 Starting complete Docker removal for Ubuntu..."

# Stop Docker services if running
echo "🛑 Stopping Docker services..."
sudo systemctl stop docker || true
sudo systemctl stop docker.socket || true
sudo systemctl stop containerd || true

# Remove all Docker containers, images, volumes, and networks
echo "🧱 Removing all Docker containers, images, and volumes..."
if command -v docker &> /dev/null; then
  sudo docker ps -aq | xargs -r sudo docker stop
  sudo docker system prune -af --volumes || true
fi

# Uninstall Docker packages
echo "📦 Removing Docker packages..."
sudo apt purge -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras docker-compose || true

# Remove Docker from snap (if installed)
sudo snap remove docker 2>/dev/null || true

# Remove Docker directories and data
echo "🧹 Removing Docker data directories..."
sudo rm -rf /var/lib/docker
sudo rm -rf /var/lib/containerd
sudo rm -rf /etc/docker
sudo rm -rf /etc/systemd/system/docker.service.d
sudo rm -rf /var/run/docker.sock
sudo rm -rf /run/docker*
sudo rm -rf ~/.docker

# Remove APT repository and GPG keys
echo "🔑 Removing Docker repositories and GPG keys..."
sudo rm -f /etc/apt/sources.list.d/docker.list
sudo rm -f /etc/apt/trusted.gpg.d/docker.gpg
sudo rm -f /etc/apt/keyrings/docker.gpg

# Remove binaries and symbolic links
echo "🧯 Removing Docker binaries..."
sudo rm -f /usr/local/bin/docker*
sudo rm -f /usr/bin/docker*
sudo rm -f /usr/bin/dockerd*
sudo rm -f /usr/bin/containerd*
sudo rm -f /usr/bin/ctr*
sudo rm -f /usr/bin/runc

# Remove Docker group
echo "👥 Removing Docker group..."
sudo groupdel docker 2>/dev/null || true

# Clean apt cache
echo "🧼 Cleaning apt cache..."
sudo apt autoremove -y
sudo apt autoclean -y

# Reload systemd daemon
echo "🔄 Reloading systemd daemon..."
sudo systemctl daemon-reload

# Final verification
echo "🔍 Verifying Docker removal..."
if command -v docker &> /dev/null; then
  echo "❌ Docker still exists, manual cleanup may be needed."
else
  echo "✅ Docker completely removed from system!"
fi

echo "🧹 Full Docker cleanup complete!"
