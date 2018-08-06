#!/bin/bash

nameservers=$(dig ns $IPA_DOMAIN +short | sort | sed -e 's/\.$//')
touch /etc/resolv.conf.tmp
for nameserver in $nameservers; do
    echo "nameserver $(getent hosts $nameserver | awk '{ print $1 }')">>/etc/resolv.conf.tmp
done
cp /etc/resolv.conf.tmp /etc/resolv.conf