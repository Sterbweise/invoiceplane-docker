#!/usr/bin/env bash
set -euo pipefail

CONFIG_DIRECTORY="/var/www/html"
CONFIG_FILE="${CONFIG_DIRECTORY}/ipconfig.php"
EXAMPLE_FILE="${CONFIG_FILE}.example"

if [[ ! -d "${CONFIG_DIRECTORY}" ]]; then
  echo "InvoicePlane non monté, configuration ignorée."
  exit 0
fi

if [[ ! -f "${EXAMPLE_FILE}" ]]; then
  echo "Fichier d'exemple introuvable. InvoicePlane n'est sans doute pas encore installé."
  exit 0
fi

if [[ ! -f "${CONFIG_FILE}" ]]; then
  cp "${EXAMPLE_FILE}" "${CONFIG_FILE}"
fi

BASE_URL="${INVOICEPLANE_BASE_URL:-http://localhost:8383}"

if [[ -n "${BASE_URL}" ]]; then
  CONFIG_FILE="${CONFIG_FILE}" BASE_URL="${BASE_URL}" php -d detect_unicode=0 - <<'PHP'
<?php
$configFile = getenv('CONFIG_FILE');
$baseUrl = getenv('BASE_URL');

if ($configFile === false || $baseUrl === false) {
    exit(0);
}

if (!is_file($configFile)) {
    exit(0);
}

$config = include $configFile;
if (!is_array($config)) {
    $config = [];
}

$config['base_url'] = rtrim($baseUrl, '/');
$configExport = var_export($config, true);
file_put_contents($configFile, "<?php\nreturn {$configExport};\n");
PHP
fi

chown -R www-data:www-data "${CONFIG_DIRECTORY}"
