PHONY :=
.DEFAULT_GOAL := help
SHELL := /bin/bash

OS := $(shell uname -s)

help:
	@grep -E '(^[a-zA-Z0-9_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}{printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'

##Welcome to shop Project to get you started type 'make help'

##
##Docker Commands
##

PHONY += up
up:			## Launch project
up:
	$(call colorecho, "\nStarting project on $(OS)")
	@docker compose -f docker-compose.yml -f docker-compose.yml up -d

PHONY += production
production:			## Launch Production project
production:
	$(call colorecho, "\nStarting project on $(OS)")
	@docker compose -f docker-compose.yml -f docker-compose.yml up --build -d

PHONY += down
down: 			## Tear down project
	$(call colorecho, "\nTear down project docker\n\n- Stoping all containers...\n")
	@docker compose down

PHONY += recreate
recreate: 			## Recreate docker containers
	$(call colorecho, "Recreate docker containers...\n")
	@docker compose -f docker-compose.yml -f docker-compose.yml up -d --build --force-recreate --remove-orphans

PHONY += restart
restart:		## Restart Docker
restart: down up logs

PHONY += ps
ps:			## Docker containers process status
ps:
	$(call colorecho, "\nDocker containers process status $(OS)")
	@docker compose ps

PHONY += messenger
messenger:		## Run symfony messenger async worker
	@docker exec shop-php bin/console messenger:consume async -vvv

##
##SSH (Docker)
##

PHONY += ssh
ssh-api:		## SSH to API container
ssh-api:
	$(call colorecho, "\nSSH to API container (shop-php docker image):\n")
	@docker exec -it shop-php /bin/sh

##
##Logs
##

PHONY += logs
logs:			## View Logs from Docker
logs:
	@docker compose logs -f

PHONY += appl
appl:			## View Application Logs from Docker
appl:
	@docker exec -it shop-php tail -f /srv/api/var/log/dev.log

PHONY += mail
mail:			## View email on local
mail:
	@xdg-open http://localhost:8025/

##
##API Database commands
##

PHONY += migration
migration:	## Create Migration files
migration:
	$(call colorecho, "\nCreating Database Migration:\n")
	@docker exec shop-php bin/console doctrine:cache:clear-metadata
	@docker exec shop-php bin/console make:migration

PHONY += migrate
migrate:		## Migrate database
migrate:
	$(call colorecho, "\nMigrating Project Database\n")
	@docker exec shop-php bin/console doctrine:migrations:migrate --no-interaction

##
##Cache commands
##

PHONY += clear
clear:	## Clear API (Symfony) cache command
	$(call colorecho, "\nClearing Cache\n")
	@docker exec shop-php rm -rf var/cache
	@docker exec shop-php bin/console doctrine:cache:clear-metadata
	@docker exec shop-php composer dump-autoload --optimize --classmap-authoritative --ansi
	@docker exec shop-php php bin/console cache:warmup

##
##Composer commands
##

PHONY += composer-install
composer-install:	## Instaling Composer libraries command
	$(call colorecho, "\nInstaling Composer libraries\n")
	@docker exec shop-php composer install


##
##Coding standars commands
##

PHONY += cs-fix
cs-fix:			## Fixing coding standards
	$(call colorecho, "\nFixing coding standards\n")
	@docker exec -it shop-php vendor/bin/phpcbf src

PHONY += cs
cs:			## Checking coding standards
	$(call colorecho, "Checking coding standards\n")
	@docker exec -it shop-php vendor/bin/phpcs src

PHONY += check
check:	## Run all checks
	$(call colorecho, "Checking coding standards\n")
	@docker exec -it shop-php vendor/bin/phpcs src
	$(call colorecho, "\nMess detector check\n")
	@docker exec  shop-php vendor/bin/phpmd src ansi phpmd-ruleset.xml
	$(call colorecho, "\nPHP standards check\n")
	@docker exec shop-php vendor/bin/phpstan analyse -c phpstan.neon -l 8 src

PHONY += mess
mess:			## Mess detector check
	$(call colorecho, "\nMess detector check\n")
	@docker exec  shop-php vendor/bin/phpmd src ansi phpmd-ruleset.xml

PHONY += phpstan
phpstan:		## Run phpstan with custom configuration
	@docker exec shop-php vendor/bin/phpstan analyse -c phpstan.neon -l 8 src

##
##Tests
##

PHONY += unit
unit:		## Run phpunit tests
	@docker exec shop-php vendor/bin/simple-phpunit tests

##
##Debug
##

PHONY += xon
xon:			## Enable XDebuger on PHP container
xon:
	@docker exec shop-php chmod 666 /var/log/xdebug.log
	@docker exec shop-php mv /usr/local/docker-php-ext-xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
	@docker exec shop-php kill -USR2 1
	$(call colorecho, "\nxdebuger is ON\n")

PHONY += xoff
xoff:			## Disable XDebuger on PHP container
xoff:
	@docker exec shop-php mv /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini /usr/local/docker-php-ext-xdebug.ini
	@docker exec shop-php kill -USR2 1
	$(call colorecho, "\nxdebuger is switched OFF\n")

define colorecho
	@tput -T xterm setaf 3
	@shopt -s xpg_echo && echo $1
	@tput -T xterm sgr0
endef
