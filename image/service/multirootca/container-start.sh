#!/bin/bash -e

FIRST_START_DONE="/etc/docker-multirootca-first-start-done"

# container first start
if [ ! -e "$FIRST_START_DONE" ]; then

  # tls config
  if [ "${CFSSL_MUTLTIROOTCA_HTTPS,,}" == "true" ]; then
    echo "Use HTTPS"
    cfssl-helper multirootca "/container/service/multirootca/assets/certs/$CFSSL_MUTLTIROOTCA_HTTPS_CRT_FILENAME" "/container/service/multirootca/assets/certs/$CFSSL_MUTLTIROOTCA_HTTPS_KEY_FILENAME" "/container/service/multirootca/assets/certs/ca.crt"
  fi

  append_to_file() {
    local TO_APPEND=$1
    echo "${TO_APPEND}" >> /container/service/multirootca/assets/roots.conf
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
