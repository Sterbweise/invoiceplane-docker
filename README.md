# InvoicePlane Docker

## 🚀 Goal
Provision InvoicePlane inside Docker, expose it on port `8383`, and keep it ready for an external reverse proxy (for example Nginx Proxy Manager).

## 📁 Layout
- `docker-compose.yml`: orchestrates `mariadb`, `php-fpm`, and `nginx` services.
- `php/`: PHP Dockerfile, custom PHP configuration, and initialization scripts.
- `nginx/default.conf`: virtual host definition serving InvoicePlane through Nginx.
- `html/`: bind-mounted web root where the InvoicePlane sources will be extracted.

## ⚙️ Prerequisites
- Docker Desktop or Docker Engine with Docker Compose
- Host port `8383` available
- (Optional) External reverse proxy solution (Nginx Proxy Manager, Traefik, …)

## 🔧 Configuration
Copy `.env.example` to `.env` and adjust the values (or create a `docker-compose.override.yml` to keep secrets outside the repository):

```bash
cp .env.example .env
```

Key variables:
- `MYSQL_ROOT_PASSWORD`, `MYSQL_PASSWORD`: MariaDB credentials (required)
- `HOST_PORT`: host port mapped to the Nginx container
- `INVOICEPLANE_BASE_URL`: public URL used to populate `ipconfig.php`
- You can also duplicate `docker-compose.override.example.yml` to keep secrets out of version control

## ▶️ Start the stack
```bash
docker compose up -d --build
```
The PHP image is built with all required extensions, and an entry script creates `ipconfig.php` from the example file on the first boot.

## 📦 Install InvoicePlane
You can automate the installation steps with `scripts/setup-invoiceplane.sh`.

### Recommended: automated script
```bash
chmod +x scripts/setup-invoiceplane.sh
./scripts/setup-invoiceplane.sh
```
The script downloads InvoicePlane `v1.6.3`, extracts the `ip` folder, copies `ipconfig.php.example` to `ipconfig.php`, converts `env` to `.env`, and removes the PHP guard line that prevents dotenv parsing.

### Manual steps (if you prefer)
1. (Re)start the stack:
   ```bash
   docker compose up -d
   ```
2. Download and extract InvoicePlane:
   ```bash
   cd html
   wget https://www.invoiceplane.com/download/v1.6.3 -O invoiceplane.zip
   unzip invoiceplane.zip -d .
   rm invoiceplane.zip
   chown -R www-data:www-data .
   ```
3. Copy the configuration stub and adjust the base URL:
   ```bash
   mv ipconfig.php.example ipconfig.php
   ```
   Minimal example:
   ```php
   <?php
   return [
       'base_url' => 'http://localhost:8383',
   ];
   ```
4. Open `http://localhost:8383` in your browser to finish the web installer.

## 🔁 Firewall / Reverse Proxy
Expose container `nginx` on port `8383`, then configure your external reverse proxy (Nginx Proxy Manager, Traefik, …) to publish the site on the desired hostname.

## 🧹 Maintenance
- `docker compose down`: stop and remove the containers
- `docker compose down -v`: also remove named volumes (including the database)
- Back up the MariaDB volume `db_data` to preserve your data
