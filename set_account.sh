#!/bin/bash
#
# remake_account: 
#
source ./functions.sh

GRIS="\033[01;30m"
ROJO="\033[01;31m"
VERDE="\033[01;32m"
AMARILLO="\033[01;33m"
AZUL="\033[01;34m"
MORADO="\033[01;35m"
BLANCO="\033[01;36m"
CIAN="\033[01;37m"
NO04="\033[35;30m"
NO05="\033[36;31m"
NO07="\033[37;32m"
NO08="\033[38;33m"
NOCO="\033[00m"

function usage(){
	local ACCOUNT="<cuenta dec correo>"
	cat << __EOF__
Uso:
	remake_account <cuenta de correo>

Proposito:
	Importar usuario en zimbra.
__EOF__
}

#
# __main__
#
# TODO: Comprobar que usuario y directorio ...

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
TEMP_ACCOUNT=${USER}TEMP@${DOMAIN}
WORK_DIR=/tmp/remake_account/${ACCOUNT}
# rm -rf ${WORK_DIR} 2>&- >&-
# mkdir -p ${WORK_DIR}

zmprov getAccount ${ACCOUNT} > ${WORK_DIR}/account.get

echo -e "${BLANCO}crear ${ACCOUNT} ${NOCO}"
create_account ${ACCOUNT} ${PASSWORD}
echo

echo -e "${NO04}meter alias a ${ACCOUNT} ${NOCO}"
set_aliases ${ACCOUNT} ${WORK_DIR}/alias.list
echo

echo -e "${NO05}insertar en listas a ${ACCOUNT} ${NOCO}"
set_userlists ${ACCOUNT} ${WORK_DIR}/listas.list 
echo

echo -e "${GRIS}poner filtros a ${ACCOUNT} ${NOCO}"
set_filters ${ACCOUNT} ${WORK_DIR}/filtros.list
echo

echo -e "${NO08}importo buzon de ${TGZ} a ${ACCOUNT} ${NOCO}"
descomprime_buzon ${ACCOUNT} ${TGZ}
