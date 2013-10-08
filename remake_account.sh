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
	Creado para eliminar los duplicados, realiza:

	1 Obtenemos cuenta objetivo
		1.1 Obtenemos password "zmprov --ldap getAccount ${ACCOUNT} | grep userPassword"
		1.2 Renombramos ${ACCOUNT} a ${ACCOUNT}temp
		1.3 Creamos nueva ${ACCOUNT} y le metemos la ${PASS} con el "zmprov --ldap modifyAccount ${ACCOUNT} userPassword ${CORRO_PASS}"
		1.3.1 --- ¿ Por qué así y no al revés ?, por que así nos aseguramos de que todos los correos que entren en ${ACCOUNT} durante el proceso de export/import no se pierden, y hacemos un export de un buzón estanco.

	Y en paralelo..

	2 Export el buz�n de ${ACCOUNT}temp e import en ${ACCOUNT}
	3 Filtros de ${ACCOUNT}temp a ${ACCOUNT}
	4 Eliminar alias de temp y asignar alias a ${ACCOUNT}
	5 Comprobación de listas y alias de {ACCOUNT
__EOF__
}

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
TEMP_ACCOUNT=${USER}TEMP@${DOMAIN}
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

echo -e "${MORADO}renombrar de ${ACCOUNT} a ${TEMP_ACCOUNT} ${NOCO}"
rename_account ${ACCOUNT} ${TEMP_ACCOUNT}
echo

echo -e "${CIAN}eliminar alias de ${TEMP_ACCOUNT} ${NOCO}"
remove_account_alias ${TEMP_ACCOUNT}
echo

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

TGZ=${WORK_DIR}/${TEMP_ACCOUNT%%@*}.tgz
echo -e "${N007}exporto buzon de ${TEMP_ACCOUNT} en ${TGZ} ${NOCO}"
comprime_buzon ${TEMP_ACCOUNT} ${TGZ}

echo -e "${NO08}importo buzon de ${TGZ} a ${ACCOUNT} ${NOCO}"
descomprime_buzon ${ACCOUNT} ${TGZ}

echo -e "\033[37;41mBorrar cuenta ${TEMP_ACCOUNT} ${NOCO}"
delete_account ${TEMP_ACCOUNT}
