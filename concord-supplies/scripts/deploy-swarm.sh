#!/bin/bash

# Script para deploy no Docker Swarm
set -e

STACK_NAME="concord-supplies"

echo "🚀 Iniciando deploy no Docker Swarm..."

# Verificar se o Swarm está ativo
if ! docker info | grep -q "Swarm: active"; then
    echo "⚠️  Docker Swarm não está ativo. Inicializando..."
    docker swarm init
fi

# Build das imagens
echo "📦 Construindo imagens..."
./scripts/build.sh

# Deploy do stack
echo "🚀 Fazendo deploy do stack '$STACK_NAME'..."
docker stack deploy -c docker-swarm-stack.yml $STACK_NAME

# Aguardar serviços ficarem prontos
echo "⏳ Aguardando serviços ficarem prontos..."
sleep 30

# Verificar status dos serviços
echo "📊 Status dos serviços:"
docker stack services $STACK_NAME

echo "✅ Deploy concluído!"
echo "🌐 Aplicação disponível em: http://localhost"
echo "📊 Para monitorar: docker stack ps $STACK_NAME"