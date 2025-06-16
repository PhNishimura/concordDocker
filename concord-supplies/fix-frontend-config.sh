#!/bin/bash

# 🔧 Script para corrigir configuração do frontend
# Execute: chmod +x fix-frontend-config.sh && ./fix-frontend-config.sh

echo "🔧 Corrigindo configuração do Frontend"
echo "====================================="

# Parar containers
echo "🛑 Parando containers..."
docker-compose down

# Verificar se o arquivo nuxt.config.ts está correto
echo "📝 Verificando configuração do Nuxt..."

# Recriar o arquivo de configuração do Nuxt com as configurações corretas
cat > frontend/nuxt.config.ts << 'EOF'
export default defineNuxtConfig({
  compatibilityDate: '2025-05-15',
  devtools: { enabled: true },

  // Configuração das variáveis em tempo de execução
  runtimeConfig: {
    public: {
      // URL base da API backend - usar nginx como proxy
      apiBase: process.env.API_BASE_URL || '/api'
    }
  },

  // Configuração do servidor para produção
  nitro: {
    port: process.env.NITRO_PORT || 3000,
    host: process.env.NITRO_HOST || '0.0.0.0'
  }
})
EOF

echo "✅ Arquivo nuxt.config.ts atualizado!"

# Atualizar docker-compose.yml para corrigir variáveis de ambiente
echo "📝 Atualizando docker-compose.yml..."

cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  # Backend Service
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: concord-backend
    ports:
      - "3001:3001"
    environment:
      - NODE_ENV=production
      - PORT=3001
    volumes:
      - backend_data:/app/data
    networks:
      - concord-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:3001/usuario"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  # Frontend Service
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    container_name: concord-frontend
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - NITRO_PORT=3000
      - NITRO_HOST=0.0.0.0
      - API_BASE_URL=/api
    depends_on:
      - backend
    networks:
      - concord-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:3000"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  # Nginx Reverse Proxy
  nginx:
    image: nginx:alpine
    container_name: concord-nginx
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
    depends_on:
      - frontend
      - backend
    networks:
      - concord-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost/health"]
      interval: 30s
      timeout: 10s
      retries: 3

volumes:
  backend_data:
    driver: local

networks:
  concord-network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16
EOF

echo "✅ docker-compose.yml atualizado!"

# Rebuild e restart
echo "🔨 Reconstruindo e reiniciando containers..."
docker-compose up --build -d

echo "⏳ Aguardando containers ficarem prontos..."
sleep 30

echo "📊 Status final:"
docker-compose ps

echo ""
echo "🎉 Correção concluída!"
echo "🌐 Teste acessando: http://localhost"
echo "🔍 Para diagnosticar: ./debug-containers.sh"
EOF

chmod +x fix-frontend-config.sh