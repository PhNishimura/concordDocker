FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install express pg cors

COPY index.js .

CMD ["node", "index.js"]
