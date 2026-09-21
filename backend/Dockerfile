# Imatge de producció de l'API (Express) per a Render / Railway / Fly.io.
# El context de build és l'arrel del monorepo (vegeu .dockerignore).
FROM node:22-alpine AS build
WORKDIR /app
# package.json de l'arrel i dels workspaces que fan falta: `shared` és una
# dependència real de `backend` (`@parlaval/shared`), no opcional.
COPY package*.json ./
COPY shared/package.json shared/package.json
COPY backend/package.json backend/package.json
RUN npm ci
COPY shared ./shared
COPY backend ./backend
# `shared` primer: el backend n'importa els tipus i en consumeix el `dist`.
RUN npm run build -w @parlaval/shared && npm run build -w parlaval-agent

# Dependències de producció: tsc i vitest no fan falta a runtime.
FROM node:22-alpine AS prod-deps
WORKDIR /app
COPY package*.json ./
COPY shared/package.json shared/package.json
COPY backend/package.json backend/package.json
RUN npm ci --omit=dev

FROM node:22-alpine
WORKDIR /app
ENV NODE_ENV=production
# package.json del backend: aporta "type":"module" (sense això Node fa detecció
# de sintaxi i avisa amb MODULE_TYPELESS_PACKAGE_JSON).
COPY --from=build /app/backend/package.json ./package.json
# node_modules de producció: conserva el symlink @parlaval/shared -> ../../shared
COPY --from=prod-deps /app/node_modules ./node_modules
COPY --from=build /app/shared/dist ./shared/dist
COPY --from=build /app/shared/package.json ./shared/package.json
COPY --from=build /app/backend/dist ./dist
USER node
EXPOSE 3001
# Healthcheck amb `fetch` global de Node (l'imatge alpine no porta curl).
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s \
  CMD node -e "fetch('http://127.0.0.1:'+(process.env.PORT||3001)+'/health').then(r=>process.exit(r.ok?0:1)).catch(()=>process.exit(1))"
CMD ["node", "dist/index.js"]

