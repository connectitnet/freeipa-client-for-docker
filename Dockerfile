FROM phusion/baseimage:latest

LABEL maintainer="JSenecal@connectitnet.com"

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
 && apt-get install -y freeipa-client pwgen \
 && rm -rf /var/lib/apt/lists/*

# Remove NSSdb certificate repository contents
RUN rm -rfv /etc/pki/nssdb

ADD docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

VOLUME [ "/etc/pki/nssdb" ]
VOLUME [ "/etc/ipa" ]

ENV NSSDB_DIR=/etc/pki/nssdb

ENTRYPOINT ["/docker-entrypoint.sh"]