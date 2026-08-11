#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${REPO_ROOT}"

bash scripts/decrypt-roadrecon-snapshot.sh

SQLITE_SIGNATURE="$(dd if=roadrecon.db bs=16 count=1 2>/dev/null || true)"
if [[ "${SQLITE_SIGNATURE}" != "SQLite format 3" ]]; then
  echo "error: roadrecon.db is not a valid SQLite database" >&2
  exit 65
fi

if ! docker info >/dev/null 2>&1; then
  echo "error: the Codespaces Docker engine is not ready" >&2
  exit 69
fi

docker compose pull
docker compose up -d

for _ in $(seq 1 60); do
  CONTAINER_ID="$(docker compose ps -q workstation 2>/dev/null || true)"
  STATUS=""
  if [[ -n "${CONTAINER_ID}" ]]; then
    STATUS="$(docker inspect --format '{{if .State.Health}}{{.State.Health.Status}}{{else}}{{.State.Status}}{{end}}' "${CONTAINER_ID}" 2>/dev/null || true)"
  fi
  if [[ "${STATUS}" == "healthy" ]]; then
    docker compose ps
    echo
    echo "Lab workstation is ready. Open port 6080 from the Codespaces PORTS tab."
    exit 0
  fi
  if [[ "${STATUS}" == "unhealthy" || "${STATUS}" == "exited" || "${STATUS}" == "dead" ]]; then
    docker compose ps
    docker compose logs --tail=100 workstation
    exit 1
  fi
  sleep 2
done

docker compose ps
echo "error: workstation did not become healthy within 120 seconds" >&2
exit 1
