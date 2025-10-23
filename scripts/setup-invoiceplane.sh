#!/usr/bin/env bash
set -euo pipefail

INVOICEPLANE_VERSION="${INVOICEPLANE_VERSION:-v1.6.1}"
INVOICEPLANE_URL="https://www.invoiceplane.com/download/${INVOICEPLANE_VERSION}"
HTML_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)/html"

if [[ ! -d "${HTML_DIR}" ]]; then
  echo "Répertoire html introuvable: ${HTML_DIR}" >&2
  exit 1
fi

cd "${HTML_DIR}"

if [[ -d invoice || -f ipconfig.php || -f ipconfig.php.example ]]; then
  echo "Il semble qu'InvoicePlane soit déjà présent dans ${HTML_DIR}." >&2
  echo "Abandon pour éviter d'écraser des données." >&2
  exit 0
fi

TMP_DIR="$(mktemp -d)"

echo "Téléchargement de InvoicePlane (${INVOICEPLANE_VERSION})..."
wget "${INVOICEPLANE_URL}" -O "${TMP_DIR}/invoiceplane.zip"

echo "Décompression..."
unzip "${TMP_DIR}/invoiceplane.zip" -d "${TMP_DIR}"

MOVE_SOURCE="$(find "${TMP_DIR}" -maxdepth 1 -type d -name 'invoiceplane' -o -name 'InvoicePlane' | head -n 1)"
if [[ -z "${MOVE_SOURCE}" ]]; then
  echo "Impossible de localiser le dossier InvoicePlane dans l'archive." >&2
  exit 1
fi

shopt -s dotglob
mv "${MOVE_SOURCE}"/* "${HTML_DIR}/"
shopt -u dotglob

rm -rf "${TMP_DIR}"

if [[ -f "ipconfig.php.example" ]]; then
  cp "ipconfig.php.example" "ipconfig.php"
fi

chown -R 33:33 "${HTML_DIR}"

cat <<'INFO'
Installation terminée.
Pensez à configurer INVOICEPLANE_BASE_URL dans votre fichier .env avant de relancer les conteneurs.
INFO
