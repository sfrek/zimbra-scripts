#!/bin/bash
#
#
source ./functions.sh

# __main__

DDIR=./domains
[[ ! -d ${DDIR} ]] && mkdir -p ${DDIR}

for DOMAIN in $(zmprov gad)
do
	echo -e "Dominio: ${AZUL}${DOMAIN}${NOCO}"
	[[ -f ${DDIR}/${DOMAIN} ]] && rm ${DDIR}/${DOMAIN}
	for ACCOUNT in $(zmprov --ldap gaa ${DOMAIN})
	do
		echo -e "\t${MORADO}${ACCOUNT}${NOCO} en ${AZUL}${DOMAIN}${NOCO}"
		echo ${ACCOUNT} >> ${DDIR}/${DOMAIN}
	done
done
