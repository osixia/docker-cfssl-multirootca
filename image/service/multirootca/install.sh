#!/bin/bash -e
# this script is run during the image build

apt-get -y update

echo "Install curl and ca-certificates"
LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
curl \
ca-certificates

# download multirootca
UARCH=$(uname -m)
echo "Architecture is ${UARCH}"

case "${UARCH}" in
    
    "x86_64")
        HOST_ARCH="amd64"
    ;;
    
    "arm64" | "aarch64")
        HOST_ARCH="arm64"
    ;;
    
    "armv7l" | "armv6l" | "armhf")
        HOST_ARCH="arm"
    ;;
    
    "i386")
        HOST_ARCH="386"
    ;;
    
    *)
        echo "Architecture not supported. Exiting."
        exit 1
    ;;
esac

echo "Going to use ${HOST_ARCH} cfssl binaries"

echo "Download cfssl ..."
echo "curl -o /usr/local/bin/multirootca -SL https://github.com/osixia/cfssl/releases/download/1.4.1/multirootca_linux-${HOST_ARCH}"
curl -o /usr/local/bin/multirootca -SL "https://github.com/osixia/cfssl/releases/download/1.4.1/multirootca_linux-${HOST_ARCH}"

chmod +x /usr/local/bin/multirootca

apt-get remove -y --purge --auto-remove curl ca-certificates \
apt-get clean \
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
