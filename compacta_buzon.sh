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
DOMINIO=$(echo $1 | cut -d'@' -f2)
USUARIO=$(echo $1 | cut -d'@' -f1)
DIRECTORIO_BASE="/opt/backup/zimbra"
DIRECTORIO_USUARIO="$DIRECTORIO_BASE/$DOMINIO/$USUARIO"
FICHERO_LDAP="ldap.info"
FICHERO_LISTAS="lists.info"
FICHERO_ALIAS="alias.info"
FICHERO_FILTROS="filters.info"
FICHERO_PASSWORD="password.info"
FICHERO_DISPLAY_NAME="displayname.info"
FICHERO_BUZON="buzon.tgz"
CUENTA_TEMPORAL="temporal@abadasoft.com"
DIRECTORIO_TEMPORAL="$DIRECTORIO_BASE/abadasoft.com/temporal"
# -----------------------------------------------------------------------------------------------
#                                  OPERACIONES CON DIRECTORIOS
# -----------------------------------------------------------------------------------------------

# -----------------
#  DIRECTORIO BASE
# -----------------
if [ ! -d $DIRECTORIO_BASE ]; then 
   echo 
   echo "ATENCION: El directorio base de backup <$DIRECTORIO_BASE> no existe ..."
   echo "    Se procede a su creacion..."
   mkdir -p $DIRECTORIO_BASE
fi

# --------------------
#  DIRECTORIO USUARIO
# --------------------
if [ ! -d $DIRECTORIO_USUARIO ]; then 
   echo 
   echo "Creando directorio de backup <$DIRECTORIO_USUARIO> para el usuario <$1> ..."
   mkdir -p $DIRECTORIO_USUARIO
fi

# --------------------
#  DIRECTORIO TEMPORAL
# --------------------
if [ ! -d $DIRECTORIO_TEMPORAL ]; then 
   echo 
   echo "Creando directorio de backup temporal <$DIRECTORIO_TEMPORAL> ..."
   mkdir -p $DIRECTORIO_TEMPORAL
fi

# -----------------------------------------------------------------------------------------------
#                                    EXPORTACION DE VALORES
# -----------------------------------------------------------------------------------------------

echo "============================================================================================"
echo "                         Compactando: $1"
echo "                         `date`"
echo "============================================================================================"
# --------------------
#  EXPORTAR PASSWORD
# --------------------
PASSWORD="'`zmprov --ldap getAccount $1 | grep userPassword | cut -d ":" -f2`'";
echo "$PASSWORD" > $DIRECTORIO_USUARIO/$FICHERO_PASSWORD
echo
#echo "     Salvada la password de $1: $PASSWORD"
echo "     Exportando la password de la cuenta <$1> ..."
echo "        Salvada la informacion en $DIRECTORIO_USUARIO/$FICHERO_PASSWORD"


# -----------------------
#  EXPORTAR DISPLAY NAME
# -----------------------
DISPLAY_NAME=`zmprov ga $1 | grep -i displayName | cut -d":" -f2 | sed 's/ //'`
echo $DISPLAY_NAME > $DIRECTORIO_USUARIO/$FICHERO_DISPLAY_NAME
echo
echo "     Exportando el DisplayName de la cuenta <$1> ..."
echo "        Salvada la informacion en $DIRECTORIO_USUARIO/$FICHERO_DISPLAY_NAME"

# ------------------------
#  EXPORTAR LDAP COMPLETO
# ------------------------
echo
echo "     Exportando el contenido LDAP de la cuenta <$1> ..."
echo "        Salvada la informacion en $DIRECTORIO_USUARIO/$FICHERO_LDAP"
zmprov ga $1 > $DIRECTORIO_USUARIO/$FICHERO_LDAP

# ------------------
#  EXPORTAR FILTROS
# ------------------
tiene_filtros=`zmprov ga $1 zimbraMailSieveScript | wc -l `;
echo 
if [ $tiene_filtros -gt 2 ]; then
   echo "     Exportando los filtros configurados de <$1> ..."
   echo "        Salvada la informacion en $DIRECTORIO_USUARIO/$FICHERO_FILTROS"
    zmmailbox -z -m $1 gfrl > $DIRECTORIO_USUARIO/$FICHERO_FILTROS
else
   echo "     La cuenta <$1> NO tiene filtros configurados..."
   touch $DIRECTORIO_USUARIO/$FICHERO_FILTROS

fi

# -----------------
#  EXPORTAR LISTAS
# -----------------
zmprov getAccountMembership $1 | grep -v via > "$DIRECTORIO_USUARIO/$FICHERO_LISTAS"
echo 
if [ `wc -l $DIRECTORIO_USUARIO/$FICHERO_LISTAS | awk '{print $1}'` ]; then 
   echo "     Exportando las listas a las que pertenece <$1> ..."
   echo "        Salvada la informacion en $DIRECTORIO_USUARIO/$FICHERO_LISTAS"
else 
   echo "     La cuenta <$1> no pertenece a ninguna lista"
   touch $DIRECTORIO_USUARIO/$FICHERO_LISTAS
