# -----------------------------------------------------------------------------------------------
# Script:       backup_buzones_v3.sh
# Parametros:   sin parametros
#
# Versión:  3.02
# Fecha:    08-05-2013
# Autores:  Fernando I. Garcia Martinez <figarcia@abadasoft.com>
#           Pedro Jimenez Solis <pjimenez@abadasoft.com>
#
# Descripción: Script que va a realizar la copia de toda la información relevante de cada cuenta,
#              incluyendo desde la información LDAP hasta el buzon.
#              Recorre todos las cuentas de todos los dominios que haya en Zimbra.
#
#!/bin/bash
#
# -----------------------------------------------------------------------------------------------
# VARIABLES:
# -----------------------------------------------------------------------------------------------
DIRECTORIO_BASE="/opt/backup/zimbra"
SCRIPT_COMPRESION="/opt/zimbra/scripts/comprime_buzon.sh"
FICHERO_LDAP="ldap.info"
FICHERO_LISTAS="lists.info"
FICHERO_ALIAS="alias.info"
FICHERO_FILTROS="filters.info"
FICHERO_PASSWORD="password.info"
FICHERO_BUZON="buzon.tgz"
FICHERO_LOG="/var/log/backup_buzones_zimbra.log"

# -----------------------------------------------------------------------------------------------
#                            OPERACIONES CON DIRECTORIOS / FICHEROS
# -----------------------------------------------------------------------------------------------

# ----------------
# FICHERO DE LOGS
# ----------------
if [ ! -f $FICHERO_LOG ]; then 
   echo "" > $FICHERO_LOG;
   echo "Creado fichero de log <$FICHERO_LOG> ... " >> $FICHERO_LOG;
fi

# -----------------
#  DIRECTORIO BASE
# -----------------
if [ ! -d $DIRECTORIO_BASE ]; then 
   echo >> $FICHERO_LOG;
   echo "ATENCION: El directorio base de backup <$DIRECTORIO_BASE> no existe ..." >> $FICHERO_LOG;
   echo "    Se procede a su creacion..." >> $FICHERO_LOG;
   mkdir -p $DIRECTORIO_BASE 
fi

echo "============================================================================================" >> $FICHERO_LOG;
echo "                         PROCESO DE EXPORTACION DE CUENTAS / BUZONES                        " >> $FICHERO_LOG;
echo "                         `date`                                                             " >> $FICHERO_LOG;
echo "============================================================================================" >> $FICHERO_LOG;

