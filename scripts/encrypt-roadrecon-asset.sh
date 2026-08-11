#!/usr/bin/env bash

set -euo pipefail

if [[ $# -lt 1 || $# -gt 2 ]]; then
  echo "usage: $0 /path/to/roadrecon.db [output-directory]" >&2
  exit 64
fi

SOURCE_DATABASE="$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
OUTPUT_DIRECTORY="${2:-release-assets}"

[[ -f "${SOURCE_DATABASE}" ]] || {
  echo "error: database not found: ${SOURCE_DATABASE}" >&2
  exit 66
}

if [[ "$(dd if="${SOURCE_DATABASE}" bs=16 count=1 2>/dev/null || true)" != "SQLite format 3" ]]; then
  echo "error: source file is not a valid SQLite database" >&2
  exit 65
fi

command -v age >/dev/null || {
  echo "error: age is not installed" >&2
  exit 69
}

sha256_value() {
  if command -v sha256sum >/dev/null; then
    sha256sum "$1" | awk '{print $1}'
  elif command -v shasum >/dev/null; then
    shasum -a 256 "$1" | awk '{print $1}'
  else
    echo "error: neither sha256sum nor shasum is installed" >&2
    return 69
  fi
}

mkdir -p "${OUTPUT_DIRECTORY}"
BUILD_DIRECTORY="$(mktemp -d)"
trap 'rm -rf "${BUILD_DIRECTORY}"' EXIT
ENCRYPTED_FILE="${BUILD_DIRECTORY}/roadrecon.db.age"

echo "Enter the course passphrase when prompted. It will not be saved by this script."
age --passphrase --output "${ENCRYPTED_FILE}" "${SOURCE_DATABASE}"

DATABASE_HASH="$(sha256_value "${SOURCE_DATABASE}")"
ENCRYPTED_HASH="$(sha256_value "${ENCRYPTED_FILE}")"
printf '%s  roadrecon.db\n' "${DATABASE_HASH}" > "${BUILD_DIRECTORY}/roadrecon.db.sha256"
printf '%s  roadrecon.db.age\n' "${ENCRYPTED_HASH}" > "${BUILD_DIRECTORY}/roadrecon.db.age.sha256"

mv "${BUILD_DIRECTORY}/roadrecon.db.age" "${OUTPUT_DIRECTORY}/roadrecon.db.age"
mv "${BUILD_DIRECTORY}/roadrecon.db.age.sha256" "${OUTPUT_DIRECTORY}/roadrecon.db.age.sha256"
mv "${BUILD_DIRECTORY}/roadrecon.db.sha256" "${OUTPUT_DIRECTORY}/roadrecon.db.sha256"

echo "Encrypted release assets are ready in ${OUTPUT_DIRECTORY}:"
echo "  roadrecon.db.age"
echo "  roadrecon.db.age.sha256"
echo "  roadrecon.db.sha256"
