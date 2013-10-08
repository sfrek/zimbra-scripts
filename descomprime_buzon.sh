# -----------------------------------------------------------------------------------------------
# Script:       descomprime_buzon.sh
# Parametros:   $1 --> Cuenta sobre la que se va a restaurar el BackUP
#               $2 --> RUTA completa del archivo TGZ 
#
# Versión:  1.04
# Fecha:    07-05-2013
# Autores:  Fernando I. Garcia Martinez <figarcia@abadasoft.com>
#           Pedro Jimenez Solis <pjimenez@abadasoft.com>
#
# Descripción: Script que va a realizar el volcado de la información contenida en un archivo 
#              de BACKUP ("buzon.tgz") de una cuenta hacia el buzon que se le pase como primer
#              parametro.
#
#!/bin/bash
# -----------------------------------------------------------------------------------------------
# VARIABLES:
# -----------------------------------------------------------------------------------------------
CORREO=${1}
ARCHIVO_BACKUP=${2}
CORREO_DESTINO="zimbra@abadasoft.com"
# -----------------------------------------------------------------------------------------------
# COMPROBACION DE PARAMETROS:
# -----------------------------------------------------------------------------------------------
if [ $# -lt 2 ]; then  
   echo "Uso: descomprime_buzon.sh <correo> <RUTA COMPLETA del archivo tgz>" 
   exit 1
fi

if [ ! -f $ARCHIVO_BACKUP ]; then 
   echo "ERROR: No existe el archivo especificado... <$ARCHIVO_BACKUP>"
   exit 1
fi 

# -----------------------------------------------------------------------------------------------
# RESTAURACION DEL BUZON:
# -----------------------------------------------------------------------------------------------
echo -e "      \033[01;32mDescomprimo $1\033[00m"
echo -e "      \033[01;33mSize actual: $(zmmailbox -z -m $1 getMailboxSize)\033[00m"

# Sentencia de compresion
zmmailbox -z -m $CORREO postRestURL "//?fmt=tgz" $ARCHIVO_BACKUP

# Volcado de Buzon.
# The resolve= paramater has several options:
#  “skip” ignores duplicates of old items, it’s also the default conflict-resolution.
#  “modify” changes old items.
#  “reset” will delete the old subfolder (or entire mailbox if /).
#  “replace” will delete and re-enter them.

# -----------------------------------------------------------------------------------------------
# ENVIO DE CORREO CON RESULTADO DE LA OPERACION:
# -----------------------------------------------------------------------------------------------
if [ "x$?" = "x0" ];then
    echo -e "      \033[01;34m\"Volcado\" de $1 correcto"
    echo -e "      \033[01;33mNuevo Size: $(zmmailbox -z -m $1 getMailboxSize)\033[00m"
    echo "${CORREO} Volcado" | mail -s "[ VOLCADO ]" $CORREO_DESTINO
else
    echo -e "      \033[01;31mError en \"Volcado\" de ${CORREO}\033[00m"
fi
