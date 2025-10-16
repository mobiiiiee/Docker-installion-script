#!/bin/bash
set -e

echo "🔥 Universal Docker Uninstall Script"

# Detect distro
if [ -f /etc/os-release ]; then
  . /etc/os-release
  DISTRO=$ID
else
  echo "❌ Cannot detect Linux distribution."
  exit 1
fi

echo "🧩 Detected distro: $DISTRO"

# Stop Docker services
echo "🛑 Stopping Docker and containerd services..."
sudo systemctl stop docker.service 2>/dev/null || true
sudo systemctl stop docker.socket 2>/dev/null || true
sudo systemctl stop containerd.service 2>/dev/null || true

# Remove all containers, images, volumes, networks
if command -v docker &>/dev/null; then
  echo "🧱 Removing all Docker containers, images, and volumes..."
  sudo docker ps -aq | xargs -r sudo docker stop
  sudo docker system prune -af --volumes || true
fi

# Remove packages depending on distro
case $DISTRO in
  ubuntu|debian)
    echo "📦 Removing Docker packages (APT)..."
    if command -v apt &>/dev/null; then
      sudo apt purge -y docker-ce docker-ce-cli docker-compose docker-compose-plugin \
        containerd.io docker-buildx-plugin docker-ce-rootless-extras docker-scan-plugin || true
      sudo apt autoremove -y
      sudo apt autoclean -y
    fi
    # Remove Docker repos and keys
    sudo rm -f /etc/apt/sources.list.d/docker.list
    sudo rm -f /etc/apt/trusted.gpg.d/docker.gpg
    sudo rm -f /etc/apt/keyrings/docker.gpg
    ;;
  fedora)
    echo "📦 Removing Docker packages (DNF)..."
    if command -v dnf &>/dev/null; then
      sudo dnf remove -y docker docker-client docker-client-latest docker-common docker-latest \
        docker-latest-logrotate docker-logrotate docker-engine docker-ce docker-ce-cli containerd.io \
        docker-compose-plugin docker-buildx-plugin || true
      sudo dnf clean all -y
    fi
    # Remove Docker repo
    sudo rm -f /etc/yum.repos.d/docker*.repo
    ;;
  arch|manjaro|endeavouros)
    echo "📦 Removing Docker packages (Pacman)..."
    if command -v pacman &>/dev/null; then
      sudo pacman -Rs --noconfirm docker docker-compose || true
    fi
    ;;
  *)
    echo "⚠️ Unsupported distro for package removal. Manual removal may be needed."
    ;;
esac

# Remove Snap Docker if exists
sudo snap remove docker 2>/dev/null || true

# Remove Docker directories and configs
echo "🧹 Removing Docker directories and config files..."
sudo rm -rf /var/lib/docker
sudo rm -rf /var/lib/containerd
sudo rm -rf /etc/docker
sudo rm -rf /etc/systemd/system/docker.service.d
sudo rm -rf /var/run/docker.sock
sudo rm -rf /run/docker*
sudo rm -rf ~/.docker

# Remove Docker binaries
echo "🧯 Removing Docker binaries..."
sudo rm -f /usr/local/bin/docker*
sudo rm -f /usr/bin/docker*
sudo rm -f /usr/bin/dockerd*
sudo rm -f /usr/bin/containerd*
sudo rm -f /usr/bin/ctr*
sudo rm -f /usr/bin/runc

# Remove Docker group
echo "👥 Removing Docker group..."
if getent group docker > /dev/null; then
  sudo groupdel docker || true
fi

# Reload systemd
echo "🔄 Reloading systemd daemon..."
sudo systemctl daemon-reexec
sudo systemctl daemon-reload

# Final verification
echo "🔍 Verifying Docker removal..."
if command -v docker &>/dev/null; then
  echo "❌ Docker still exists. Manual cleanup may be required."
else
  echo "✅ Docker completely removed from system!"
fi

echo "🧹 Universal Docker cleanup complete!"
