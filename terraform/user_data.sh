#!/bin/bash
# Runs once as root on first boot (cloud-init)
# Print each command and stop on the first error
set -euxo pipefail

# Install and start docker
dnf install -y docker
systemctl enable --now docker

# Run the app container (public image, no login needed)
docker run -d \
  --name mini-devops-lab \
  --restart unless-stopped \
  -p 5000:5000 \
  ghcr.io/ghaith-bl/mini-devops-lab:latest
