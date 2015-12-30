FROM osixia/light-baseimage:0.2.1-dev
MAINTAINER Bertrand Gouny <bertrand.gouny@osixia.net>

# Use baseimage's init system.
# https://github.com/osixia/docker-light-baseimage/blob/stable/image/tool/run
CMD ["/container/tool/run"]

# Install cfssl from baseimage
# https://github.com/osixia/docker-light-baseimage/blob/stable/image/tool/install-service-available
RUN apt-get -y update \
    && /container/tool/install-service-available cfssl

# Add service directory to /container/service
ADD service /container/service

# Use baseimage install-service script
# https://github.com/osixia/docker-light-baseimage/blob/stable/image/tool/install-service
RUN /container/tool/install-service

# Add default env variables
ADD env.yaml /container/environment/99-default/env.yaml

EXPOSE 8888