fi

# -----------------
#  EXPORTAR ALIAS
# -----------------
tiene_alias=`zmprov ga $1 | grep zimbraMailAlias | awk '{print $2}' | wc -l | awk '{print $1}'`;
echo
if [ $tiene_alias -gt 1 ]; then
   echo "     Exportando los alias configurados de <$1> ..."
   echo "        Salvada la informacion en $DIRECTORIO_USUARIO/$FICHERO_ALIAS"
   zmprov ga $1 | grep zimbraMailAlias | awk '{print $2}' > $DIRECTORIO_USUARIO/$FICHERO_ALIAS
   # Despues de capturarlos hay que quitarlos
   echo "        Eliminando alias en la cuenta $1 ..."
   for alias in `cat $DIRECTORIO_USUARIO/$FICHERO_ALIAS`; do 
      echo "           Eliminado <$alias>"
	  zmprov removeAccountAlias $1 $alias
   done
else
   echo "     La cuenta <$1> NO tiene alias..."
   touch $DIRECTORIO_USUARIO/$FICHERO_ALIAS
fi  

# -----------------------------------------------------------------------------------------------
#                                     OPERACION CON BUZONES 
# -----------------------------------------------------------------------------------------------

# ----------------------------
#  MOVER BUZON A UNO TEMPORAL
# ----------------------------
echo
echo "     Moviendo la cuenta <$1> al buzon temporal <$CUENTA_TEMPORAL>"
zmprov renameAccount $1 $CUENTA_TEMPORAL

# -----------------------
#  RECREACION DEL BUZON
# -----------------------
echo
echo "     Regenerando la cuenta <$1>"
zmprov createAccount $1 "Abada123."

# -----------------------------------------------------------------------------------------------
#                                    IMPORTACION DE VALORES
# -----------------------------------------------------------------------------------------------

# -------------------
#  IMPORTAR PASSWORD
# -------------------
echo
echo "     Importando la password de <$1>"
echo $PASSWORD | xargs zmprov --ldap ma $1 userPassword

# -----------------------
#  IMPORTAR DISPLAY_NAME
# -----------------------
echo
echo "     Importando el DisplayName de <$1>"
zmprov ma $1 displayName "$DISPLAY_NAME"

# ----------------
#  IMPORTAR ALIAS
# ----------------
tiene_alias=$(wc -l $DIRECTORIO_USUARIO/$FICHERO_ALIAS | awk '{print $1}');
if [ $tiene_alias -gt 0 ]; then
   echo 
   echo "     Importando los alias de <$1>"
   for alias in `cat $DIRECTORIO_USUARIO/$FICHERO_ALIAS`; do 
      echo "        Adding <$alias>"
	  zmprov addAccountAlias $1 $alias
   done
fi

# -----------------
#  IMPORTAR LISTAS
# -----------------
tiene_listas=$(wc -l $DIRECTORIO_USUARIO/$FICHERO_LISTAS | awk '{print $1}');
if [ $tiene_listas -gt 0 ]; then
   echo 
   echo "     Importando las listas de <$1>"
   for lista in `cat $DIRECTORIO_USUARIO/$FICHERO_LISTAS`; do 
      echo "        Adding <$1> to <$lista>"
	  zmprov addDistributionListMember $lista $1
   done
fi

# ------------------
#  IMPORTAR FILTROS
# ------------------
tiene_filtros=$(wc -l $DIRECTORIO_USUARIO/$FICHERO_FILTROS | awk '{print $1}');
if [ $tiene_filtros -gt 0 ]; then
   echo 
   echo "     Importando los filtros de <$1>"
   oldIFS=${IFS}
   IFS='
'
   for filtro in `cat $DIRECTORIO_USUARIO/$FICHERO_FILTROS`; do
      nombre_filtro=$(echo $filtro|cut -d'"' -f2)
      echo "        Adding $nombre_filtro"
      echo $filtro | xargs zmmailbox -z -m $1 addFilterRule --last
   done
   IFS=${oldIFS}
fi

# -------------------
#  EXPORTAR EL BUZON 
# -------------------
echo
echo "     Comprimiendo Buzon de <$CUENTA_TEMPORAL>"
bash comprime_buzon.sh $CUENTA_TEMPORAL $DIRECTORIO_BASE

# -------------------
#  IMPORTAR EL BUZON 
# -------------------
echo
buzon_exportado="$DIRECTORIO_TEMPORAL/$FICHERO_BUZON"
echo "     Descomprimiendo Buzon de <$1>"
#echo "        bash descomprime_buzon.sh $1 $buzon_exportado"
bash descomprime_buzon.sh $1 $buzon_exportado

# -------------------------------
#  BORRADO DE LA CUENTA TEMPORAL
# -------------------------------
echo
echo "     Eliminando la cuenta temporal <$CUENTA_TEMPORAL>"
zmprov da $CUENTA_TEMPORAL



echo "============================================================================================"
echo " `date`"
echo "============================================================================================"

	

