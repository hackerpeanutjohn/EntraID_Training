#!/usr/bin/env bash

set -euo pipefail

if [[ "${CODESPACES:-false}" != "true" ]]; then
  echo "This repository is intended for GitHub Codespaces."
fi

echo "Waiting for the Codespaces Docker engine..."
for _ in $(seq 1 60); do
  if docker info >/dev/null 2>&1; then
    docker version --format 'Docker server {{.Server.Version}} is ready'
    bash scripts/fetch-roadrecon-snapshot.sh
    docker compose pull
    echo "Codespace preparation is complete."
    exit 0
  fi
  sleep 2
done

echo "error: Docker did not become ready within 120 seconds" >&2
exit 1
