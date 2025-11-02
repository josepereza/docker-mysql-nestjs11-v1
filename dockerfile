FROM node:18-alpine
WORKDIR /app

# Solo copia e instala dependencias de Node.js
COPY package*.json ./
RUN npm ci

# Solo copia código de NestJS
COPY . .
RUN npm run build

EXPOSE 3000
CMD ["node", "dist/main"]