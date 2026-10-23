FROM node:20-slim
WORKDIR /app
COPY server/package*.json ./
RUN npm ci
COPY server/tsconfig.json ./
COPY server/src ./src
COPY database/seed.json /database/seed.json
RUN npm run build && npm prune --omit=dev
EXPOSE 5000
CMD ["npm","start"]
