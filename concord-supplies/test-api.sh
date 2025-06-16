#!/bin/bash

# 🧪 Script para testar a API
# Execute: chmod +x test-api.sh && ./test-api.sh

set -e

BASE_URL="http://localhost/api"

echo "🧪 Testando API ConcordSupplies"
echo "==============================="

# Função para testar endpoint
test_endpoint() {
    local method=$1
    local endpoint=$2
    local data=$3
    local description=$4
    
    echo "🔍 Testando: $description"
    echo "   $method $endpoint"
    
    if [ -n "$data" ]; then
        response=$(curl -s -w "\n%{http_code}" -X $method \
            -H "Content-Type: application/json" \
            -d "$data" \
            "$BASE_URL$endpoint")
    else
        response=$(curl -s -w "\n%{http_code}" -X $method "$BASE_URL$endpoint")
    fi
    
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | head -n -1)
    
    if [ "$http_code" -eq 200 ] || [ "$http_code" -eq 201 ]; then
        echo "   ✅ Sucesso ($http_code)"
        echo "   📄 Resposta: $body" | head -c 100
        echo "..."
    else
        echo "   ❌ Erro ($http_code)"
        echo "   📄 Resposta: $body"
    fi
    echo ""
}

# Aguardar API ficar disponível
echo "⏳ Aguardando API ficar disponível..."
for i in {1..30}; do
    if curl -s http://localhost/health > /dev/null; then
        echo "✅ API está disponível!"
        break
    fi
    sleep 2
    echo "   Tentativa $i/30..."
done

echo ""

# Testar endpoints
test_endpoint "GET" "/usuario" "" "Listar usuários"

test_endpoint "POST" "/usuario" '{
    "nomeUser": "João Silva",
    "email": "joao@example.com",
    "senha": "123456",
    "tipo": "comum"
}' "Criar usuário"

test_endpoint "GET" "/produto" "" "Listar produtos"

test_endpoint "POST" "/produto" '{
    "nomeProduct": "Caneta Azul",
    "preco_unitario": 2.50,
    "descricao": "Caneta esferográfica azul",
    "unidade": "un",
    "ativo": true
}' "Criar produto"

test_endpoint "GET" "/order" "" "Listar pedidos"

echo "🎉 Testes concluídos!"
echo "💡 Para mais testes, acesse a interface web em http://localhost"