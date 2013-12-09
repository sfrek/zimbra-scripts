#!/bin/bash
#
# script for create lists
#
source ./functions.sh

for LIST in $(ls ./lists)
do
	echo -e "${CIAN}${LIST}${NOCO}"
	if ! exist_list ${LIST}
	then
		echo -e "\tCreamos ${CIAN}${LIST}${NOCO}"
		zmprov createDistributionList ${LIST}
	fi
done
