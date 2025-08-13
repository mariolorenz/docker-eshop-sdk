USERID = `id -u`
USERNAME = `id -un`
GROUPID = `id -g`
GROUPNAME = `id -gn`

default: help

help:
	@printf "\n\
	    \e[1;1;33mSome Help needed?\e[0m\n\n\
	    \e[1;1;32mmake setup\e[0m - Prefills the .env file with sync required parameters \n\
	        and prepares all modifiable custom files from dist. Run this \n\
	        once before everything!\n\n\
	    \e[1;1;32mmake addbasicservices\e[0m - Adds php, apache and mysql services \n\
	    \e[1;1;32mmake addngrokservice\e[0m - Adds ngrok and dnsmasq services \n\
	    \e[1;1;32mmake file=... addservice\e[0m - Prepend file contents to current docker-compose.yml file\n\n\
	    \e[1;1;32mmake install\e[0m - Install & Start all configured containers (have you run setup command already?)!\n\
	    \e[1;1;32mmake up\e[0m - Start all configured containers (have you run setup command already?)!\n\
	    \e[1;1;32mmake down\e[0m - Stop all configured containers\n\n\
	    \e[1;1;32mmake example\e[0m - Setup basic services + Runs example recipe\n\n\
	    \e[1;1;32mmake php\e[0m - Connect to php container shell\n\
	    \e[1;1;32mmake node\e[0m - Connect to node container shell\n\
	"

setup:
	@cat .env.dist | \
		sed "s/<userId>/$(USERID)/;\
		     s/<userName>/$(USERNAME)/;\
		     s/<groupId>/$(GROUPID)/;\
		     s/<groupName>/$(GROUPNAME)/"\
		> .env
	@cp -n containers/httpd/project.conf.dist containers/httpd/project.conf
	@cp -n containers/php/custom.ini.dist containers/php/custom.ini
	@cp -n docker-compose.yml.dist docker-compose.yml
	@printf "Setup done! Add basic services with \e[1;1;32mmake addbasicservices\e[0m and start everything \e[1;1;32mmake up\e[0m\n"

example:
	@make addbasicservices
	@./recipes/default/example/run.sh

build:
	docker compose up --build -d

up:
	docker compose up -d

down:
	docker compose down --remove-orphans

stop:
	docker compose stop

php:
	docker compose exec php bash

generate-docs:
	docker compose run --rm sphinx sphinx-build /home/$(USERNAME)/docs /home/$(USERNAME)/docs/build

node:
	docker compose run --rm node bash

ngrok:
	docker compose run --rm ngrok start workspace --config /etc/ngrok.yml

addservice:
	@cat $(file) >> docker-compose.yml
	@printf "\n" >> docker-compose.yml
	@printf "Service file $(file) contents added\n";

addbasicservices:
	@make file=services/apache.yml addservice
	@make file=services/php.yml addservice
	@make file=services/mailpit.yml addservice
	@make file=services/mysql.yml addservice
	@printf "php, apache and mysql related services added\n";

addngrokservice:
	@make file=services/ngrok.yml addservice
	@make file=services/caddy.yml addservice

cleanup:
	-make down
	-[ -d "source" ] && rm -rf source
	-[ -e ".env" ] && rm .env
	-[ -e "docker-compose.yml" ] && rm docker-compose.yml
	-[ -e "containers/httpd/project.conf" ] && rm containers/httpd/project.conf
	-[ -e "containers/php/custom.ini" ] && rm containers/php/custom.ini
	-[ -d "data/mysql" ] && rm -rf data/mysql/*
	-[ -d "data/composer/cache" ] && rm -rf data/composer/cache

mysqlimport:
	@if [ -z "$(filter-out $@,$(MAKECMDGOALS))" ]; then \
		echo "Usage: make mysqlimport /path/to/dump.sql (filename = target database name)"; \
		exit 1; \
	fi
	$(eval DUMP_FILE := $(filter-out $@,$(MAKECMDGOALS)))
	$(eval DB_NAME := $(basename $(notdir $(DUMP_FILE))))
	@echo "=== MySQL Import ==="
	@echo "File: $(DUMP_FILE)"
	@echo "Target Database: $(DB_NAME) (derived from filename)"
	@if [ ! -f "$(DUMP_FILE)" ]; then \
		echo "Error: File $(DUMP_FILE) not found"; \
		exit 1; \
	fi
	@echo "File size: $$(du -h $(DUMP_FILE) | cut -f1)"
	docker-compose exec -T mysql mysql -uroot -proot -v $(DB_NAME) < $(filter-out $@,$(MAKECMDGOALS));
	@echo "Import completed successfully"

mysql:
	docker-compose exec mysql mysql -uroot -proot

# Dummy target to avoid make errors
%:
	@true