# -------------------------
# 1. Builder stage
# -------------------------
FROM node:18-alpine AS builder

# Create app directory
WORKDIR /app

# Install build dependencies
# (you can optimize by copying only package*.json first, but this is simplest)
COPY . .

# Install all deps
RUN npm install

# Build Medusa (backend + admin)
# This will create .medusa/server with compiled code + admin assets
RUN npx medusa build

# Install production deps for the built server
WORKDIR /app/.medusa/server
RUN npm install --production



# -------------------------
# 2. Runtime stage
# -------------------------
FROM node:18-alpine

WORKDIR /server

ENV NODE_ENV=production
ENV PORT=9000

# Copy built server (including node_modules) from builder
COPY --from=builder /app/.medusa/server ./

# Expose Medusa port
EXPOSE 9000

# Start using the start script inside .medusa/server/package.json
CMD ["npm", "run", "start"]
