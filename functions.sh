#
# Biblioteca de funciones
#

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

function get_password(){
	local ACCOUNT=${1}
	PASSWORD=$(zmprov --ldap getAccount ${ACCOUNT} | grep userPassword | cut -f2 -d' ')
}

function set_password(){
	local ACCOUNT=${1}
	local PASSWORD=${2}
	echo "'${PASSWORD}'" | xargs zmprov --ldap modifyAccount ${ACCOUNT} userPassword
}

function get_displayname(){
	local ACCOUNT=${1}
	DISPLAY_NAME=$(zmprov getAccount ${ACCOUNT} | grep -i displayName | awk -F': ' '{print $2}')
}

function set_displayname(){
	local ACCOUNT=${1}
	local DISPLAY_NAME="${2}"
	echo "'${2}'" | xargs zmprov --ldap modifyAccount displayName
}

# Listas a las que pertenece el usuario:
#	Desde el punto de vista de la cuenta del domino.
# 
# Aclaracion:
#	Con getAccountMembership salen todas las listas a las que pertenece el
#	usario, incluidas en las que estáde manera indirecta, de ahíel grep -v
function get_userlist(){
	local ACCOUNT=${1}
	zmprov getAccountMembership ${ACCOUNT} | grep -v via
}

function get_useralias(){
	local ACCOUNT=${1}
	zmprov getAccount ${ACCOUNT} | grep zimbraMailAlias | awk '{print $2}'
}

function get_filters(){
	local ACCOUNT=${1}
	zmmailbox -z -m ${ACCOUNT} gfrl
}

function rename_account(){
	local ACCOUNT=${1}
	local NEW_ACCOUNT=${2}
	zmprov renameAccount ${ACCOUNT} ${NEW_ACCOUNT}
	return $?
}

function create_account(){
	local ACCOUNT=${1}
	local PASSWORD=${2:-Abada123.}
	zmprov createAccount ${ACCOUNT} ${PASSWORD}
	return $?
}

function remove_account_alias(){
	local ACCOUNT=${1}
	for ALIAS in $(get_useralias ${ACCOUNT});do
		zmprov removeAccountAlias ${ACCOUNT} ${ALIAS}
	done
}

function set_aliases(){
	local ACCOUNT=${1}
	local ALIASES_FILE=${2}
	for ALIAS in $(cat ${ALIASES_FILE});do
		zmprov addAccountAlias ${ACCOUNT} ${ALIAS}
		echo -e "\t\tAlias ${ALIAS} to ${ACCOUNT}"
	done
}

function set_userlists(){
	local ACCOUNT=${1}
	local LISTS_FILE=${2}
	for LIST in $(cat ${LISTS_FILE});do
		zmprov addDistributionListMember ${LIST} ${ACCOUNT}
		echo -e "\t\tadd ${ACCOUNT} to ${LIST}"
	done
}


function set_filters(){
	local ACCOUNT=${1}
	local FILTERS_FILE=${2}
	oldIFS=${IFS}
	IFS=$'\n'
	for FILTER in $(cat ${FILTERS_FILE})
	do
		# echo ${FILTER}
		echo ${FILTER} | xargs zmmailbox -z -m ${ACCOUNT} addFilterRule --last
	done
	IFS=${oldIFS}
}

function comprime_buzon(){
	local ACCOUNT=${1}
	local TGZ=${2}
	zmmailbox -z -m ${ACCOUNT} getRestURL "//?fmt=tgz" > ${TGZ}
	return $?
}

function descomprime_buzon(){
	local ACCOUNT=${1}
	local TGZ=${2}
	zmmailbox -z -m ${ACCOUNT} postRestURL "//?fmt=tgz" ${TGZ}
	return $?
}

function delete_account(){
	local ACCOUNT=${1}
	zmprov deleteAccount ${ACCOUNT}
	return $?
}
