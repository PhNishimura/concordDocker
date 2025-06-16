#!/bin/bash

# 🚀 Script de Início Rápido para Play with Docker
# Execute: chmod +x quick-start.sh && ./quick-start.sh

set -e

echo "🐳 ConcordSupplies - Início Rápido no Play with Docker"
echo "=================================================="

# Verificar se estamos no diretório correto
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ Arquivo docker-compose.yml não encontrado!"
    echo "📁 Certifique-se de estar no diretório correto do projeto"
    exit 1
fi

# Parar containers existentes
echo "🛑 Parando containers existentes..."
docker-compose down 2>/dev/null || true

# Limpar recursos antigos
echo "🧹 Limpando recursos antigos..."
docker system prune -f

# Construir e iniciar serviços
echo "🔨 Construindo e iniciando serviços..."
docker-compose up --build -d

# Aguardar serviços ficarem prontos
echo "⏳ Aguardando serviços ficarem prontos..."
sleep 30

# Verificar status
echo "📊 Status dos serviços:"
docker-compose ps

# Testar conectividade
echo "🔍 Testando conectividade..."
if curl -s http://localhost/health > /dev/null; then
    echo "✅ Nginx está respondendo!"
else
    echo "⚠️  Nginx não está respondendo ainda..."
fi

# Mostrar informações úteis
echo ""
echo "🎉 Aplicação iniciada com sucesso!"
echo "================================="
echo "📱 Frontend: Clique em 'OPEN PORT' e digite 80"
echo "🔧 API: http://localhost/api/"
echo "📊 Status: docker-compose ps"
echo "📋 Logs: docker-compose logs -f"
echo "🛑 Parar: docker-compose down"
echo ""
echo "🔗 Para acessar, clique no botão 'OPEN PORT' ao lado do IP"
echo "   e digite a porta 80, ou clique diretamente na porta 80"
echo ""