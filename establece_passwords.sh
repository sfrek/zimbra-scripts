#!/bin/bash
# ----------------------------------------------------------------------------------
#
# Script:      genera_passwords.sh
# Descripcion: Este script se encarga de la generacion de las nuevas contraseñasy del 
#              envio masivo del correo de AVISO a cada cuenta de cada dominio de 
#              la empresa.
# NOTA:        Este script debe ejecutarse en el Servidor Origen, y posteriormente 
#              pasar las contrase�as al Servidor Destino y ejecutar el "establecer password"
#              desde el mismo, ya que no sera posible hacerlo porque el DNS de Abada
#              estárespondiendo con un BIND local.
#
# ----------------------------------------------------------------------------------
# =========
# VARIABLES
# =========
CUENTA_ADMIN="admin@abadasoft.com"
DIRECTORIO_LOGS="./logs"
FICHERO_LOGS="$DIRECTORIO_LOGS/log_establecimiento.log"
DIRECTORIO_PASSWORDS="./logs"
FICHERO_PASSWORDS="$DIRECTORIO_PASSWORDS/produccion.log"

# Comprobacion de los archivos/directorios de Passwords.
if [ ! -d $DIRECTORIO_PASSWORDS ]; then
   echo "ERROR: No existe el directoio donde se aloja el fichero de Passwords"
   exit 1
else 
   if [ ! -f $FICHERO_PASSWORDS ]; then
      echo "ERROR: No existe el archivo de Passwords"
      exit 1  
   fi
fi

# Creacion del Directorio de Logs.
if [ ! -d $DIRECTORIO_LOGS ]; then
  mkdir -p $DIRECTORIO_LOGS
fi

# Bucle para establecer la contrasena de los usuarios de los dominios.
  echo "============================================================================================" >> $FICHERO_LOGS
  echo " Script para Establecer las Contrasenas nuevas para todos los usuarios de Zimbra" >> $FICHERO_LOGS
  echo " $(date) " >> $FICHERO_LOGS
  echo "============================================================================================" >> $FICHERO_LOGS
  for domain in `zmprov gad`;do
     echo " -------------------------------------" >> $FICHERO_LOGS
     echo " Dominio: $domain" >> $FICHERO_LOGS
     echo " -------------------------------------" >> $FICHERO_LOGS
     for cuenta in `zmprov -l  gaa $domain | sort`; do
	    password=`grep $cuenta $FICHERO_PASSWORDS | awk '{print $4}'`
		if [ "x$password" == "x" ]; then # password sale vacio
	       echo "     No se cambia la password al usuario <$cuenta>" >> $FICHERO_LOGS
		else
		   if [ `echo $cuenta | grep galsync` ] || [ $cuenta == $CUENTA_ADMIN ]; then # Cuentas Protegidas
	          echo "     No se cambia la password al usuario <$cuenta>" >> $FICHERO_LOGS
		   else 
		      zmprov setPassword $cuenta $password;
              zmprov modifyAccount $cuenta zimbraPasswordMustChange TRUE;
	          echo "     Establecida la password <$password> al usuario <$cuenta>" >> $FICHERO_LOGS
		   fi
		fi
	 done # - for cuentas 
  done # - for domains



