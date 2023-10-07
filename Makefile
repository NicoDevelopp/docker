#---------NicoDevelopp Makefile---------------#
# Author: https://github.com/nicodevelopp
# License: MIT
#---------------------------------------------#

COMMAND_ARGS := $(subst :,\:,$(COMMAND_ARGS))

#---VARIABLES---------------------------------#
#---DOCKER---#
DOCKER = docker
DOCKER_RUN = $(DOCKER) run
DOCKER_COMPOSE = docker compose
PHP_CONT = $(DOCKER_COMPOSE) exec php
NODE_CONT = $(DOCKER_COMPOSE) exec node
SYMFONY_CONSOLE = ${PHP_CONT} php bin/console
#------------#

#---COMPOSER---#
COMPOSER = ${PHP_CONT} composer
COMPOSER_INSTALL = $(COMPOSER) install
COMPOSER_UPDATE = $(COMPOSER) update
#------------#

#---YARN---#
YARN = ${NODE_CONT} yarn
YARN_INSTALL = $(YARN) install --force
YARN_UPDATE = $(YARN) update
YARN_BUILD = $(YARN) build
YARN_WATCH = $(YARN) watch
#------------#

#---PHPUNIT-#
PHPUNIT = APP_ENV=test $(SYMFONY) php bin/phpunit
#------------#
#---------------------------------------------#

.DEFAULT_GOAL = help

## === 🆘  HELP ==========================================================================================
help: ## Montre cette aide
	@echo "NicoDevelopp Makefile"
	@echo "---------------------"
	@echo "Utilisation : make [commande]"
	@echo ""
	@echo "Commandes :"
	@grep -E '(^[a-zA-Z0-9_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}{printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'
#---------------------------------------------#

## === 🐋  DOCKER ========================================================================================
up: ## Lance vos conteneurs en mode détaché.
	@$(DOCKER_COMPOSE) up --detach
.PHONY: up

down: ## Arrête vos conteneurs.
	@$(DOCKER_COMPOSE) down --remove-orphans
.PHONY: down

sh: ## Se connecte à votre conteneur PHP.
	@$(PHP_CONT) sh
.PHONY: sh

test: ## Lance les tests avec PHPUnit.
	@$(eval c ?=)
	@$(DOCKER_COMP) exec -e APP_ENV=test php bin/phpunit $(c)
.PHONY: test

## === 🎛️  SYMFONY ========================================================================================
sf: ## Utilise la console Symfony.
	$(SYMFONY_CONSOLE) $(filter-out $@,$(MAKECMDGOALS))
.PHONY: sf

sf-cc: ## Supprime le cache de votre projet Symfony.
	$(SYMFONY_CONSOLE) cache:clear
.PHONY: sf-cc

sf-ddc: ## Crée la base de données si elle n'existe pas.
	$(SYMFONY_CONSOLE) doctrine:database:create --if-not-exists
.PHONY: sf-ddc

sf-ddd: ## Supprime la base de données si elle existe.
	$(SYMFONY_CONSOLE) doctrine:database:drop --if-exists --force
.PHONY: sf-ddd

sf-mm: ## Crée les requêtes SQL de migration de la base de données.
	$(SYMFONY_CONSOLE) make:migration
.PHONY: sf-mm

sf-dmm: ## Exécute la migration de la base de données.
	$(SYMFONY_CONSOLE) doctrine:migrations:migrate --no-interaction
.PHONY: sf-dmm

sf-fixtures: ## Charge les fixtures.
	$(SYMFONY_CONSOLE) doctrine:fixtures:load --no-interaction
.PHONY: sf-fixtures

sf-me: ## Crée une entité.
	$(SYMFONY_CONSOLE) make:entity
.PHONY: sf-me

sf-mc: ## Crée un controller.
	$(SYMFONY_CONSOLE) make:controller
.PHONY: sf-mc

sf-mf: ## Crée un formulaire.
	$(SYMFONY_CONSOLE) make:form
.PHONY: sf-mf

## === 📦  COMPOSER ======================================================================================
composer: ## Exécute composer
	$(COMPOSER) $(filter-out $@,$(MAKECMDGOALS))
.PHONY: composer

composer-install: ## Installe les dépendances PHP de votre projet.
	$(COMPOSER_INSTALL)
.PHONY: composer-install

composer-update: ## Met à jour les dépendances PHP de votre projet.
	$(COMPOSER_UPDATE)
.PHONY: composer-update

## === 📦  YARN ==========================================================================================
yarn-install: ## Installe les dépendances Javascript-CSS de votre projet.
	$(YARN_INSTALL)
.PHONY: yarn-install

yarn-update: ## Met à jour les dépendances Javascript-CSS de votre projet.
	$(YARN_UPDATE)
.PHONY: yarn-update

yarn-build: ## Construit les assets de votre projet.
	$(YARN_BUILD)
.PHONY: yarn-build

yarn-watch: ## Visualise vos assets.
	$(YARN_WATCH)
.PHONY: yarn-watch