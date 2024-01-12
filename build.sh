#!/bin/bash

sudo docker build -t uro:build -f base.Dockerfile . && sudo docker-compose up -d
echo Build Done! Check above to see result...