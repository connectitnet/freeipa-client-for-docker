FROM phusion/baseimage:latest

LABEL maintainer="JSenecal@connectitnet.com"

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
 && apt-get install -y freeipa-client pwgen \
 && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Remove NSSdb certificate repository contents
RUN rm -rfv /etc/pki/nssdb

ADD /src /
RUN chmod +x /etc/service/*/run
RUN chmod +x /etc/my_init.d/*.sh

VOLUME [ "/etc" ]

CMD ["/sbin/my_init"]