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
FICHERO_LOGS="$DIRECTORIO_LOGS/log_export_listas.log"
DIRECTORIO_EXPORT="./logs"
FICHERO_EXPORT_LISTAS="$DIRECTORIO_EXPORT/export_listas.log"

# Creacion del Directorio de Logs.
if [ ! -d $DIRECTORIO_LOGS ]; then
  mkdir -p $DIRECTORIO_LOGS
fi

# Creacion del Directorio de la Exportacion.
if [ ! -d $DIRECTORIO_EXPORT ]; then
  mkdir -p $DIRECTORIO_EXPORT
fi

# Creacion del archivo/directorios de Listas
if [ -f $FICHERO_EXPORT_LISTAS ]; then
   rm -f $FICHERO_EXPORT_LISTAS
fi
touch $FICHERO_EXPORT_LISTAS

# Captura de Listas y Miembros
echo "==================================================="
echo "     Migracion de Listas de Correo de Zimbra       "
echo "==================================================="
for lista in `zmprov gadl`;do 	    
   echo " ------------------- $lista -----------------------"
   for miembro in `zmprov gdl $lista | grep zimbraMailForwardingAddress: | awk '{print $2}'`;do
      echo "     Exportado $miembro en la lista $lista"
      echo "$miembro $lista" >> $FICHERO_EXPORT_LISTAS;
   done
done
echo "==================================================="
