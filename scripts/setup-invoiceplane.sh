#!/usr/bin/env bash
set -euo pipefail

INVOICEPLANE_VERSION="${INVOICEPLANE_VERSION:-v1.6.3}"
INVOICEPLANE_URL="https://www.invoiceplane.com/download/${INVOICEPLANE_VERSION}"
HTML_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)/html"

if [[ ! -d "${HTML_DIR}" ]]; then
  echo "html directory not found: ${HTML_DIR}" >&2
  exit 1
fi

cd "${HTML_DIR}"

if [[ -d ip || -f ipconfig.php || -f ipconfig.php.example ]]; then
  echo "InvoicePlane already appears to be present in ${HTML_DIR}." >&2
  echo "Aborting to avoid overwriting existing data." >&2
  exit 0
fi

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

echo "Downloading InvoicePlane (${INVOICEPLANE_VERSION})..."
wget "${INVOICEPLANE_URL}" -O "${TMP_DIR}/invoiceplane.zip"

echo "Extracting archive..."
unzip "${TMP_DIR}/invoiceplane.zip" -d "${TMP_DIR}" >/dev/null

MOVE_SOURCE="$(find "${TMP_DIR}" -maxdepth 1 -type d \( -name 'ip' -o -name 'invoiceplane' -o -name 'InvoicePlane' \) | head -n 1)"
if [[ -z "${MOVE_SOURCE}" ]]; then
  echo "Unable to locate the 'ip' directory inside the archive." >&2
  exit 1
fi

shopt -s dotglob nullglob
mv "${MOVE_SOURCE}"/* "${HTML_DIR}/"
shopt -u dotglob nullglob

rm -rf "${TMP_DIR}"
trap - EXIT

if [[ -f "ipconfig.php.example" && ! -f "ipconfig.php" ]]; then
  cp "ipconfig.php.example" "ipconfig.php"
fi

chown -R 33:33 "${HTML_DIR}"

echo "InvoicePlane files have been installed into ${HTML_DIR}."
echo "Remember to set INVOICEPLANE_BASE_URL in your .env file before restarting the containers."
