FROM node:22-alpine AS frontend-build

WORKDIR /frontend

COPY frontend/package.json ./
RUN npm install
COPY frontend ./
RUN npm run build

FROM node:22-alpine AS backend-deps

WORKDIR /app

COPY backend/package.json ./
RUN npm install --omit=dev

FROM node:22-alpine

WORKDIR /app

COPY --from=backend-deps /app/node_modules ./node_modules
COPY backend/package.json ./
COPY backend/src ./src
COPY --from=frontend-build /frontend/dist ./public

ENV NODE_ENV=production
EXPOSE 3000

CMD ["npm", "start"]
