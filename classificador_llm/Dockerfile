# Servici web del classificador de nivell de valencià (Mòdul 3), en TypeScript.
# Es construïx des d'esta carpeta (classificador_llm/). La forma més senzilla és:
#   docker compose up -d --build

# 1a etapa: compila TypeScript → JavaScript (dist/)
FROM node:24-slim AS compilacio
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY tsconfig.json ./
COPY src ./src
RUN npx tsc

# 2a etapa: imatge final, només amb les dependències d'execució i el codi compilat
FROM node:24-slim
LABEL description="Classificador de nivell de valencià (A1-C2) amb l'API d'OpenAI - Mòdul 3"
ENV NODE_ENV=production
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --omit=dev
COPY --from=compilacio /app/dist ./dist
COPY exemples ./exemples

# La clau NO es copia en la imatge (.env està en .dockerignore): es passa en executar
EXPOSE 8000
USER node

# Servici web. Per a usar la línia d'ordres dins del contenidor:
#   docker compose exec classificador node dist/cli.js "text..."
CMD ["node", "dist/servei.js"]
