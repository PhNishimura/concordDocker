# 🐳 Tutorial: ConcordSupplies no Play with Docker

## 📋 Passo a Passo Completo

### 1️⃣ **Preparar o Ambiente**

No terminal do Play with Docker, execute:

```bash
# Verificar se Docker está funcionando
docker --version
docker-compose --version

# Criar diretório do projeto
mkdir concord-supplies
cd concord-supplies
```

### 2️⃣ **Baixar os Arquivos do Projeto**

Você pode fazer de duas formas:

#### Opção A: Clonar repositório (se disponível)
```bash
# Se você tiver o projeto no GitHub
git clone <SEU_REPOSITORIO_URL> .
```

#### Opção B: Criar arquivos manualmente
```bash
# Criar estrutura de diretórios
mkdir -p backend frontend nginx scripts

# Você precisará criar cada arquivo usando o editor
# Clique em "EDITOR" no Play with Docker para criar os arquivos
```

### 3️⃣ **Criar Arquivos Essenciais**

Use o **EDITOR** do Play with Docker para criar estes arquivos:

#### 📁 `backend/Dockerfile`
```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN mkdir -p /app/data
EXPOSE 3001
ENV NODE_ENV=production
ENV PORT=3001
CMD ["npm", "start"]
```

#### 📁 `frontend/Dockerfile`
```dockerfile
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:18-alpine AS production
WORKDIR /app
COPY --from=builder /app/.output ./
COPY --from=builder /app/package*.json ./
RUN npm ci --only=production
EXPOSE 3000
ENV NODE_ENV=production
ENV NITRO_PORT=3000
ENV NITRO_HOST=0.0.0.0
CMD ["node", "server/index.mjs"]
```

#### 📁 `docker-compose.yml`
```yaml
version: '3.8'

services:
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
      - API_BASE_URL=http://backend:3001
    depends_on:
      - backend
    networks:
      - concord-network
    restart: unless-stopped

  nginx:
    image: nginx:alpine
    container_name: concord-nginx
    ports:
      - "80:80"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
    depends_on:
      - frontend
      - backend
    networks:
      - concord-network
    restart: unless-stopped

volumes:
  backend_data:
    driver: local

networks:
  concord-network:
    driver: bridge
```

#### 📁 `nginx/nginx.conf`
```nginx
events {
    worker_connections 1024;
}

http {
    upstream frontend {
        server frontend:3000;
    }

    upstream backend {
        server backend:3001;
    }

    server {
        listen 80;
        server_name localhost;

        location /health {
            access_log off;
            return 200 "healthy\n";
            add_header Content-Type text/plain;
        }

        location /api/ {
            rewrite ^/api/(.*)$ /$1 break;
            proxy_pass http://backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        location / {
            proxy_pass http://frontend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
```

### 4️⃣ **Executar a Aplicação**

#### Método 1: Docker Compose (Recomendado para início)
```bash
# Navegar para o diretório do projeto
cd concord-supplies

# Construir e executar os serviços
docker-compose up --build -d

# Verificar se os containers estão rodando
docker-compose ps

# Ver logs em tempo real
docker-compose logs -f
```

#### Método 2: Docker Swarm (Para clusterização)
```bash
# Inicializar Docker Swarm
docker swarm init

# Construir imagens
docker build -t concord-supplies/backend:latest ./backend
docker build -t concord-supplies/frontend:latest ./frontend

# Deploy do stack
docker stack deploy -c docker-swarm-stack.yml concord-supplies

# Verificar serviços
docker stack services concord-supplies
```

### 5️⃣ **Acessar a Aplicação**

No Play with Docker:

1. **Clique no botão "OPEN PORT"** (ao lado do IP)
2. **Digite a porta 80** e clique em OK
3. **Ou clique diretamente na porta 80** se ela aparecer automaticamente

A aplicação estará disponível em:
- **Frontend**: `http://ip172-18-0-21-xxx.direct.labs.play-with-docker.com`
- **API Backend**: `http://ip172-18-0-21-xxx.direct.labs.play-with-docker.com/api/`

### 6️⃣ **Comandos Úteis para Monitoramento**

```bash
# Ver status dos containers
docker ps

# Ver logs de um serviço específico
docker-compose logs backend
docker-compose logs frontend
docker-compose logs nginx

# Entrar em um container
docker exec -it concord-backend sh
docker exec -it concord-frontend sh

# Ver uso de recursos
docker stats

# Parar todos os serviços
docker-compose down

# Parar e remover volumes
docker-compose down -v
```

### 7️⃣ **Testar a API**

```bash
# Testar se a API está funcionando
curl http://localhost/api/usuario

# Criar um usuário de teste
curl -X POST http://localhost/api/usuario \
  -H "Content-Type: application/json" \
  -d '{
    "nomeUser": "Teste User",
    "email": "teste@example.com",
    "senha": "123456",
    "tipo": "comum"
  }'

# Listar usuários
curl http://localhost/api/usuario
```

### 8️⃣ **Troubleshooting**

#### Problema: Containers não sobem
```bash
# Verificar logs de erro
docker-compose logs

# Verificar se as portas estão livres
netstat -tulpn | grep :80
netstat -tulpn | grep :3000
netstat -tulpn | grep :3001
```

#### Problema: Erro de build
```bash
# Limpar cache do Docker
docker system prune -a

# Rebuild forçado
docker-compose build --no-cache
docker-compose up --force-recreate
```

#### Problema: Frontend não conecta com Backend
```bash
# Verificar se os containers estão na mesma rede
docker network ls
docker network inspect concord-supplies_concord-network

# Testar conectividade entre containers
docker exec concord-frontend ping backend
```

### 9️⃣ **Estrutura Final do Projeto**

```
concord-supplies/
├── backend/
│   ├── Dockerfile
│   ├── package.json
│   ├── server.js
│   └── ... (outros arquivos do backend)
├── frontend/
│   ├── Dockerfile
│   ├── package.json
│   ├── nuxt.config.ts
│   └── ... (outros arquivos do frontend)
├── nginx/
│   └── nginx.conf
├── docker-compose.yml
├── docker-compose.prod.yml
└── docker-swarm-stack.yml
```

### 🔟 **Próximos Passos**

1. **Testar todas as funcionalidades** da aplicação
2. **Criar dados de teste** via interface web
3. **Monitorar performance** dos containers
4. **Experimentar com scaling** usando Docker Swarm
5. **Implementar CI/CD** se necessário

---

## 🚨 **Dicas Importantes para Play with Docker**

- ⏰ **Sessão expira em 4 horas** - salve seu trabalho!
- 💾 **Use volumes** para dados persistentes
- 🔗 **URLs mudam** a cada sessão
- 📊 **Monitore recursos** - RAM limitada
- 🔄 **Reinicie containers** se necessário

## 📞 **Suporte**

Se encontrar problemas:
1. Verifique os logs: `docker-compose logs`
2. Teste conectividade: `docker exec -it container_name sh`
3. Reinicie serviços: `docker-compose restart`
4. Rebuild se necessário: `docker-compose up --build --force-recreate`