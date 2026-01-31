# openclaw-docker

Unofficial auto-built Docker image for [OpenClaw](https://openclaw.ai).

## Usage

```bash
docker run -d \
  --name openclaw \
  -p 18789:18789 \
  -v openclaw-home:/home/node \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  -e OPENCLAW_GATEWAY_TOKEN=your-secret-token \
  ghcr.io/jaronjaron/openclaw-docker:latest
```

Then access `http://localhost:18789/?token=your-secret-token`

## Configuration

Environment variables:
- `OPENCLAW_GATEWAY_TOKEN` - Required. Token for gateway authentication.
- `ANTHROPIC_API_KEY` - API key (or use `docker exec -it openclaw openclaw onboard` for Claude Max)

The container runs the gateway in LAN mode with `--allow-unconfigured` for easy setup.

## Auto-build

This image is automatically rebuilt daily when new [upstream releases](https://github.com/openclaw/openclaw/releases) are detected. Images are tagged with both `latest` and the upstream version tag.

## Sandbox Support

For sandbox isolation, ensure the Docker socket is mounted and create the sandbox image:

```bash
docker build -t openclaw-sandbox:bookworm-slim - <<'EOF'
FROM node:22-bookworm-slim
RUN useradd -m -s /bin/bash sandbox
USER sandbox
WORKDIR /home/sandbox
EOF
```

## License

MIT
