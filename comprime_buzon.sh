# Script:       comprime_buzon.sh
# Parametros:   $1 = Buzon a descomprimir
#	        $2 = Ruta donde alojar el backup del buzon en formato TGZ.
#
# Version:  2.02
# Fecha:    08-05-2013
# Autores:  Fernando I. Garcia Martinez <figarcia@abadasoft.com>
#           Pedro Jimenez Solis <pjimenez@abadasoft.com>
#
# Descripcion: Script que va a realizar la compreson real del buzon que recibe como parametro ($1)
#              y lo guardará en el directorio asociado al segundo parametro "$2/dominio/Cuenta"
#              Se mandan a la salida estandar los mensajes de ejecucion / error.
#
#!/bin/bash
# -----------------------------------------------------------------------------------------------
# COMPROBACION DE PARAMETROS:
# -----------------------------------------------------------------------------------------------
if [ $# -lt 2 ]; then  
   echo "Uso: comprime_buzon.sh <correo> <path_of_backup_directory>";
   exit 1
fi

# -----------------------------------------------------------------------------------------------
# VARIABLES:
# -----------------------------------------------------------------------------------------------
CORREO=${1}
USUARIO=${CORREO%%@*}
DOMINIO=${CORREO##*@}
DESTINO="${2}/${DOMINIO}/$USUARIO"
NOMBRE_BUZON="buzon.tgz"

# -----------------------------------------------------------------------------------------------
# COMPROBACION DEL DIRECTORIO DE SALVADO:
# -----------------------------------------------------------------------------------------------
# Creacion del directorio propio del dominio si no existe
if [ ! -d ${DESTINO} ]; then 
   mkdir -p ${DESTINO}
fi

# -----------------------------------------------------------------------------------------------
# COMPRESION DEL BUZON:
# -----------------------------------------------------------------------------------------------
# Calculo del tamano actual del Buzon
SIZE="$(zmmailbox -z -m ${CORREO} getMailboxSize)"
echo -e "      \033[01;32mComprimo ${CORREO}\033[00m";
echo -e "      \033[01;33mSize: ${SIZE}\033[00m";
logger -t "$0" "Comprimiendo ${CORREO} con tamano ${SIZE}";

# Compresion del Buzon en un archivo TGZ
zmmailbox -z -m ${CORREO} getRestURL "//?fmt=tgz" > ${DESTINO}/${NOMBRE_BUZON}

# -----------------------------------------------------------------------------------------------
# RESULTADO DE LA OPERACION:
# -----------------------------------------------------------------------------------------------
# Si el resultado es correcto ==> (x0 = x0) ==> ECHO + LOGGER
if [ "x$?" = "x0" ]; then
	FINAL_SIZE=$(du -hs ${DESTINO}/${NOMBRE_BUZON} | awk '{print $1}')
	echo -e "      \033[01;34mVolcado de ${CORREO} correcto (Final TGZ Size: $FINAL_SIZE)\033[00m";
	logger -t "$0" "${DESTINO}/${NOMBRE_BUZON} OK";
else
	echo -e "      \033[01;31mError en el Volcado de ${CORREO}\033[00m";
   	logger -t "$0" "${DESTINO}/${NOMBRE_BUZON} NO OK";
fi
