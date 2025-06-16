#!/bin/bash

# Script para remover o stack do Docker Swarm
set -e

STACK_NAME="concord-supplies"

echo "🗑️  Removendo stack '$STACK_NAME' do Docker Swarm..."

# Remover o stack
docker stack rm $STACK_NAME

echo "⏳ Aguardando remoção completa..."
sleep 10

# Verificar se foi removido
if docker stack ls | grep -q $STACK_NAME; then
    echo "⚠️  Stack ainda está sendo removido..."
else
    echo "✅ Stack removido com sucesso!"
fi

# Limpar volumes órfãos (opcional)
read -p "🧹 Deseja limpar volumes órfãos? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    docker volume prune -f
    echo "✅ Volumes órfãos removidos!"
fi