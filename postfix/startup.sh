#!/bin/sh

echo "Adjusting postfix configuration"
envsubst '$POSTFIX_HOSTNAME,$POSTFIX_MYNETWORKS,$POSTFIX_TLS_CRT_FILENAME,$POSTFIX_TLS_KEY_FILENAME,$SMTP_SERVER,$SMTP_PORT' < /etc/postfix/main.cf > /etc/postfix/main.cf
envsubst '$LDAP_USER,$LDAP_BIND_PASSWORD,$LDAP_HOST,$LDAP_PORT' < /etc/postfix/ldap-aliases.cf > /etc/postfix/ldap-aliases.cf

echo "Adding INCOMING SASL authentication config"
mkdir -p /etc/sasl2
echo "pwcheck_method: auxprop
auxprop_plugin: sasldb
mech_list: PLAIN LOGIN CRAM-MD5 DIGEST-MD5 NTLM" > /etc/sasl2/smtpd.conf
echo "$POSTFIX_PASSWORD" | saslpasswd2 -c -p -u "$POSTFIX_HOSTNAME" "$POSTFIX_USERNAME"

echo "Adding OUTGOING SASL authentication config"
echo "[${SMTP_SERVER}]:${SMTP_PORT} ${SMTP_USERNAME}:${SMTP_PASSWORD}" > /etc/postfix/sasl_passwd
postmap /etc/postfix/sasl_passwd
chmod 600 /etc/postfix/sasl_passwd

postfix start-fg
