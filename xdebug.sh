#!/bin/bash
XDEBUG_CONFIG_FILE=./containers/php/xdebug.ini

RED='\033[0;31m'
GREEN='\033[0;32m'
NO_COLOR='\033[0m'

if [[ -z "$1" ]]
then
    echo "usage: xdebug on|off"
else
    if [[ "$1" == "on" ]]; then
        echo -e "turning xdebug ${GREEN}on${NO_COLOR}"
        sed -i 's/;*zend/zend/g' $XDEBUG_CONFIG_FILE
    else
        echo -e "turning xdebug ${RED}off${NO_COLOR}"
        sed -i 's/;*zend/;zend/g' $XDEBUG_CONFIG_FILE
    fi
    docker compose restart php
fi