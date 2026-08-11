#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${REPO_ROOT}"

DATABASE_FILE="roadrecon.db"
DATABASE_CHECKSUM_FILE="roadrecon.db.sha256"
ENCRYPTED_FILE="roadrecon.db.age"

valid_snapshot() {
  [[ -f "${DATABASE_FILE}" ]] || return 1
  [[ -f "${DATABASE_CHECKSUM_FILE}" ]] || return 1
  sha256sum -c "${DATABASE_CHECKSUM_FILE}" >/dev/null 2>&1 || return 1
  [[ "$(dd if="${DATABASE_FILE}" bs=15 count=1 2>/dev/null || true)" == "SQLite format 3" ]]
}

if valid_snapshot; then
  echo "ROADrecon snapshot is already decrypted and verified."
  exit 0
fi

command -v age >/dev/null || {
  echo "error: age is not installed; rebuild this Codespace" >&2
  exit 69
}

bash scripts/fetch-roadrecon-snapshot.sh

DECRYPT_DIR="$(mktemp -d)"
trap 'rm -rf "${DECRYPT_DIR}"' EXIT

echo
echo "請輸入講師現場公布的解密密碼（輸入時畫面不會顯示字元）："
age --decrypt --output "${DECRYPT_DIR}/${DATABASE_FILE}" "${ENCRYPTED_FILE}"
cp "${DATABASE_CHECKSUM_FILE}" "${DECRYPT_DIR}/${DATABASE_CHECKSUM_FILE}"

(
  cd "${DECRYPT_DIR}"
  sha256sum -c "${DATABASE_CHECKSUM_FILE}"
)

if [[ "$(dd if="${DECRYPT_DIR}/${DATABASE_FILE}" bs=15 count=1 2>/dev/null || true)" != "SQLite format 3" ]]; then
  echo "error: decrypted roadrecon.db is not a valid SQLite database" >&2
  exit 65
fi

mv "${DECRYPT_DIR}/${DATABASE_FILE}" "${DATABASE_FILE}"
echo "ROADrecon snapshot decrypted and verified."
