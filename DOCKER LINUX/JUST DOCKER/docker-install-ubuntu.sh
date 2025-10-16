#!/bin/bash
set -e

echo "🐳 Welcome to the Docker + GUI Installer for Ubuntu"

# Ask for username
read -p "Enter the username to add to Docker group (default: $USER): " docker_user
docker_user=${docker_user:-$USER}

# Update system
echo "🧱 Updating system..."
sudo apt update -y
sudo apt upgrade -y

# Install dependencies
echo "📦 Installing required dependencies..."
sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release

# Add Docker’s official GPG key
echo "🔑 Adding Docker GPG key..."
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Add Docker repository
echo "📜 Setting up Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
echo "🐳 Installing Docker Engine, CLI, and Compose..."
sudo apt update -y
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Enable and start Docker
echo "⚙️ Enabling Docker to start on boot..."
sudo systemctl enable docker
sudo systemctl start docker

# Add user to docker group
echo "👤 Adding user '$docker_user' to Docker group..."
sudo usermod -aG docker "$docker_user"

# Confirm Docker installation
echo "✅ Verifying Docker installation..."
docker_version=$(docker --version 2>/dev/null || true)
if [[ -n "$docker_version" ]]; then
  echo "🎉 Docker installed successfully: $docker_version"
else
  echo "❌ Docker installation failed."
  exit 1
fi

# Ask user which GUI they want
echo ""
echo "🌐 Choose a Web-Based Docker GUI to Install:"
echo "1) Portainer (recommended, modern dashboard)"
echo "2) Yacht (beautiful lightweight interface)"
echo "3) Docker-Web-UI (minimal web control panel)"
echo "4) None (skip GUI installation)"
read -p "Enter your choice [1-4]: " gui_choice

case $gui_choice in
  1)
    echo "🚀 Installing Portainer..."
    sudo docker volume create portainer_data
    sudo docker run -d \
      -p 9000:9000 \
      -p 9443:9443 \
      --name=portainer \
      --restart=always \
      -v /var/run/docker.sock:/var/run/docker.sock \
      -v portainer_data:/data \
      portainer/portainer-ce:latest
    echo "✅ Portainer is running at: https://localhost:9443 or http://localhost:9000"
    ;;
  2)
    echo "🚀 Installing Yacht..."
    sudo docker volume create yacht
    sudo docker run -d \
      --name yacht \
      --restart=always \
      -p 8000:8000 \
      -v /var/run/docker.sock:/var/run/docker.sock \
      -v yacht:/config \
      selfhostedpro/yacht:latest
    echo "✅ Yacht is running at: http://localhost:8000"
    ;;
  3)
    echo "🚀 Installing Docker-Web-UI..."
    sudo docker run -d \
      --name docker-web-ui \
      --restart=always \
      -p 8080:8080 \
      -v /var/run/docker.sock:/var/run/docker.sock \
      uifd/ui-for-docker
    echo "✅ Docker Web UI is running at: http://localhost:8080"
    ;;
  4)
    echo "⏭️ Skipping GUI installation."
    ;;
  *)
    echo "⚠️ Invalid choice, skipping GUI installation."
    ;;
esac

# Final message
echo ""
echo "🔁 Please log out or restart your system for group changes to take effect."
echo "✅ Docker is installed and will start automatically on boot."
echo "💡 You can test with: docker run hello-world"
echo "✨ Installation complete!"
