#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${REPO_ROOT}"

RELEASE_REPOSITORY="${ROADRECON_RELEASE_REPOSITORY:-hackerpeanutjohn/EntraID_Training}"
RELEASE_TAG="${ROADRECON_RELEASE_TAG:-course-assets}"
ENCRYPTED_FILE="roadrecon.db.age"
ENCRYPTED_CHECKSUM_FILE="roadrecon.db.age.sha256"
DATABASE_CHECKSUM_FILE="roadrecon.db.sha256"

valid_encrypted_asset() {
  [[ -f "${ENCRYPTED_FILE}" ]] || return 1
  [[ -f "${ENCRYPTED_CHECKSUM_FILE}" ]] || return 1
  [[ -f "${DATABASE_CHECKSUM_FILE}" ]] || return 1
  sha256sum -c "${ENCRYPTED_CHECKSUM_FILE}" >/dev/null 2>&1
}

if valid_encrypted_asset; then
  echo "Encrypted ROADrecon asset is ready and its SHA-256 checksum is valid."
  exit 0
fi

command -v gh >/dev/null || {
  echo "error: GitHub CLI is not installed" >&2
  exit 69
}

DOWNLOAD_DIR="$(mktemp -d)"
trap 'rm -rf "${DOWNLOAD_DIR}"' EXIT

echo "Downloading the encrypted ROADrecon asset from release ${RELEASE_TAG}..."
DOWNLOAD_ARGS=(
  release download "${RELEASE_TAG}"
  --repo "${RELEASE_REPOSITORY}"
  --pattern "${ENCRYPTED_FILE}"
  --pattern "${ENCRYPTED_CHECKSUM_FILE}"
  --pattern "${DATABASE_CHECKSUM_FILE}"
  --dir "${DOWNLOAD_DIR}"
)

if [[ -n "${GH_TOKEN:-}" ]]; then
  GH_TOKEN="${GH_TOKEN}" gh "${DOWNLOAD_ARGS[@]}"
elif [[ -n "${GITHUB_TOKEN:-}" ]]; then
  GH_TOKEN="${GITHUB_TOKEN}" gh "${DOWNLOAD_ARGS[@]}"
else
  gh "${DOWNLOAD_ARGS[@]}"
fi

(
  cd "${DOWNLOAD_DIR}"
  sha256sum -c "${ENCRYPTED_CHECKSUM_FILE}"
)

mv "${DOWNLOAD_DIR}/${ENCRYPTED_FILE}" "${ENCRYPTED_FILE}"
mv "${DOWNLOAD_DIR}/${ENCRYPTED_CHECKSUM_FILE}" "${ENCRYPTED_CHECKSUM_FILE}"
mv "${DOWNLOAD_DIR}/${DATABASE_CHECKSUM_FILE}" "${DATABASE_CHECKSUM_FILE}"
echo "Encrypted ROADrecon asset downloaded and verified."
