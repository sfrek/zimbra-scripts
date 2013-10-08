#
# Script:   backup_buzones_v2.sh
# Uso:      sin parámetros
# Versión: 2.0
# Fecha:    17-04-2013
# Autor:	Pedro Jimenez Solis <pjimenez@abadasoft.com>
#
# Descripción: Script que va a realizar la compresión de los buzones de todos los usuarios de todos los 
#              dominios y la va a dejar en /opt/zimbra/scripts/mailboxes. También se encarga del borrado
#              y la rotación (2días) de estos buzones al otro volumen lógico (LV) que se ha creado, 
#              lv_backup (300GB). Manda un correo a sistemas@abadasoft.com con el log de las operaciones.
#
# Referencias: Este script hace uso de otros 2, comprime_buzon.sh que a su vez llama a account_size.sh
#              También creaun logde las operaciones que ha realizado.
#!/bin/bash
# 
# VARIABLES
# 
SCRIPT_BACKUP="/opt/zimbra/scripts/comprime_buzon.sh"
FICHERO_DOMINIOS="/opt/zimbra/scripts/lista_dominios"
FICHERO_LOG="/opt/zimbra/scripts/log_backup"
MAILTO="sistemas.hispafuentes@gmail.com"
DIRECTORIO_DIA1="/opt/backup/buzones/dia1"
DIRECTORIO_DIA2="/opt/backup/buzones/dia2"
DIRECTORIO_BUZONES="/opt/zimbra/scripts/mailboxes"

# Creamos el fichero de log (vacio).
if [ ! -f $FICHERO_LOG ]; then 
  touch $FICHERO_LOG
else
  > $FICHERO_LOG
fi

# Borrado de los buzones que llevan 2 dias guardados.
echo "======================================" >> $FICHERO_LOG
echo " BORRADO DE BUZONES ANTIGUOS ..." >> $FICHERO_LOG

if [ ! -d $DIRECTORIO_DIA2 ]; then 
   echo "  Creado el directorio <$DIRECTORIO_DIA2> ..." >> $FICHERO_LOG
   mkdir -p $DIRECTORIO_DIA2;
else
   echo "  Borrando buzones en <$DIRECTORIO_DIA2> ..." >> $FICHERO_LOG
   rm -rf $DIRECTORIO_DIA2/*
fi
echo "======================================" >> $FICHERO_LOG

# Movemos los buzones del directorio DIA1 al DIA2
echo " ROTACION DE BUZONES ..." >> $FICHERO_LOG
mv $DIRECTORIO_DIA1/* $DIRECTORIO_DIA2
echo " ROTACION COMPLETADA ..." >> $FICHERO_LOG
echo "======================================" >> $FICHERO_LOG

# Bucle para recorrer todas las cuentas de todos los dominios
echo " INICIO DE COMPRESION DE LOS BUZONES: `date`" >> $FICHERO_LOG
echo "======================================" >> $FICHERO_LOG

for dominio in `zmprov gad`;do
   echo "Realizando backup de las cuentas de <$dominio> ..." >> $FICHERO_LOG
   for cuenta in `zmprov -l gaa $dominio`; do
       echo >> $FICHERO_LOG
       echo "     [$cuenta] ... Comprimiendo Buzon" >> $FICHERO_LOG
	   sh $SCRIPT_BACKUP $cuenta >> $FICHERO_LOG
       echo "     [$cuenta] ... Finalizado" >> $FICHERO_LOG
   done
   echo "Finalizado ..." >> $FICHERO_LOG
done

echo "======================================" >> $FICHERO_LOG
echo " FIN DE COMPRESION DE LOS BUZONES: `date`" >> $FICHERO_LOG
echo "======================================" >> $FICHERO_LOG

# Copia de los Buzones al directorio de DIA1
echo " COPIANDO LOS BUZONES A DIRECTORIO DE DIA 1: `date`" >> $FICHERO_LOG
echo "======================================" >> $FICHERO_LOG
cp -R $DIRECTORIO_BUZONES/* $DIRECTORIO_DIA1

# Borrado de los Buzones
echo " BORRANDO LOS BUZONES: `date`" >> $FICHERO_LOG
echo "======================================" >> $FICHERO_LOG
rm -fv /opt/zimbra/scripts/mailboxes/*/* >> $FICHERO_LOG

echo " FIN DE LA COPIA DE LOS BUZONES A DIRECTORIO DE DIA 1: `date`" >> $FICHERO_LOG
echo "======================================" >> $FICHERO_LOG

# Envio del correo con el "log" a la direccion seleccionada: Sistemas
cat $FICHERO_LOG | mail -s "[ZIMBRA] Backup de Buzones - `date`" $MAILTO
