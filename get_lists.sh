#!/bin/bash
#
#
source ./functions.sh

# __main__

LISTDIR="./lists"
[[ ! -d ${LISTDIR} ]] && mkdir -p ${LISTDIR}

for LIST in $(zmprov gadl)
do
	echo -e "Lista: ${AMARILLO}${LIST}${NOCO}"
	[[ -f ${LISTDIR}/${LIST} ]] && rm ${LISTDIR}/${LIST}
	for MEMBER in $(zmprov gdl ${LIST} | awk '/zimbraMailForwardingAdd/ {print $2}')
	do
		echo -e "\t${CIAN}${MEMBER}${NOCO} en ${AMARILLO}${LIST}${NOCO}"
		echo "${MEMBER}" >> ${LISTDIR}/${LIST}
	done
done