for dominio in `zmprov gad`; do 
   echo "" >> $FICHERO_LOG;
   echo "Procesando el dominio <$dominio> " >> $FICHERO_LOG;
   echo "" >> $FICHERO_LOG;
   # Si no existe el directorio del dominio lo creamos
   if [ ! -d $DIRECTORIO_BASE/$dominio ]; then 
      echo "   Creando el directorio de backup para el dominio <$dominio>" >> $FICHERO_LOG;
	  mkdir -p $DIRECTORIO_BASE/$dominio
   fi
   # Si existe, borramos el "Directorio del Segundo dia de ($dominio.OLD)"
   if [ -d "$DIRECTORIO_BASE/$dominio.OLD" ]; then 
	   echo "   Borrando directorio de backup antiguo (2o dia) del dominio <$dominio> ..." >> $FICHERO_LOG;
	   rm -rf $DIRECTORIO_BASE/$dominio.OLD
   fi
   # Movemos el directorio actual al Segundo Dia (dominio --> dominio.OLD)
   mv $DIRECTORIO_BASE/$dominio $DIRECTORIO_BASE/$dominio.OLD
   echo "   Moviendo directorio de backup actual de <$dominio> a <$dominio.OLD>" >> $FICHERO_LOG;

   # Regeneramos el Directorio actual de Backup.
   mkdir -p $DIRECTORIO_BASE/$dominio
   echo "   Regeneramos el directorio de backup actual de <$dominio>" >> $FICHERO_LOG;
   
   echo "" >> $FICHERO_LOG;
   echo "    Procesando las cuentas de <$dominio> ..." >> $FICHERO_LOG;

   # ------------------------------------------------------------------------------------
   #                             EXPORTACION DE LA CUENTA
   # ------------------------------------------------------------------------------------
   for cuenta in `zmprov -l gaa $dominio`; do 
	   echo "      - $cuenta" >> $FICHERO_LOG;
       #DOMINIO=$(echo $cuenta | cut -d'@' -f2)
       USUARIO=$(echo $cuenta | cut -d'@' -f1)
       DIRECTORIO_USUARIO="$DIRECTORIO_BASE/$dominio/$USUARIO"
       # --------------------
       #  DIRECTORIO USUARIO
       # --------------------
       if [ ! -d $DIRECTORIO_USUARIO ]; then 
          echo "        Creando directorio de backup <$DIRECTORIO_USUARIO> para el usuario <$cuenta> ..." >> $FICHERO_LOG;
          mkdir -p $DIRECTORIO_USUARIO
       fi
       # --------------------
       #  EXPORTAR PASSWORD
       # --------------------
       PASSWORD="'`zmprov --ldap getAccount $cuenta | grep userPassword | cut -d ":" -f2`'";
       echo "$PASSWORD" > $DIRECTORIO_USUARIO/$FICHERO_PASSWORD;
       echo "        Exportando la password de la cuenta <$cuenta> ..." >> $FICHERO_LOG;
       echo "          Salvada la informacion en $DIRECTORIO_USUARIO/$FICHERO_PASSWORD" >> $FICHERO_LOG;
       # ------------------------
       #  EXPORTAR LDAP COMPLETO
       # ------------------------
       echo "        Exportando el contenido LDAP de la cuenta <$cuenta> ..." >> $FICHERO_LOG;
       echo "          Salvada la informacion en $DIRECTORIO_USUARIO/$FICHERO_LDAP" >> $FICHERO_LOG;
       zmprov --ldap ga $cuenta > $DIRECTORIO_USUARIO/$FICHERO_LDAP
       # ------------------
       #  EXPORTAR FILTROS
       # ------------------
       tiene_filtros=`zmprov --ldap ga $cuenta zimbraMailSieveScript | wc -l `;
       if [ $tiene_filtros -gt 2 ]; then
          echo "        Exportando los filtros configurados de <$cuenta> ..." >> $FICHERO_LOG;
          echo "          Salvada la informacion en $DIRECTORIO_USUARIO/$FICHERO_FILTROS" >> $FICHERO_LOG;
          zmmailbox -z -m $cuenta gfrl > $DIRECTORIO_USUARIO/$FICHERO_FILTROS
       else
          echo "        La cuenta <$cuenta> NO tiene filtros configurados..." >> $FICHERO_LOG;
          touch $DIRECTORIO_USUARIO/$FICHERO_FILTROS
       fi 
	   # -----------------
	   #  EXPORTAR LISTAS
	   # -----------------
	   zmprov getAccountMembership $cuenta | grep -v via > "$DIRECTORIO_USUARIO/$FICHERO_LISTAS"
	   echo 
	   if [ `wc -l $DIRECTORIO_USUARIO/$FICHERO_LISTAS | awk '{print $1}'` ]; then 
	      echo "        Exportando las listas a las que pertenece <$cuenta> ..." >> $FICHERO_LOG;
 	      echo "          Salvada la informacion en $DIRECTORIO_USUARIO/$FICHERO_LISTAS" >> $FICHERO_LOG;
	   else 
	      echo "     La cuenta <$cuenta> no pertenece a ninguna lista" >> $FICHERO_LOG;
	      touch $DIRECTORIO_USUARIO/$FICHERO_LISTAS
	   fi
	   # -----------------
 	   #  EXPORTAR ALIAS
	   # -----------------
	   tiene_alias=`zmprov --ldap ga $cuenta | grep zimbraMailAlias | awk '{print $2}' | wc -l | awk '{print $1}'`;
	   if [ $tiene_alias -gt 1 ]; then
	      echo "        Exportando los alias configurados de <$cuenta> ..." >> $FICHERO_LOG;
	      echo "          Salvada la informacion en $DIRECTORIO_USUARIO/$FICHERO_ALIAS" >> $FICHERO_LOG;
	      zmprov --ldap ga $cuenta | grep zimbraMailAlias | awk '{print $2}' > $DIRECTORIO_USUARIO/$FICHERO_ALIAS
	   else
	      echo "        La cuenta <$cuenta> NO tiene alias..." >> $FICHERO_LOG;
	      touch $DIRECTORIO_USUARIO/$FICHERO_ALIAS
	   fi
	   # ---------------
	   # EXPORTAR BUZON 
	   # ---------------
           bash $SCRIPT_COMPRESION $cuenta $DIRECTORIO_USUARIO >> $FICHERO_LOG;

           echo "" >> $FICHERO_LOG

   done # for cuenta

done # for dominio
# ------------------------------------------------------------
#  COPIA REMOTA DE LOS DATOS
# ------------------------------------------------------------
ZIMBRA_UID=1001
ZIMBRA_GID=1001
HETZNER_FTP="u31750.your-backup.de/backup"
HETZNER_FTP_USER="u31750"
HETZNER_FTP_PASS="ADss6Gf8dhbTpigs"
BINARIO_MOUNT="/sbin/mount.cifs"
MONTAJE_TEMPORAL="/mnt"

# Realizamos una copia de todos los buzones a almacenamiento EXTRA (FTP montado por SMB) de Hetzner
# mount.cifs -o rw,uid=1001,gid=1001,username=u31750,password=ADss6Gf8dhbTpigs //u31750.your-backup.de/backup /mnt/
echo "MONTAJE DE LA UNIDAD COMPARTIDA POR CIFS" >> $FICHERO_LOG
$BINARIO_MOUNT -o rw,uid=$ZIMBRA_UID,gid=$ZIMBRA_GID,username=$HETZNER_FTP_USER,password=$HETZNER_FTP_PASS //$HETZNER_FTP $MONTAJE_TEMPORAL

if [ $? == 0 ]; then
    echo "Montaje de la unidad CIFS correcta" >> $FICHERO_LOG
    rsync -av $DIRECTORIO_BASE $MONTAJE_TEMPORAL 
    umount $MONTAJE_TEMPORAL
else     
    echo "ERROR en el montaje de la unidad CIFS " >> $FICHERO_LOG
fi
# ------------------------------------------------------------



echo "============================================================================================" >> $FICHERO_LOG
echo "                         `date`                                                             " >> $FICHERO_LOG
echo "============================================================================================" >> $FICHERO_LOG

	

