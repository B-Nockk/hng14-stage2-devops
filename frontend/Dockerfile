# Stage 1: builder
FROM node:20-alpine AS builder

WORKDIR /build

# Copy package files and install deps
COPY package*.json ./
# RUN npm ci --omit=dev
RUN npm install --omit=dev

# Stage 2: runtime
FROM node:20-alpine AS runtime

# Non-root user (node user already exists in node alpine images)
RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser

WORKDIR /app

# Copy only installed node_modules from builder
COPY --from=builder /build/node_modules ./node_modules

# Copy app source
COPY app.js .
COPY views/ ./views/
COPY package.json .

USER appuser

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/healthz', (r) => process.exit(r.statusCode === 200 ? 0 : 1))"

CMD ["node", "app.js"]
