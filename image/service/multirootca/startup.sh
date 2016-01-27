#!/bin/bash -e

# set -x (bash debug) if log level is trace
# https://github.com/osixia/docker-light-baseimage/blob/stable/image/tool/log-helper
log-helper level eq trace && set -x

# add bin
ln -sf ${CONTAINER_SERVICE_DIR}/multirootca/assets/multirootca /usr/local/bin/multirootca

FIRST_START_DONE="${CONTAINER_STATE_DIR}/docker-multirootca-first-start-done"
# container first start
if [ ! -e "$FIRST_START_DONE" ]; then

  # tls config
  if [ "${CFSSL_MUTLTIROOTCA_HTTPS,,}" == "true" ]; then
    log-helper info "Use HTTPS..."

    # generate a certificate and key with cfssl tool if LDAP_CRT and LDAP_KEY files don't exists
    # https://github.com/osixia/docker-light-baseimage/blob/stable/image/service-available/:cfssl/assets/tool/cfssl-helper
    cfssl-helper ${CFSSL_MULTIROOTCA_CFSSL_PREFIX} "${CONTAINER_SERVICE_DIR}/multirootca/assets/certs/$CFSSL_MUTLTIROOTCA_HTTPS_CRT_FILENAME" "${CONTAINER_SERVICE_DIR}/multirootca/assets/certs/$CFSSL_MUTLTIROOTCA_HTTPS_KEY_FILENAME" "${CONTAINER_SERVICE_DIR}/multirootca/assets/certs/ca.crt"

    [[ ! -d "/etc/ssl/certs/" ]] && mkdir -p /etc/ssl/certs/
    cat ${CONTAINER_SERVICE_DIR}/multirootca/assets/certs/$CFSSL_MUTLTIROOTCA_HTTPS_CRT_FILENAME >> /etc/ssl/certs/ca-certificates.crt

  fi

  append_to_file() {
    local TO_APPEND=$1
    echo "${TO_APPEND}" >> ${CONTAINER_SERVICE_DIR}/multirootca/assets/roots.conf
  }

  append_value_to_file() {
    local TO_PRINT=$1
    local VALUE=$2
    append_to_file "$TO_PRINT = $VALUE"
  }

  ca_info(){
    local to_print=$1

    for info in $(complex-bash-env iterate "$2")
    do
      if [ $(complex-bash-env isRow "${!info}") = true ]; then
        local key=$(complex-bash-env getRowKey "${!info}")
        local valueVarName=$(complex-bash-env getRowValueVarName "${!info}")

        if [ $(complex-bash-env isTable "${!valueVarName}") = true ] || [ $(complex-bash-env isRow "${!valueVarName}") = true ]; then
          ca_info "$to_print$key" "$valueVarName"
        else
          append_value_to_file "$to_print$key" "${!valueVarName}"
        fi
      fi
    done
  }

  for ca in $(complex-bash-env iterate CFSSL_MULTIROOTCA_ROOTS)
  do
    if [ $(complex-bash-env isRow "${!ca}") = true ]; then
      hostname=$(complex-bash-env getRowKey "${!ca}")
      info=$(complex-bash-env getRowValueVarName "${!ca}")

      append_to_file "[ ${hostname} ]"
      ca_info "" "$info"
    else
      append_to_file "[ ${!ca} ]"
    fi
  done

  touch $FIRST_START_DONE
fi

exit 0
