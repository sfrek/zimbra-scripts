#!/bin/bash
#
# Indice: 1.) Migracion de COS
#         2.) 1a. pasada de "bucle for" para creacion de Dominios / Cuentas sin Atributos / Listas de Distribucion.
#         3.) 2a. pasada de "bucle for" para rellenar toda la informacion de cada cuenta de cada dominio (incluye Buzones).

# VARIABLES:

# =========
# VARIABLES
# =========
DIRECTORIO_LOGS="./logs"
FICHERO_LOGS="$DIRECTORIO_LOGS/log_export_alias.log"
DIRECTORIO_EXPORT="./alias"

# Creacion del Directorio de Logs.
if [ ! -d $DIRECTORIO_LOGS ]; then
  mkdir -p $DIRECTORIO_LOGS
fi

# Creacion del Directorio de la Exportacion.
if [ ! -d $DIRECTORIO_EXPORT ]; then
  mkdir -p $DIRECTORIO_EXPORT
fi

# zimbra@serenity scripts]$ zmprov ga pjimenez@abadasoft.com | grep zimbraMailAlias | awk '{print $2}'
for domain in `zmprov gad`;do 
	echo "============================================================================================" >> $FICHERO_LOGS
	echo " Comprobacion de las alias de las cuentas de correo <$domain>" >> $FICHERO_LOGS
	echo "      `date`" >> $FICHERO_LOGS
	echo "============================================================================================" >> $FICHERO_LOGS
	for cuenta in `zmprov -l gaa $domain | sort`; do 	  
 		tiene_alias=`zmprov ga $cuenta | grep zimbraMailAlias | awk '{print $2}' | wc -l | awk '{print $1}'`;		
		if [ $tiene_alias -gt 1 ]; then
			echo "     La cuenta <$cuenta> tiene alias configurados..." >> $FICHERO_LOGS
			echo "        Salvados en <alias_$cuenta.txt>" >> $FICHERO_LOGS
 		    zmprov ga $cuenta | grep zimbraMailAlias | awk '{print $2}' > $DIRECTORIO_EXPORT/alias_$cuenta.txt
	    else 
			echo "       - La cuenta <$cuenta> NO tiene alias... - "
		fi	   
	done
	echo "============================================================================================"
done	

