# ConcordSupplies - Docker Setup

Este documento explica como executar a aplicação ConcordSupplies usando Docker, Docker Compose e Docker Swarm.

## 📋 Pré-requisitos

- Docker Engine 20.10+
- Docker Compose 2.0+
- Docker Swarm (para clusterização)

## 🚀 Execução Local com Docker Compose

### Desenvolvimento
```bash
# Executar em modo desenvolvimento
docker-compose up --build

# Executar em background
docker-compose up -d --build

# Ver logs
docker-compose logs -f

# Parar serviços
docker-compose down
```

### Produção
```bash
# Executar em modo produção
docker-compose -f docker-compose.prod.yml up -d --build

# Verificar status
docker-compose -f docker-compose.prod.yml ps

# Parar serviços
docker-compose -f docker-compose.prod.yml down
```

## 🐳 Docker Swarm (Clusterização)

### Inicializar Swarm
```bash
# Inicializar o swarm (apenas no manager)
docker swarm init

# Para adicionar workers (executar nos nós worker)
docker swarm join --token <TOKEN> <MANAGER-IP>:2377
```

### Deploy Automatizado
```bash
# Dar permissão aos scripts
chmod +x scripts/*.sh

# Deploy completo
./scripts/deploy-swarm.sh

# Remover stack
./scripts/remove-swarm.sh
```

### Deploy Manual
```bash
# Build das imagens
docker build -t concord-supplies/backend:latest ./backend
docker build -t concord-supplies/frontend:latest ./frontend

# Deploy do stack
docker stack deploy -c docker-swarm-stack.yml concord-supplies

# Verificar serviços
docker stack services concord-supplies
docker stack ps concord-supplies

# Remover stack
docker stack rm concord-supplies
```

## 🏗️ Arquitetura

### Serviços
- **Backend**: API REST (Node.js + Express + Sequelize)
- **Frontend**: Interface web (Nuxt.js + Vue.js)
- **Nginx**: Reverse proxy e load balancer
- **SQLite**: Banco de dados (volume persistente)

### Rede
- **Desenvolvimento**: Bridge network
- **Produção/Swarm**: Overlay network

### Volumes
- `backend_data`: Dados persistentes do SQLite

## 🔧 Configurações

### Variáveis de Ambiente

#### Backend
- `NODE_ENV=production`
- `PORT=3001`

#### Frontend
- `NODE_ENV=production`
- `NITRO_PORT=3000`
- `NITRO_HOST=0.0.0.0`
- `API_BASE_URL=http://backend:3001`

### Portas
- **80**: Nginx (HTTP)
- **443**: Nginx (HTTPS) - opcional
- **3000**: Frontend (interno)
- **3001**: Backend (interno)

## 📊 Monitoramento

### Verificar Status
```bash
# Docker Compose
docker-compose ps
docker-compose logs [service]

# Docker Swarm
docker stack services concord-supplies
docker stack ps concord-supplies
docker service logs concord-supplies_backend
```

### Health Checks
Todos os serviços possuem health checks configurados:
- **Backend**: `GET /usuario`
- **Frontend**: `GET /`
- **Nginx**: `GET /health`

## 🔒 Segurança

### Nginx
- Rate limiting configurado
- Headers de segurança
- Compressão gzip
- CORS configurado para API

### Docker
- Imagens baseadas em Alpine Linux
- Usuários não-root
- Recursos limitados
- Restart policies configuradas

## 🚀 Escalabilidade

### Docker Swarm
- **Backend**: 3 réplicas
- **Frontend**: 3 réplicas
- **Nginx**: 2 réplicas
- Load balancing automático
- Rolling updates
- Auto-restart em falhas

### Recursos
- CPU e memória limitados por serviço
- Placement constraints configurados
- Update e rollback policies

## 🛠️ Troubleshooting

### Problemas Comuns

1. **Porta em uso**
   ```bash
   # Verificar portas em uso
   netstat -tulpn | grep :80
   
   # Parar serviços conflitantes
   sudo systemctl stop apache2
   ```

2. **Volumes com permissão**
   ```bash
   # Ajustar permissões
   sudo chown -R $USER:$USER ./data
   ```

3. **Swarm não inicializado**
   ```bash
   # Verificar status
   docker info | grep Swarm
   
   # Inicializar se necessário
   docker swarm init
   ```

### Logs Úteis
```bash
# Logs do compose
docker-compose logs -f [service]

# Logs do swarm
docker service logs -f concord-supplies_backend

# Logs do sistema
journalctl -u docker.service
```

## 📈 Performance

### Otimizações Implementadas
- Multi-stage builds
- Imagens Alpine Linux
- Gzip compression
- Static file caching
- Connection pooling
- Health checks otimizados

### Métricas Recomendadas
- CPU e memória por container
- Latência de resposta
- Taxa de erro HTTP
- Throughput de requests
- Uptime dos serviços

## 🔄 CI/CD

Para integração contínua, considere:
- Build automático das imagens
- Testes automatizados
- Deploy automático no Swarm
- Rollback automático em falhas
- Monitoramento pós-deploy