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
    cfssl-helper ${CFSSL_MULTIROOTCA_CFSSL_PREFIX} "${CONTAINER_SERVICE_DIR}/multirootca/assets/certs/$CFSSL_MUTLTIROOTCA_HTTPS_CRT_FILENAME" "${CONTAINER_SERVICE_DIR}/multirootca/assets/certs/$CFSSL_MUTLTIROOTCA_HTTPS_KEY_FILENAME" "${CONTAINER_SERVICE_DIR}/multirootca/assets/certs/ca.crt"
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
        local value=$(complex-bash-env getRowValue "${!info}")

        if [ $(complex-bash-env isTable "$value") = true ] || [ $(complex-bash-env isRow "$value") = true ]; then
          ca_info "$to_print$key" "$value"
        else
          append_value_to_file "$to_print$key" "$value"
        fi
      fi
    done
  }

  for ca in $(complex-bash-env iterate "${CFSSL_MULTIROOTCA_ROOTS}")
  do
    if [ $(complex-bash-env isRow "${!ca}") = true ]; then
      hostname=$(complex-bash-env getRowKey "${!ca}")
      info=$(complex-bash-env getRowValue "${!ca}")

      append_to_file "[ ${hostname} ]"
      ca_info "" "$info"
    else
      append_to_file "[ ${ca} ]"
    fi
  done

  touch $FIRST_START_DONE
fi

exit 0
