# Build stage
FROM node:22-bookworm-slim AS builder

RUN apt-get update && apt-get install -y --no-install-recommends git ca-certificates && rm -rf /var/lib/apt/lists/*

RUN corepack enable && corepack prepare pnpm@latest --activate

WORKDIR /app

# Clone latest release
RUN LATEST_TAG=$(git ls-remote --tags --sort=-v:refname https://github.com/openclaw/openclaw.git | head -1 | sed 's/.*refs\/tags\///') && \
    git clone --depth 1 --branch "$LATEST_TAG" https://github.com/openclaw/openclaw.git . && \
    echo "$LATEST_TAG" > /app/.version

RUN pnpm install --frozen-lockfile || pnpm install

# Build in correct order per upstream docs
RUN pnpm ui:build && pnpm build

# Production stage
FROM node:22-bookworm-slim AS runtime

RUN corepack enable && corepack prepare pnpm@latest --activate

WORKDIR /app

# Copy built artifacts
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package.json ./
COPY --from=builder /app/pnpm-lock.yaml* ./
COPY --from=builder /app/.version ./

# Install production dependencies only and clean cache
RUN pnpm install --prod --frozen-lockfile || pnpm install --prod && \
    pnpm store prune && \
    rm -rf /root/.cache /tmp/*

ENV NODE_ENV=production

# OpenClaw gateway default port
EXPOSE 18789

# Data directory for persistent storage
VOLUME ["/app/data"]

CMD ["node", "dist/index.js", "gateway", "--bind", "0.0.0.0"]
