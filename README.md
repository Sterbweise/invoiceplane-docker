# InvoicePlane Docker

## 🚀 Objectif
Déployer InvoicePlane dans un environnement Docker prêt à l’emploi et exposé sur le port `8383`, afin de pouvoir l’intégrer derrière un reverse-proxy externe (ex : Nginx Proxy Manager).

## 📁 Structure
- `docker-compose.yml` : orchestre les services `mariadb`, `php-fpm` et `nginx`.
- `php/` : Dockerfile PHP, configuration personnalisée et script d’initialisation.
- `nginx/default.conf` : configuration vhost pour servir InvoicePlane.
- `html/` : répertoire partagé où sera décompressé InvoicePlane.

## ⚙️ Pré-requis
- Docker Desktop ou Docker Engine + Docker Compose
- Port `8383` libre sur l’hôte
- (Optionnel) Outil de reverse-proxy externe (ex. Nginx Proxy Manager)

## 🔧 Configuration
Copiez `.env.example` en `.env` puis ajustez les mots de passe et paramètres si besoin :

```bash
cp .env.example .env
```

Variables clés :
- `MYSQL_ROOT_PASSWORD`, `MYSQL_USER`, `MYSQL_PASSWORD` : mots de passe MariaDB
- `HOST_PORT` : port d’écoute exposé par Nginx
- `INVOICEPLANE_BASE_URL` : URL publique (utilisée pour générer `ipconfig.php` automatiquement)

## ▶️ Démarrer l’environnement
```bash
docker compose up -d --build
```
Le build va préparer PHP avec toutes les dépendances et enregistrer un script d’initialisation qui, au premier démarrage, crée `ipconfig.php` à partir de l’exemple si le fichier n’existe pas encore.

## 📦 Installer InvoicePlane
Vous pouvez automatiser les étapes ci-dessous avec le script `scripts/setup-invoiceplane.sh`.

### Script d’installation (recommandé)
```bash
chmod +x scripts/setup-invoiceplane.sh
./scripts/setup-invoiceplane.sh
```

### Étapes manuelles équivalentes
1. Arrêtez la stack si elle tourne déjà, puis redémarrez les conteneurs :
   ```bash
   docker compose up -d
   ```
2. Téléchargez et décompressez InvoicePlane :
   ```bash
   cd html
   wget https://www.invoiceplane.com/download/v1.6.1 -O invoiceplane.zip
   unzip invoiceplane.zip -d .
   rm invoiceplane.zip
   chown -R www-data:www-data .
   ```
3. Copiez le fichier de configuration et appliquez la base URL :
   ```bash
   mv ipconfig.php.example ipconfig.php
   ```
   Exemple de configuration minimale :
   ```php
   <?php
   return [
       'base_url' => 'http://localhost:8383',
   ];
   ```
4. Accédez à `http://localhost:8383` depuis votre navigateur pour finaliser l’installation.

## 🔁 Pare-feu / Reverse Proxy
Exposez le service `nginx` sur le port `8383` et configurez votre reverse-proxy externe (Nginx Proxy Manager, Traefik, …) pour servir le site sur le domaine/public souhaité.

## 🧹 Maintenance
- `docker compose down` : arrête et supprime les conteneurs
- `docker compose down -v` : supprime également les volumes (incluant la base de données)
- Sauvegardez le volume MariaDB `db_data` pour sécuriser vos données.
