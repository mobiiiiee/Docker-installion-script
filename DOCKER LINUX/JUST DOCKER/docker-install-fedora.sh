#!/bin/bash
set -e

echo "🐧 Fedora Docker Installation Script"
echo "-----------------------------------"

# 🧠 Check if running on Fedora
if ! grep -qi "fedora" /etc/os-release; then
  echo "❌ This script is only for Fedora-based distributions."
  exit 1
fi

# 📦 Update system
echo "🔄 Updating system..."
sudo dnf update -y

# 🧱 Remove any old Docker versions
echo "🧹 Removing old Docker versions (if any)..."
sudo dnf remove -y docker docker-client docker-client-latest docker-common docker-latest \
  docker-latest-logrotate docker-logrotate docker-engine || true

# 📜 Add Docker repository if not already added
if ! sudo dnf repolist | grep -q "docker-ce-stable"; then
  echo "📦 Adding official Docker repository..."
  sudo dnf -y install dnf-plugins-core
  sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
fi

# 🐳 Install Docker
echo "🐳 Installing Docker Engine, CLI, and Compose..."
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

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
echo "⚙️ Enabling and starting Docker service..."
sudo systemctl enable docker
sudo systemctl start docker

# ✅ Verify Docker
if docker --version &>/dev/null; then
  echo "✅ Docker installed successfully: $(docker --version)"
else
  echo "❌ Docker installation failed."
  exit 1
fi

echo ""
echo "🌐 Choose a web-based Docker GUI to install:"
echo "1) Portainer (most popular, easy to use)"
echo "2) Yacht (modern interface)"
echo "3) Dockge (docker-compose manager)"
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
    sudo docker volume create yacht_data
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
    sudo docker volume create dockge_data
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

# 🧠 Remind user about group change
echo ""
echo "🔑 Setup complete!"
echo "➡️ You must log out and log back in for Docker group permissions to take effect."
echo "➡️ Docker will start automatically on boot."
echo ""
echo "✅ Installation finished successfully!"
