#!/bin/bash
#
# script for fill in lists
#
source ./functions.sh

for LIST in $(ls ./lists/)
do
	if exist_list ${LIST}
	then
		echo -e "${CIAN}${LIST}${NOCO} Existe"
		for ACCOUNT in $(cat ./lists/${LIST})
		do
			echo -e "\tInsert ${AMARILLO}${ACCOUNT}${NOCO}"
			zmprov addDistributionListMember ${LIST} ${ACCOUNT}
		done
	fi
done
