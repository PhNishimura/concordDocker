#!/bin/bash

# Script para build das imagens Docker
set -e

echo "🐳 Construindo imagens Docker para ConcordSupplies..."

# Build da imagem do backend
echo "📦 Construindo imagem do backend..."
docker build -t concord-supplies/backend:latest ./backend

# Build da imagem do frontend
echo "🎨 Construindo imagem do frontend..."
docker build -t concord-supplies/frontend:latest ./frontend

echo "✅ Build das imagens concluído!"

# Listar imagens criadas
echo "📋 Imagens criadas:"
docker images | grep concord-supplies