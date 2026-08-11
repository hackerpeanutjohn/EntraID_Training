#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${REPO_ROOT}"

if [[ "${1:-}" == "--delete-workspace" ]]; then
  docker compose down -v
  echo "Lab containers and the student workspace volume were deleted."
else
  docker compose down
  echo "Lab containers stopped. The student workspace volume was kept."
fi
