FROM phusion/baseimage:latest

LABEL maintainer="JSenecal@connectitnet.com"

ENV DEBIAN_FRONTEND=noninteractive
RUN install_clean freeipa-client pwgen \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
 && mv /etc/krb5.conf /etc/ipa

# Remove NSSdb certificate repository contents
RUN rm -rfv /etc/pki/nssdb

ADD /src /
RUN chmod +x /etc/service/*/run
RUN chmod +x /etc/my_init.d/*.sh

VOLUME ["/etc/ipa", "/etc/sssd", "/etc/pki", "/etc/openldap"]

CMD ["/sbin/my_init"]