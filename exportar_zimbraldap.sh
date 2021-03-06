#/bin/bash
#SCRIPT PARA EXPORTAR COS, CONTAS, NOMES ALTERNATIVOS E LISTAS DE DISTRIBUICAO DO ZIMBRA
#FABIO S. SCHMIDT - fabio_schmidt@hotmail.com - 02/04/2015
#TODO:

#OBTER INTERFACE DESEJADA E IP DO ZIMBRA PARA CONEXAO
IFACE="eth0"
IP=`/sbin/ifconfig $IFACE | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p'`
#DESTINO DOS ARQUIVOS
DEST="/tmp"

#DIRETORIO TEMPORARIO PARA NOMES ALTERNATIVOS
if [ ! -d "$DEST/alias" ]; then
 mkdir $DEST/alias
 echo "Criando DIRETORIO TEMPORARIO PARA NOMES ALTERNATIVOS"
 else
 echo "DIRETORIO TEMPORARIO PARA NOMES ALTERNATIVOS JA EXISTENTE - EXECUCAO ABORTADA"
 exit 0
fi

#DEFININDO VARIAVEIS DE AMBIENTE DO ZIMBRA
source ~/bin/zmshutil
zmsetvars

#EXPORTANDO CLASSES DE SERVICO
echo "EXPORTANDO CLASSES DE SERVICO"
ldapsearch -x -H ldap://$IP -D uid=zimbra,cn=admins,cn=zimbra -w $zimbra_ldap_password -b '' -LLL "(objectclass=zimbraCOS)" > $DEST/COS.ldif

#EXPORTANDO CONTAS
echo "EXPORTANDO CONTAS"
ldapsearch -x -H ldap://$IP -D uid=zimbra,cn=admins,cn=zimbra -w $zimbra_ldap_password -b '' -LLL "(objectclass=zimbraAccount)" > $DEST/CONTAS.ldif

#EXPORTANDO NOMES ALTERNATIVOS
echo "EXPORTANDO NOMES ALTERNATIVOS"
ldapsearch -x -H ldap://$IP -D uid=zimbra,cn=admins,cn=zimbra -w $zimbra_ldap_password  -b '' -LLL "(objectclass=zimbraAlias)" uid | grep ^uid | awk '{print $2}' > $DEST/lista_contas.ldif

for MAIL in $(cat $DEST/lista_contas.ldif);
	do 
      ldapsearch -x -H ldap://$IP -D uid=zimbra,cn=admins,cn=zimbra -w $zimbra_ldap_password -b '' -LLL "(&(uid=$MAIL)(objectclass=zimbraAlias))" > $DEST/alias/$MAIL.ldif
	cat $DEST/alias/*.ldif > $DEST/APELIDOS.ldif
done 

#EXPORTANDO LISTAS DE DISTRIBUICAO
echo "EXPORTANDO LISTAS DE DISTRIBUICAO"
ldapsearch -x -H ldap://$IP -D uid=zimbra,cn=admins,cn=zimbra -w $zimbra_ldap_password -b '' -LLL "(objectclass=zimbraDistributionList)" > $DEST/LISTAS.ldif
