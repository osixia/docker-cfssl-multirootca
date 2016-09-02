#!/bin/bash -e

# set -x (bash debug) if log level is trace
# https://github.com/osixia/docker-light-baseimage/blob/stable/image/tool/log-helper
log-helper level eq trace && set -x

CFSSL_MULTIROOTCA_HTTPS_PARAM=""
if [ "${CFSSL_MUTLTIROOTCA_HTTPS,,}" == "true" ]; then
  CFSSL_MULTIROOTCA_HTTPS_PARAM="-tls-cert ${CONTAINER_SERVICE_DIR}/multirootca/assets/certs/$CFSSL_MUTLTIROOTCA_HTTPS_CRT_FILENAME -tls-key ${CONTAINER_SERVICE_DIR}/multirootca/assets/certs/$CFSSL_MUTLTIROOTCA_HTTPS_KEY_FILENAME"
fi

exec multirootca -roots ${CONTAINER_SERVICE_DIR}/multirootca/assets/roots.conf $CFSSL_MULTIROOTCA_HTTPS_PARAM $CFSSL_MULTIROOTCA_CMD_ARGS
