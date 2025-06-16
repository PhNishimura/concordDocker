# Dockerfile para o Backend
FROM node:18-alpine

# Definir diretório de trabalho
WORKDIR /app

# Copiar package.json e package-lock.json
COPY package*.json ./

# Instalar dependências
RUN npm ci --only=production

# Copiar código fonte
COPY . .

# Criar diretório para o banco SQLite
RUN mkdir -p /app/data

# Expor porta
EXPOSE 3001

# Definir variáveis de ambiente
ENV NODE_ENV=production
ENV PORT=3001

# Comando para iniciar a aplicação
CMD ["npm", "start"]