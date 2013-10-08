#!/bin/bash
# ----------------------------------------------------------------------------------
#
# Script:      genera_passwords.sh
# Descripcion: Este script se encarga de la generacion de las nuevas contraseÃ±asy del 
#              envio masivo del correo de AVISO a cada cuenta de cada dominio de 
#              la empresa.
# NOTA:        Este script debe ejecutarse en el Servidor Origen, y posteriormente 
#              pasar las contraseÃas al Servidor Destino y ejecutar el "establecer password"
#              desde el mismo, ya que no sera posible hacerlo porque el DNS de Abada
#              estÃ¡respondiendo con un BIND local.
#
# ----------------------------------------------------------------------------------
# =========
# VARIABLES
# =========
DIRECTORIO_LOGS="./logs"
FICHERO_LOGS="$DIRECTORIO_LOGS/log_envio.log"
CORREO_DE_SISTEMAS="sistemas.hispafuentes@gmail.com"

# Creacion del Directorio de Logs
if [ ! -d $DIRECTORIO_LOGS ]; then
  mkdir -p $DIRECTORIO_LOGS
  fi

# Bucle para la generacion y envio del correo de cambio de contraseÃa
  echo "============================================================================================" >> $FICHERO_LOGS
  echo " Script para la generacion de Contrasenas nuevas para todos los usuarios de Zimbra" >> $FICHERO_LOGS
  echo " $(date) " >> $FICHERO_LOGS
  echo "============================================================================================" >> $FICHERO_LOGS
  for domain in `zmprov gad`;do
     echo " -------------------------------------" >> $FICHERO_LOGS
     echo " Dominio: $domain" >> $FICHERO_LOGS
     echo " -------------------------------------" >> $FICHERO_LOGS
     for cuenta in `zmprov -l  gaa $domain | sort`; do
	    password="RANDOMpass_$(openssl rand -hex 4)"
		# Cuentas a Omitir:
		if [ `echo $cuenta | grep galsync` ] || [ `echo $cuenta | grep admin@abadasoft.com` ] ;then
		  echo "     La Cuenta: ---$cuenta--- no se cambia" >> $FICHERO_LOGS;
		else 
		  echo "     Cuenta: $cuenta Password: $password" >> $FICHERO_LOGS
          if [ `echo $cuenta | grep pjimenez` ] || [ `echo $cuenta | grep figarcia` ];then
		     echo "Estimado Colaborador: 
Le enviamos la nueva password  que estara disponible desde esta misma noche a partir de las 23:00h
Su nueva password es: $password
			       
Un saludo. 
"  | mail -s "DPTO SISTEMAS - OTP Password - 22 Abril 2013" $cuenta
		  fi
		zmprov setPassword $cuenta $password;
        zmprov modifyAccount $cuenta zimbraPasswordMustChange TRUE;
		# Envio del Correo
		fi
	 done # - for cuentas 
  done # - for domains



