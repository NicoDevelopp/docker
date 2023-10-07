# Environnement avec Symfony

Cette option installera :

- PHP
- Apache
- MariaDB
- Mailpit
- PHPMyAdmin
- NodeJS
- Symfony

## Configuration du projet

![choix](images/installateur-conf-projet.png)

Le nom du projet doit être sans caractères spécials, sans espace et en minuscule.

Le dossier de destination doit exister.

Le dossier destination contiendra un dossier avec le nom du projet. Votre projet sera dans ce répertoire.

## Configuration de la base de données

![db](images/installateur-conf-db.png)

La base de données est MariaDB.

## Configuration de Symfony

![symfony](images/installateur-conf-symfony.png)

Vous avez le choix de 3 versions

## Configuration de PHP

![php](images/installateur-conf-php.png)

Vous avez le choix de 2 ou 3 versions en fonction de votre configuration de Symfony

## Configuration de Node

![node](images/installateur-conf-node.png)

Vous avez le choix de 2 versions

## Configuration du réseau

![reseau](images/installateur-conf-reseau.png)

La configuration des ports de votre hôte pour accéder à vos conteneurs

---

- Les images seront créés et téléchargés
- containers seront lancés automatiquement (docker compose up -d)

![fini](images/installateur-fini.png)

## Vérification des conteneurs lancés

- `docker ps --format '{{.Names}}'`
- Vous devriez avoir 6 conteneurs préfixés par le nom de projet choisi.

## Répertoire d'installation

Le répertoire d'installation est `le répertoire de destination` + `nom du projet`.

Le répertoire de destination par défaut : `répertoire home de votre utisateur\dev`
Le nom du projet par défaut : `app`

Dans votre répertoire d'installation, vous devriez avoir Symfony d'installer avec votre environnement Docker.

---

## Conteneur PHP

Se connecter dans le conteneur PHP :
`docker compose exec php sh`

![conteneur](images/conteneur-php.png)

Un petit smiley de baleine vous permettra de savoir si vous êtes dans le conteneur.

### Accès aux sites :

- Votre projet Symfony : http://localhost:8080
- PHPMyadmin : http://localhost:9080
- Mailpit : http://localhost:8025

Les ports seront ceux que vous aurez choisis. Ils sont présents dans votre `.env.docker`.
