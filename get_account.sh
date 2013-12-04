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
	get_account <cuenta de correo>

Proposito:
	Obtener todos los datos y el buzon del usuario.
	2 Export el buzon de ${ACCOUNT}.
	3 Filtros de ${ACCOUNT}.
	4 Alias a ${ACCOUNT}
	5 Comprobación de listas y alias d ${ACCOUNT}
__EOF__
}

#
# __main__
#
# TODO:
#	temporal word directory.
#	checks

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

if [ -z ${DOMAIN} -o ${USER} = ${DOMAIN} ];then
	echo -e "${ROJO}Error${NOCO}: Falta el dominio"
	exit 3
fi

WORK_DIR=/tmp/remake_account/${ACCOUNT}
rm -rf ${WORK_DIR} 2>&- >&-
mkdir -p ${WORK_DIR}

zmprov getAccount ${ACCOUNT} > ${WORK_DIR}/account.get

get_password ${ACCOUNT}
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

TGZ=${WORK_DIR}/${ACCOUNT%%@*}.tgz
echo -e "${N007}exporto buzon de ${ACCOUNT} en ${TGZ}${NOCO}"
comprime_buzon ${ACCOUNT} ${TGZ}
