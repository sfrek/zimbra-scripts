#!/bin/bash
#
# Indice: 1.) Migracion de COS
#         2.) 1a. pasada de "bucle for" para creacion de Dominios / Cuentas sin Atributos / Listas de Distribucion.
#         3.) 2a. pasada de "bucle for" para rellenar toda la informacion de cada cuenta de cada dominio (incluye Buzones).


# Creacion del directorio para alojar los filtros 
DIRECTORIO_DESTINO="./filters"
if [ ! -d $DIRECTORIO_DESTINO ]; then 
  mkdir -p $DIRECTORIO_DESTINO
fi

for domain in `zmprov gad`;do 
	echo "============================================================================================"
	echo " Comprobacion de las cuentas que tengan filtros de Correo en  <$domain>"
	echo "============================================================================================"
	for cuenta in `zmprov -l  gaa $domain | sort`; do 
	  
 		tiene_filtros=`zmprov ga $cuenta zimbraMailSieveScript | wc -l `;
		
		if [ $tiene_filtros -gt 2 ]; then
			echo "     La cuenta <$cuenta> tiene filtros configurados..."
			echo "        Salvados en <filtros_$cuenta.txt>"
 		    # zmprov ga $cuenta zimbraMailSieveScript > $DIRECTORIO_DESTINO/filtros_$cuenta.txt
 		    zmmailbox -z -m $cuenta gfrl > $DIRECTORIO_DESTINO/filtros_$cuenta.txt
		fi
	   
	done
	echo "============================================================================================"
done	

