# ------------------------------------------------------------
#  COPIA REMOTA DE LOS DATOS
# ------------------------------------------------------------
ZIMBRA_UID=1001
ZIMBRA_GID=1001
HETZNER_FTP="u31750.your-backup.de/backup"
HETZNER_FTP_USER="u31750"
HETZNER_FTP_PASS="ADss6Gf8dhbTpigs"
MONTAJE_TEMPORAL="/mnt"
FICHERO_LOG="/tmp/check_backup.log"

# Realizamos una copia de todos los buzones a almacenamiento EXTRA (FTP montado por SMB) de Hetzner
# mount.cifs -o rw,uid=1001,gid=1001,username=u31750,password=ADss6Gf8dhbTpigs //u31750.your-backup.de/backup /mnt/
echo " ----------------------------------- `date ` ---------------------------------------------------------" >> $FICHERO_LOG
mount.cifs -o rw,uid=$ZIMBRA_UID,gid=$ZIMBRA_GID,username=$HETZNER_FTP_USER,password=$HETZNER_FTP_PASS //$HETZNER_FTP $MONTAJE_TEMPORAL

if [ $? == 0 ]; then
    echo "Montaje de la unidad CIFS correcta" >> $FICHERO_LOG
    df -h $MONTAJE_TEMPORAL
    ls $MONTAJE_TEMPORAL/*
    umount $MONTAJE_TEMPORAL
else
    echo "ERROR en el montaje de la unidad CIFS " >> $FICHERO_LOG
fi
echo " ----------------------------------- `date ` ---------------------------------------------------------" >> $FICHERO_LOG
# ------------------------------------------------------------

