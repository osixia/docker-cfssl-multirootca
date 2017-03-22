# Use osixia/light-baseimage
# sources: https://github.com/osixia/docker-light-baseimage
FROM osixia/light-baseimage:0.2.6
MAINTAINER Bertrand Gouny <bertrand.gouny@osixia.net>

# Install cfssl from baseimage
# sources: https://github.com/osixia/docker-light-baseimage/blob/stable/image/tool/add-service-available
#          https://github.com/osixia/docker-light-baseimage/blob/stable/image/service-available/:ssl-tools/download.sh
RUN apt-get -y update \
    && LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes --no-install-recommends \
       curl \
       ca-certificates \
    && /container/tool/add-service-available :ssl-tools \
    && curl -o /usr/local/bin/multirootca -SL https://pkg.cfssl.org/R1.2/multirootca_linux-amd64 \
    && chmod +x /usr/local/bin/multirootca \
    && apt-get remove -y --purge --auto-remove curl ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add service directory to /container/service
ADD service /container/service

# Use baseimage install-service script
# https://github.com/osixia/docker-light-baseimage/blob/stable/image/tool/install-service
RUN /container/tool/install-service

# Add default env variables
ADD environment /container/environment/99-default

EXPOSE 8888
