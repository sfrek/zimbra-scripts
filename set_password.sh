#!/bin/bash

source ./functions.sh

ACCOUNT=${1:-fefito@abadasoft.com}
OLDPASS=Pruebas2013.!
NEWPASS=Abada123.!


get_password ${ACCOUNT}
INITAL_PASSWORD=${PASSWORD}
echo -e "\033[01;32m${PASSWORD}\033[00m"

zmprov setPassword ${ACCOUNT} ${NEWPASS}
get_password ${ACCOUNT}
echo -e "\033[01;33m${PASSWORD}\033[00m"

NEW_PASSWORD=${PASSWORD}

echo "PASSWORD INICIAL: ${OLDPASS} ${INITAL_PASSWORD}"
echo "PASSWORD FINAL: ${NEWPASS} ${NEW_PASSWORD}"

# echo "despues de las prueba has de ejecutar: zmprov setPassword '${OLDPASS}'"
# zmprov setPassword ${ACCOUNT} ${OLDPASS}

zmprov --ldap modifyAccount ${ACCOUNT} userPassword ${INITAL_PASSWORD}
get_password ${ACCOUNT}
echo -e "\033[01;34m${PASSWORD}\033[00m"
