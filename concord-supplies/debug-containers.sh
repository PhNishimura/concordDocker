#!/bin/bash

# 🔍 Script para diagnosticar problemas de comunicação entre containers
# Execute: chmod +x debug-containers.sh && ./debug-containers.sh

echo "🔍 Diagnóstico de Containers - ConcordSupplies"
echo "=============================================="

# Verificar se os containers estão rodando
echo "📊 Status dos containers:"
docker-compose ps
echo ""

# Verificar logs dos containers
echo "📋 Logs do Backend (últimas 20 linhas):"
docker-compose logs --tail=20 backend
echo ""

echo "📋 Logs do Frontend (últimas 20 linhas):"
docker-compose logs --tail=20 frontend
echo ""

echo "📋 Logs do Nginx (últimas 20 linhas):"
docker-compose logs --tail=20 nginx
echo ""

# Testar conectividade interna
echo "🔗 Testando conectividade interna:"
echo "Backend para Frontend:"
docker exec concord-backend ping -c 2 frontend 2>/dev/null || echo "❌ Backend não consegue alcançar Frontend"

echo "Frontend para Backend:"
docker exec concord-frontend ping -c 2 backend 2>/dev/null || echo "❌ Frontend não consegue alcançar Backend"

echo "Nginx para Backend:"
docker exec concord-nginx ping -c 2 backend 2>/dev/null || echo "❌ Nginx não consegue alcançar Backend"

echo "Nginx para Frontend:"
docker exec concord-nginx ping -c 2 frontend 2>/dev/null || echo "❌ Nginx não consegue alcançar Frontend"

# Testar portas internas
echo ""
echo "🔌 Testando portas internas:"
echo "Backend (porta 3001):"
docker exec concord-backend wget -q --spider http://localhost:3001/usuario && echo "✅ Backend respondendo na porta 3001" || echo "❌ Backend não responde na porta 3001"

echo "Frontend (porta 3000):"
docker exec concord-frontend wget -q --spider http://localhost:3000 && echo "✅ Frontend respondendo na porta 3000" || echo "❌ Frontend não responde na porta 3000"

# Testar através do Nginx
echo ""
echo "🌐 Testando através do Nginx:"
echo "API através do Nginx:"
curl -s http://localhost/api/usuario > /dev/null && echo "✅ API acessível via Nginx" || echo "❌ API não acessível via Nginx"

echo "Frontend através do Nginx:"
curl -s http://localhost > /dev/null && echo "✅ Frontend acessível via Nginx" || echo "❌ Frontend não acessível via Nginx"

# Verificar variáveis de ambiente
echo ""
echo "🔧 Variáveis de ambiente do Frontend:"
docker exec concord-frontend env | grep -E "(API_BASE_URL|NITRO_|NODE_ENV)"

echo ""
echo "🔧 Variáveis de ambiente do Backend:"
docker exec concord-backend env | grep -E "(PORT|NODE_ENV)"

echo ""
echo "📝 Diagnóstico concluído!"