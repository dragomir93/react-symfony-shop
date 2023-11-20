#!/bin/bash

env=dev

docker container exec shop-php bin/console cache:clear --no-warmup -e "$env" --ansi
docker container exec shop-php composer dump-autoload --classmap-authoritative --ansi

if [ "$env" == "prod" ]; then
   docker container exec shop-php composer install --no-dev  --optimize-autoloader
else
   docker container exec shop-php composer install --optimize-autoloader
fi

docker container exec shop-php composer dump-autoload --classmap-authoritative --ansi
docker container exec shop-php bin/console doctrine:cache:clear-metadata -e "$env"
docker container exec shop-php bin/console doctrine:migrations:migrate --no-interaction --ansi -e "$env"
docker container exec shop-php bin/console cache:clear --no-warmup -e "$env" --ansi
docker container exec shop-php bin/console cache:warmup -e "$env"
docker container exec shop-php composer dump-env "$env"

cd client || exit
npm install
npm run hot