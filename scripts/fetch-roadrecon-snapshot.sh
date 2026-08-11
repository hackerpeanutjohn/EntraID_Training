#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${REPO_ROOT}"

RELEASE_REPOSITORY="${ROADRECON_RELEASE_REPOSITORY:-hackerpeanutjohn/EntraID_Training}"
RELEASE_TAG="${ROADRECON_RELEASE_TAG:-course-assets}"
DATABASE_FILE="roadrecon.db"
CHECKSUM_FILE="roadrecon.db.sha256"

valid_snapshot() {
  [[ -f "${DATABASE_FILE}" ]] || return 1
  [[ "$(dd if="${DATABASE_FILE}" bs=16 count=1 2>/dev/null || true)" == "SQLite format 3" ]] || return 1
  [[ -f "${CHECKSUM_FILE}" ]] || return 1
  sha256sum -c "${CHECKSUM_FILE}" >/dev/null 2>&1
}

if valid_snapshot; then
  echo "ROADrecon snapshot is ready and its SHA-256 checksum is valid."
  exit 0
fi

command -v gh >/dev/null || {
  echo "error: GitHub CLI is not installed" >&2
  exit 69
}

if [[ -z "${GH_TOKEN:-${GITHUB_TOKEN:-}}" ]]; then
  echo "error: no Codespaces GitHub token is available" >&2
  exit 77
fi

DOWNLOAD_DIR="$(mktemp -d)"
trap 'rm -rf "${DOWNLOAD_DIR}"' EXIT

echo "Downloading the ROADrecon snapshot from private release ${RELEASE_TAG}..."
GH_TOKEN="${GH_TOKEN:-${GITHUB_TOKEN}}" gh release download "${RELEASE_TAG}" \
  --repo "${RELEASE_REPOSITORY}" \
  --pattern "${DATABASE_FILE}" \
  --pattern "${CHECKSUM_FILE}" \
  --dir "${DOWNLOAD_DIR}"

(
  cd "${DOWNLOAD_DIR}"
  sha256sum -c "${CHECKSUM_FILE}"
)

if [[ "$(dd if="${DOWNLOAD_DIR}/${DATABASE_FILE}" bs=16 count=1 2>/dev/null || true)" != "SQLite format 3" ]]; then
  echo "error: downloaded roadrecon.db is not a valid SQLite database" >&2
  exit 65
fi

mv "${DOWNLOAD_DIR}/${DATABASE_FILE}" "${DATABASE_FILE}"
mv "${DOWNLOAD_DIR}/${CHECKSUM_FILE}" "${CHECKSUM_FILE}"
echo "ROADrecon snapshot downloaded and verified."
