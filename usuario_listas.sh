#!/bin/bash
#
# Listas a las que pertenece el usuario:
#	Desde el punto de vista de la cuenta del domino.
# 
# Aclaracion:
#	Con getAccountMembership salen todas las listas a las que pertenece el
#	usario, incluidas en las que estáde manera indirecta, de ahíel grep -v

[ $# -lt 1 ] && echo "Falta usuario" && exit 1

ACCOUNT=${1}
zmprov getAccountMembership ${ACCOUNT} | grep -v via
