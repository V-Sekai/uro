#!/bin/bash

# Script to update /etc/hosts on Linux/Mac and setup env files

# Update hosts file
HOSTS_FILE="/etc/hosts"
ENTRIES=(
    "0.0.0.0 vsekai.local"
    "0.0.0.0 uro.v-sekai.cloud"
)

echo "Updating hosts file"

for ENTRY in "${ENTRIES[@]}"; do
    DOMAIN=$(echo "$ENTRY" | awk '{print $2}')
    if grep -q "$DOMAIN" "$HOSTS_FILE"; then
        echo "Entry for $DOMAIN already exists in $HOSTS_FILE"
    else
        echo "Adding entry for $DOMAIN to $HOSTS_FILE"
        echo "$ENTRY" | sudo tee -a "$HOSTS_FILE" > /dev/null
    fi
done

echo "Hosts file update complete"


echo "Creating env files if they do not exist"

# Setup env files
if [ -f ".env.example" ] && [ ! -f ".env" ]; then
    mv .env.example .env
    echo "Moved .env.example to .env"
fi

if [ -f "frontend/.env.example" ] && [ ! -f "frontend/.env" ]; then
    mv frontend/.env.example frontend/.env
    echo "Moved frontend/.env.example to frontend/.env"
fi

echo "Initial setup complete"
