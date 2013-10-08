#!/bin/bash
#
# Generacion masiva de alias en un dominio
# uso:
#	alias_masivo.sh <dominio principal> <dominio alias>
#
# workflouw:
#	Existe <uid>@<domino alias> ? 
#		si: Break
#		no: Crear
#
# Aclaraciones
#	zmprov getAccount <uid>@<dominio> trata igual a las "cuentas" y a los "alias"



function exist_account(){
	ACCOUNT=${1}
	zmprov getAccount ${ACCOUNT} >&-
	return $?
}

exist_account figarcia@abadasoft.com && echo HOLA || echo KK


exist_account fefito@abadasoft.com && echo HOLA || echo KK

if $(exist_account figarcia@abadasoft.com) 
then
	echo "account exist, nothing to do"
else
	echo "account don't exist, creating alias"
fi

if $(exist_account fefito@abadasoft.com) 
then
	echo "account exist, nothing to do"
else
	echo "account don't exist, creating alias"
fi



DOMAIN=${1}
ALIAS_DOMAIN=${2}


