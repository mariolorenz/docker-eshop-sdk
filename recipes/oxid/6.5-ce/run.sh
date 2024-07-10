#!/bin/bash

SCRIPT_PATH=$(dirname ${BASH_SOURCE[0]})

cd $SCRIPT_PATH/../../../ || exit

# Prepare services configuration
make setup
make addbasicservices
make file=services/adminer.yml addservice

# Configure containers
#perl -pi\
#  -e 's#error_reporting = .*#error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT & ~E_WARNING#g;'\
#  containers/php/custom.ini

perl -pi\
  -e 's#/var/www/#/var/www/source/#g;'\
  containers/httpd/project.conf

# prepare shop
mkdir source

docker compose up --build -d php
docker compose run php composer create-project oxid-esales/oxideshop-project . dev-b-6.5-ce

make down

make up

# setup shop
docker compose exec -T php vendor/bin/oe-console oe:setup:shop --db-host=mysql --db-port=3306 --db-name=example --db-user=root \
  --db-password=root --shop-url=http://localhost.local/ --shop-directory=/var/www/source/ \
  --compile-directory=/var/www/source/tmp/

docker compose exec -T php vendor/bin/oe-console oe:theme:activate apex

docker compose exec -T php vendor/bin/oe-console oe:admin:create --admin-email=noreply@oxid-esales.com --admin-password=admin

echo "Done!"
