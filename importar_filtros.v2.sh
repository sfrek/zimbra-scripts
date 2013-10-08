#!/bin/bash

FILE=/tmp/remake_account_figarcia/figarcia@abadasoft.com/filtros.list
oldIFS=${IFS}
IFS='
'
for L in $(cat $FILE)
do
	echo ${L} | xargs zmmailbox -z -m figarcia@abadasoft.com addFilterRule --last
done

IFS=${oldIFS}
