#!/bin/bash
#
# Script to create
#

# source ./functions.sh

TEMP_DIR=/tmp/accounts_info
ACCOUNTS_FILE=${TEMP_DIR}/all_accounts
mkdir -p ${TEMP_DIR}

zmprov --ldap getAllAccounts > ${ACCOUNTS_FILE}

# get mailbox size
#
# zmmailbox -z -m ${CORREO} getMailboxSize
#

for ACCOUNT in $(cat ${ACCOUNTS_FILE})
do
	DOMAIN=${ACCOUNT##*@}
	SIZE=$(zmmailbox -z -m ${ACCOUNT} getMailboxSize)
	zmprov --ldap getAccount ${ACCOUNT} > ${TEMP_DIR}/${ACCOUNT}
	DISPLAY_NAME="$(grep -i displayname ${TEMP_DIR}/${ACCOUNT} )"
	STATUS=$(awk '/^zimbraAccountStatus:/ {print $2}' ${TEMP_DIR}/${ACCOUNT})
	echo "${DOMAIN};${ACCOUNT};${SIZE};${STATUS};${DISPLAY_NAME##*:}"
done
rm -rf ${TEMP_DIR}
