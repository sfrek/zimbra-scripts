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
FICHERO_LOGS="$DIRECTORIO_LOGS/log_import_listas.log"
DIRECTORIO_EXPORT="./listas"
#FICHERO_EXPORT_LISTAS="$DIRECTORIO_EXPORT/export_listas.log"
FICHERO_EXPORT_LISTAS="$DIRECTORIO_EXPORT/export_listas_pjimenez.log"

# Creacion del Directorio de Logs.
if [ ! -f $DIRECTORIO_LOGS ]; then
  mkdir -p $DIRECTORIO_LOGS
fi

# Creacion del Directorio de la Exportacion.
if [ ! -d $DIRECTORIO_EXPORT ]; then
   echo "ERROR: No existe el directorio de listas a exportar"
   exit 1
fi

# Creacion del archivo/directorios de Listas
if [ ! -f $FICHERO_EXPORT_LISTAS ]; then
   echo "ERROR: No existe el fichero de listas a exportar"
   exit 1
fi

# Captura de Listas y Miembros
echo "===================================================" >> $FICHERO_LOGS
echo "     Migracion de Listas de Correo de Zimbra       " >> $FICHERO_LOGS
echo "     `date`           " >> $FICHERO_LOGS
echo "===================================================" >> $FICHERO_LOGS
for lista in `cat $FICHERO_EXPORT_LISTAS | awk '{print $2}' | uniq | sort `;do 	    
   echo " ------------------- $lista -----------------------"; echo " ----- $lista -----" >> $FICHERO_LOGS
   zmprov cdl $lista 
   for miembro in `grep $lista $FICHERO_EXPORT_LISTAS | awk '{print $1}'`;do
      zmprov adlm $lista $miembro
      echo "     Exportado $miembro en la lista $lista" >> $FICHERO_LOGS
   done
done
echo "==================================================="


#  AYudA:
#
#  addDistributionListMember(adlm) {list@domain|id} {member@domain}+
#
#  createDistributionList(cdl) {list@domain}

