#!/bin/bash

# Update system
apt update -y
apt install -y docker.io docker-compose

# Enable Docker
systemctl enable docker
systemctl start docker

# Create Strapi directory
mkdir -p /home/ubuntu/strapi-docker
cd /home/ubuntu/strapi-docker

# Create docker-compose.yml
cat <<EOF > docker-compose.yml
version: "3"
services:
  strapi:
    image: strapi/strapi
    container_name: strapi-app
    ports:
      - "1337:1337"
    environment:
      - DATABASE_CLIENT=sqlite
    volumes:
      - ./project:/srv/app
    restart: always
EOF

# Start the Strapi container
docker-compose up -d
