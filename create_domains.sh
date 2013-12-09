#!/bin/bash
#
# script for creata domains and accounts
#	


source ./functions.sh

function create_users(){
	local USERLIST="$@"
	#
	# if USERLIST is not a file, we convert it
	if [ ! -f "${USERLIST}" ]
	then
		echo "transform '${USERLIST}' into a file"
		echo "${USERLIST}" > /tmp/userlist.list
		USERLIST="/tmp/userlist.list"
	fi
	for ACCOUNT in $(cat ${USERLIST})
	do
		echo -e "${AZUL}${ACCOUNT}${NOCO}:"
		if ! exist_account ${ACCOUNT}
		then
			echo -e "\tCreamos ${AZUL}${ACCOUNT}${NOCO}"
			create_account ${ACCOUNT}
		else
			echo -e "\tExiste"
		fi
	done
}


[[ ! -d ./domains ]] && echo -e "${ROJO}ERROR${NOCO}: Domains' directory not found" && exit 1

for DOMAIN in $(ls ./domains/)
do
	echo -e "${VERDE}${DOMAIN}${NOCO}:"
	if ! exist_domain ${DOMAIN}
	then
		echo -e "\tCreamos el Dominio"
		zmprov createDomain ${DOMAIN}
	fi
	create_users "./domains/${DOMAIN}"
done

