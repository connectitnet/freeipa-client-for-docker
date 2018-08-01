#!/bin/bash
set -eo pipefail

# usage: file_env VAR [DEFAULT]
#    ie: file_env 'XYZ_DB_PASSWORD' 'example'
# (will allow for "$XYZ_DB_PASSWORD_FILE" to fill in the value of
#  "$XYZ_DB_PASSWORD" from a file, especially for Docker's secrets feature)
file_env() {
	local var="$1"
	local fileVar="${var}_FILE"
	local def="${2:-}"
	if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
		echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
		exit 1
	fi
	local val="$def"
	if [ "${!var:-}" ]; then
		val="${!var}"
	elif [ "${!fileVar:-}" ]; then
		val="$(< "${!fileVar}")"
	fi
	export "$var"="$val"
	unset "$fileVar"
}

# Generate default NSS Password
DEF_NSS_PASSWD=$(/usr/bin/pwgen 16 1)
file_env 'NSS_PASSWD' $DEF_NSS_PASSWD
NSSDB_DIR=/etc/pki/nssdb
NSS_PASSWD_FILE=/etc/pki/.nsspass
if [ ! -d "$NSSDB_DIR" ]; then
    # Create NSSdb directory
    mkdir -p $NSSDB_DIR
    echo $NSS_PASSWD > $NSS_PASSWD_FILE
    # Create new NSSdb certificate repository
    /usr/bin/certutil -N -d $NSSDB_DIR -f $NSS_PASSWD_FILE
fi

if [[ ! -f "/etc/ipa/ca.crt" || ! -f "/etc/openldap/ldap.conf" ]]; then
    file_env 'IPA_PASSWORD'
    if [[ -z "$IPA_PASSWORD" && -z "$IPA_DOMAIN" && -z "$IPA_PRINCIPAL" ]]; then
        echo >&2 'error: IPA client is not configured and "IPA_*" settings are not specified'
        exit 1
    fi
    # Install ipa client
    /usr/sbin/ipa-client-install -U -f --no-ntp --mkhomedir --domain=$IPA_DOMAIN -w $IPA_PASSWORD -p $IPA_PRINCIPAL < /dev/null
	if [ $? -eq 3 ]; then
		exit 0
	else
		echo "ipa-client-install failed with status $?" >&2
	fi
fi