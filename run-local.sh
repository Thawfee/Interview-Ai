#!/usr/bin/env bash
set -e
echo "1) Starting MySQL with Docker Compose..."
docker compose up -d mysql
echo "2) Start backend in another terminal: cd backend && mvn spring-boot:run"
echo "3) Start frontend in another terminal: cd frontend && npm install && npm run dev"
