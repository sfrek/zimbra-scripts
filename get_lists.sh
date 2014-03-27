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
	echo "${LIST};" >> /tmp/lists.csv
	[[ -f ${LISTDIR}/${LIST} ]] && rm ${LISTDIR}/${LIST}
	for MEMBER in $(zmprov gdl ${LIST} | awk '/zimbraMailForwardingAdd/ {print $2}')
	do
		echo ";${MEMBER}" >> /tmp/lists.csv
		echo -e "\t${CIAN}${MEMBER}${NOCO} en ${AMARILLO}${LIST}${NOCO}"
		echo "${MEMBER}" >> ${LISTDIR}/${LIST}
		zmprov ga ${MEMBER} > /tmp/member.temp 
		grep "zimbraAccountStatus: closed" /tmp/member.temp && zmprov rdlm ${LIST} ${MEMBER}
	done
done
