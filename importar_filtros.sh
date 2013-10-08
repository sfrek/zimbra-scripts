#!/bin/bash

# Uso $0 <archivo de filtros>
if [ $# -ne 1 ]; then 
	echo "Uso $0 <archivo de filtros>" 
	exit 1;
fi

CUENTA=$(head -1 $1 | awk '{print $3}')
echo "==================================================="
echo " Restableciendo filtro de correo a <$CUENTA>"

CONTENIDO="$(cat $1)";
zmprov ma $CUENTA zimbraMailSieveScript $CONTENIDO
echo "==================================================="
