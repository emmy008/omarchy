#!/bin/bash

# Install Docker from official repository
if ! command -v docker &>/dev/null; then
  # Add Docker's official GPG key
  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  sudo chmod a+r /etc/apt/keyrings/docker.gpg

  # Add the repository to Apt sources
  # For Ubuntu 25.04 (plucky), fall back to noble (24.04 LTS) if not available yet
  DOCKER_CODENAME=$(. /etc/os-release && echo "$VERSION_CODENAME")
  
  # Check if Docker has a release for this Ubuntu version
  if ! curl -fsSL "https://download.docker.com/linux/ubuntu/dists/$DOCKER_CODENAME/Release" &>/dev/null; then
    echo "Docker repository not available for $DOCKER_CODENAME, using noble (24.04 LTS) instead"
    DOCKER_CODENAME="noble"
  fi
  
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $DOCKER_CODENAME stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  
  # Update package index for Docker repository only
  sudo apt update -o Dir::Etc::sourcelist="sources.list.d/docker.list" -o Dir::Etc::sourceparts="-" -o APT::Get::List-Cleanup="0"
  
  # Install Docker
  sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
fi

# Limit log size to avoid running out of disk
sudo mkdir -p /etc/docker
echo '{"log-driver":"json-file","log-opts":{"max-size":"10m","max-file":"5"}}' | sudo tee /etc/docker/daemon.json

# Configure Docker service if systemd is available
if command -v systemctl &>/dev/null && systemctl list-units &>/dev/null 2>&1; then
  # Start Docker automatically
  sudo systemctl enable docker
  
  # Prevent Docker from preventing boot for network-online.target
  sudo mkdir -p /etc/systemd/system/docker.service.d
  sudo tee /etc/systemd/system/docker.service.d/no-block-boot.conf <<'EOF'
[Unit]
DefaultDependencies=no
EOF
  
  sudo systemctl daemon-reload
fi

# Give this user privileged Docker access
sudo usermod -aG docker ${USER}