# Imatge de producció de la web (React/Vite) per a un servidor propi.
# Caddy servix els fitxers estàtics, fa de proxy invers cap a l'API i obté
# el certificat HTTPS (imprescindible perquè el navegador concedisca el micròfon).
# El context de build és l'arrel del monorepo (vegeu .dockerignore).
FROM node:22-alpine AS build
WORKDIR /app
COPY package*.json ./
COPY shared/package.json shared/package.json
COPY frontend/package.json frontend/package.json
RUN npm ci
COPY shared ./shared
COPY frontend ./frontend
# Les VITE_* s'incrusten al bundle durant el build: canviar-les exigix reconstruir.
# VITE_API_BASE_URL buida = mateix origen (`/api/...`), Caddy ho reenvia a l'API.
ARG VITE_SUPABASE_URL
ARG VITE_SUPABASE_ANON_KEY
ARG VITE_API_BASE_URL=
ENV VITE_SUPABASE_URL=$VITE_SUPABASE_URL \
    VITE_SUPABASE_ANON_KEY=$VITE_SUPABASE_ANON_KEY \
    VITE_API_BASE_URL=$VITE_API_BASE_URL
# `shared` primer: el frontend n'importa els tipus.
RUN npm run build -w @parlaval/shared && npm run build -w parlaval-web

FROM caddy:2-alpine
COPY deploy/Caddyfile /etc/caddy/Caddyfile
COPY --from=build /app/frontend/dist /srv
EXPOSE 80 443
