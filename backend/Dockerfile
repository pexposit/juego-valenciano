FROM node:22-alpine AS build
WORKDIR /app
COPY package*.json ./
COPY backend/package.json backend/package.json
RUN npm install
COPY backend ./backend
RUN npm run build -w parlaval-agent
FROM node:22-alpine
WORKDIR /app
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/backend/dist ./dist
ENV NODE_ENV=production
CMD ["node", "dist/index.js"]
