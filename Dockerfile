# Single-stage build based on upstream Dockerfile
FROM node:22-bookworm

RUN apt-get update && apt-get install -y --no-install-recommends git ca-certificates && rm -rf /var/lib/apt/lists/*

RUN corepack enable && corepack prepare pnpm@latest --activate

WORKDIR /app

# Clone latest release
RUN LATEST_TAG=$(git ls-remote --tags --sort=-v:refname https://github.com/openclaw/openclaw.git | head -1 | sed 's/.*refs\/tags\///') && \
    git clone --depth 1 --branch "$LATEST_TAG" https://github.com/openclaw/openclaw.git . && \
    echo "$LATEST_TAG" > /app/.version

RUN pnpm install --frozen-lockfile || pnpm install

# Build in correct order per upstream docs
ENV OPENCLAW_A2UI_SKIP_MISSING=1
ENV OPENCLAW_PREFER_PNPM=1
RUN pnpm ui:build && pnpm build

ENV NODE_ENV=production

# Run as non-root user
USER node

EXPOSE 18789

CMD ["node", "dist/index.js", "gateway", "--bind", "lan", "--allow-unconfigured"]
