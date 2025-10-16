#!/bin/bash
set -e

echo "🐧 Arch Linux Docker Installation Script"
echo "---------------------------------------"

# 🧠 Check if running on Arch-based system
if ! grep -qEi 'arch|manjaro|endeavouros' /etc/os-release; then
  echo "❌ This script is only for Arch-based distributions."
  exit 1
fi

# 📦 Ensure pacman exists
if ! command -v pacman &>/dev/null; then
  echo "❌ pacman not found. This script requires Arch-based package manager."
  exit 1
fi

# 🧩 Update system and install dependencies
echo "🔄 Updating system and installing dependencies..."
sudo pacman -Syu --noconfirm
sudo pacman -S --noconfirm docker docker-compose git curl

# 👤 Ask for username
read -p "👤 Enter the username to add to Docker group (non-root user): " USERNAME
if ! id "$USERNAME" &>/dev/null; then
  echo "❌ User '$USERNAME' not found. Please create the user first."
  exit 1
fi

# 👥 Add user to docker group
echo "👥 Adding $USERNAME to Docker group..."
sudo usermod -aG docker "$USERNAME"

# ⚙️ Enable and start Docker at boot
echo "⚙️ Enabling Docker service at startup..."
sudo systemctl enable docker.service
sudo systemctl enable containerd.service
sudo systemctl start docker.service

# 🔍 Verify Docker installation
echo "🔍 Verifying Docker..."
if ! docker --version &>/dev/null; then
  echo "❌ Docker installation failed."
  exit 1
fi
echo "✅ Docker installed successfully!"

# 🖥️ GUI Selection Menu
echo ""
echo "🌐 Choose a web-based Docker GUI to install:"
echo "1) Portainer (most popular, lightweight)"
echo "2) Yacht (modern UI alternative)"
echo "3) Dockge (compose management tool)"
echo "4) None (skip GUI installation)"
echo ""
read -p "👉 Enter your choice [1-4]: " CHOICE

case $CHOICE in
  1)
    echo "🚀 Installing Portainer..."
    sudo docker volume create portainer_data
    sudo docker run -d \
      -p 9000:9000 -p 9443:9443 \
      --name portainer \
      --restart=always \
      -v /var/run/docker.sock:/var/run/docker.sock \
      -v portainer_data:/data \
      portainer/portainer-ce:latest
    echo "✅ Portainer is running at: https://localhost:9443 or http://localhost:9000"
    ;;
  2)
    echo "🚀 Installing Yacht..."
    sudo docker run -d \
      -p 8000:8000 \
      --name yacht \
      --restart=always \
      -v /var/run/docker.sock:/var/run/docker.sock \
      -v yacht_data:/config \
      selfhostedpro/yacht:latest
    echo "✅ Yacht is running at: http://localhost:8000"
    ;;
  3)
    echo "🚀 Installing Dockge..."
    sudo docker run -d \
      -p 5001:5001 \
      --name dockge \
      --restart=always \
      -v /var/run/docker.sock:/var/run/docker.sock \
      -v dockge_data:/app/data \
      louislam/dockge:latest
    echo "✅ Dockge is running at: http://localhost:5001"
    ;;
  4)
    echo "⏭️ Skipping GUI installation."
    ;;
  *)
    echo "⚠️ Invalid choice. Skipping GUI installation."
    ;;
esac

# 🧠 Remind user to re-login for group permissions
echo ""
echo "🔑 Setup complete!"
echo "➡️ You must log out and log back in for Docker group permissions to take effect."
echo "➡️ Docker starts automatically on boot."
echo ""
echo "✅ Installation finished successfully!"
