# Imatge del servidor MCP lingüístic (HTTP). El context de build és l'arrel del monorepo (vegeu .dockerignore).
FROM node:22-alpine AS build
WORKDIR /app
COPY package*.json ./
COPY mcp/package.json mcp/package.json
RUN npm ci -w parlaval-mcp --include-workspace-root=false
COPY mcp ./mcp
RUN npm run build -w parlaval-mcp

FROM node:22-alpine AS prod-deps
WORKDIR /app
COPY package*.json ./
COPY mcp/package.json mcp/package.json
RUN npm ci -w parlaval-mcp --include-workspace-root=false --omit=dev

FROM node:22-alpine
WORKDIR /app
ENV NODE_ENV=production
COPY --from=build /app/mcp/package.json ./package.json
COPY --from=prod-deps /app/node_modules ./node_modules
COPY --from=build /app/mcp/dist ./dist
USER node
ENV PORT=3002
EXPOSE 3002
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s \
  CMD node -e "fetch('http://127.0.0.1:'+(process.env.PORT||3002)+'/health').then(r=>process.exit(r.ok?0:1)).catch(()=>process.exit(1))"
CMD ["node", "dist/index.js"]
