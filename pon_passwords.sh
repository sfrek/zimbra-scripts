# -----------------------------------------------------------------------------------------------
# Script:       compacta_buzon.sh
# Parametros:   $1 = Buzon a COMPACTAR.
#
# Versión:  .04
# Fecha:    30-04-2013
# Autores:  Fernando I. Garcia Martinez <figarcia@abadasoft.com>
#           Pedro Jimenez Solis <pjimenez@abadasoft.com>
#
# Descripción: Script que va a realizar la compreson real del buzon que recibe como parametro.
#              Se manda a la salida estandar los mensajes de ejecucion / error.
#              Captura del parametro buzon ($1) el "usuario" y el "dominio" y crea en la ruta de
#              backup un subdirectorio (si no existe) en el que se guardara la copia del Buzon.
#
#!/bin/bash
#
# -----------------------------------------------------------------------------------------------
# VARIABLES:
# -----------------------------------------------------------------------------------------------
DOMINIO="abadasoft.com"
DIRECTORIO_BASE="/opt/backup/zimbra"
FICHERO_PASSWORD="password.info"

echo "============================================================================================"
echo "                   Poniendo las passwords del fichero de usuaurios <$1>"
echo "                         `date`"
echo "============================================================================================"

# -----------------------------------------------------------------------------------------------
#                                    IMPORTACION DE VALORES
# -----------------------------------------------------------------------------------------------

# -------------------
#  IMPORTAR PASSWORD
# -------------------
for usuario in `cat $1`;do 
   USUARIO=$(echo $usuario | cut -d'@' -f1)
   PASSWORD="`cat $DIRECTORIO_BASE/$DOMINIO/$USUARIO/$FICHERO_PASSWORD | sed 's/ //g' ` "
   echo
   echo "     Importando la password de <$usuario> <`echo $PASSWORD`>"
   echo $PASSWORD | xargs zmprov --ldap ma $usuario userPassword
done

echo "============================================================================================"
echo " `date`"
echo "============================================================================================"

	

