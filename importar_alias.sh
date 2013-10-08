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
FICHERO_LOGS="$DIRECTORIO_LOGS/log_import_alias.log"
DIRECTORIO_ALIAS="./alias"

# Creacion del Directorio de Logs.
if [ ! -f $DIRECTORIO_LOGS ]; then
  mkdir -p $DIRECTORIO_LOGS
fi

# Creacion del Directorio de la Exportacion.
if [ ! -d $DIRECTORIO_EXPORT ]; then
   echo "ERROR: No existe el directorio de alias a exportar"
   exit 1
fi

# Captura de Listas y Miembros
echo "===================================================" >> $FICHERO_LOGS
echo "     Migracion de Alias de Correo de Zimbra        " >> $FICHERO_LOGS
echo "     `date`           " >> $FICHERO_LOGS
echo "===================================================" >> $FICHERO_LOGS
for archivo_alias in `ls $DIRECTORIO_ALIAS | grep abada `;do 	    
   echo " ------------------- $archivo_alias -----------------------"; echo " ----- $archivo_alias -----" >> $FICHERO_LOGS
   echo "Importando alias de correo para la cuenta <$archivo_alias>"
   for alias in `cat $DIRECTORIO_ALIAS/$archivo_alias | awk '{print $1}'`;do
     zmprov aaa $archivo_alias $alias
     echo "     Importando $alias en $archivo_alias " >> $FICHERO_LOGS
   done
done
echo "===================================================" >> $FICHERO_LOGS


#  AYudA:
#
#   addAccountAlias(aaa) {name@domain|id} {alias@domain}

