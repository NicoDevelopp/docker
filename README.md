# Docker

Ce projet contient la documentation pour installer Docker sous Windows, l'ensemble des dockerfiles et scripts utilisés pour les développements Symfony.

---

Environnement Windows / Docker

## Installation Sous Système Linux

### WSL 2

```
wsl --set-default-version 2
```

### Distribution

```
wsl --install -d Ubuntu-22.04
```

### Vérifier que votre distribution est sous wsl 2

```
wsl -l -v
```

### Création du compte Linux

Saisissez votre nom de compte et mot de passe 2 fois

![image](https://github.com/NicoDevelopp/docker/assets/48688436/124bae85-9850-47c2-b096-c9c25eddf0a3)

### Répertoire de votre distribution

Votre distribution est accessible via l'explorateur directement

![image](https://github.com/NicoDevelopp/docker/assets/48688436/c255d033-38d8-4d24-b720-65fdc838cb1b)

## Installation de Docker

Une fois WSL 2 installé, il est nécessaire d’installer Docker dans une distribution Linux WSL. L’installation de Docker dans WSL est assez classique. Voici la procédure pour Ubuntu WSL et donc à exécuter dans la distribution Ubuntu :

### Récupération du script sur le serveur de Docker

```
curl -fsSL https://get.docker.com -o get-docker.sh
```

### Exécution du script d'installation

```
sudo sh get-docker.sh
```

### Ajouter votre utilisateur au groupe Docker

```
sudo usermod -aG docker $USER
```

### Vérifier que Docker a été bien installé

```
docker --version
```

```
docker compose version
```

# Installation d'un environnement pour Symfony

Vous pouvez créer un environnement Symfony en suivant ce [lien](./doc/installation.md)
