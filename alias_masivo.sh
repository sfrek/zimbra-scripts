#!/bin/bash
#
# Generacion masiva de alias en un dominio
# uso:
#	alias_masivo.sh <dominio principal> <dominio alias>
#
# workflouw:
#	Existe dominio principal
#		si: continuamos
#		no: Error y salimos
#		
#		Existe dominio alias
#			si: continuamos
#			no: Error y salimos
#
#			Existe <uid>@<domino alias> ? 
#				si: Break
#				no: Crear
#
# Aclaraciones
#	zmprov getAccount <uid>@<dominio> trata igual a las "cuentas" y a los "alias"

#
# Funciones
#

function usage(){
	cat << __EOF__
Uso:
alias_masivo.sh <dominio principal> <dominio alias>

Comentarios:
	dominio principal: Este es el dominio de las cuentas de correo
	dominio alias: Este es el dominio del que se crearan los alias en las cuentas del dominio principal
__EOF__
}

function exist_domain(){
	local DOMAIN=${1}
	zmprov getDomain ${DOMAIN} 2>&- >&-
	return $?
}

function exist_account(){
	local ACCOUNT=${1}
	zmprov getAccount ${ACCOUNT} 2>&- >&-
	return $?
}

#
# __main__
#

if (( $# < 2 ));then
	echo -e "\033[01;31mError:\033[00m Faltan parametros"
	usage
	exit 1
fi

LOG=/opt/zimbra/scripts/logs/log_${0%%*.}.log
DOMAIN=${1}
ALIAS_DOMAIN=${2}


echo "[$(date +%D\ %X)] ---- INICIO $0 ----" >> ${LOG}
if exist_domain ${DOMAIN} && exist_domain ${ALIAS_DOMAIN};then
	echo "[$(date +%D\ %X)] Existen los dominios ${DOMAIN} y ${ALIAS_DOMAIN}" >> ${LOG}

	for ACCOUNT in $(zmprov --ldap getAllAccounts ${DOMAIN});do
		ALIAS=${ACCOUNT%%@*}@${ALIAS_DOMAIN}
		echo -e "\tcomprobando alias \033[01;34m${ALIAS}\033[00m de \033[01;32m${ACCOUNT}\033[00m"
		if exist_account ${ALIAS};then
			echo -e "\t\t${ALIAS} \033[01;32mExiste\033[00m"
			echo "${ALIAS} Existe" >> ${LOG}
		else
			echo -e "\t\t${ALIAS} \033[01;31mNo existe\033[00m, lo creamos"
			zmprov addAccountAlias ${ACCOUNT} ${ALIAS}
			echo "${ALIAS} No existe, creado" >> ${LOG}
		fi

	done
			
else
	echo "[$(date +%D\ %X)] NO existen los dominios ${DOMAIN} y ${ALIAS_DOMAIN}" >> ${LOG}

	echo -e "\033[01;31mError:\033[00m Alguno de los dominios no existe"
	usage
	exit 2

fi
echo "[$(date +%D\ %X)] ---- FIN $0 ----" >> ${LOG}

#exist_account figarcia@abadasoft.com && echo HOLA || echo KK
#
#
#exist_account fefito@abadasoft.com && echo HOLA || echo KK
#
#if $(exist_account figarcia@abadasoft.com) 
#then
#	echo "account exist, nothing to do"
#else
#	echo "account don't exist, creating alias"
#fi
#
#if $(exist_account fefito@abadasoft.com) 
#then
#	echo "account exist, nothing to do"
#else
#	echo "account don't exist, creating alias"
#fi


