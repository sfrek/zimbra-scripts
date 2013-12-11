#!/bin/bash
#
# Settings of account
# 	* ldif
#	* password
#	* lists
#	* Alias
#	* filters

source ./functions.sh

#
# __main__
#

if [ $# -lt 1 ];then
	echo -e "\033[01;31mError\033[00m falta el usuario"
	usage
	exit 1
fi

ACCOUNT=${1}

if ! exist_account ${ACCOUNT};then
	echo -e "${ACCOUNT} \033[01;31mNo Existe\033[00m"
	exit 2
fi

USER=${ACCOUNT%%@*}
DOMAIN=${ACCOUNT##*@}
WORK_DIR="./accounts/${DOMAIN}/${USER}"

[[ ! -d ${WORK_DIR} ]] && mkdir -p ${WORK_DIR}

zmprov getAccount ${ACCOUNT} | tee ${WORK_DIR}/${USER}.ldif

get_password ${ACCOUNT} | tee ${WORK_DIR}/password
echo -e "${ROJO}Password ${PASSWORD} ${NOCO}"

echo -e "${VERDE}Listas en las que esta ${ACCOUNT} ${NOCO}"
get_userlist ${ACCOUNT} | tee ${WORK_DIR}/listas.list
echo

echo -e "${AZUL}Alias de ${ACCOUNT} ${NOCO}"
get_useralias ${ACCOUNT} | tee ${WORK_DIR}/alias.list
echo

echo -e "${AMARILLO}filtros de ${ACCOUNT} ${NOCO}"
get_filters ${ACCOUNT} | tee ${WORK_DIR}/filtros.list
echo


