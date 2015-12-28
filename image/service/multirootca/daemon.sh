#!/bin/bash -e

# get nodes from env var
ETCD_NODES=""
KEEPALIVED_CONFD_ETCD_NODES_TABLE=($KEEPALIVED_CONFD_ETCD_NODES)
for node in "${KEEPALIVED_CONFD_ETCD_NODES_TABLE[@]}"
do
  #host var contain a variable name, we access to the variable value and cast it to a table
  node_txt=${!node}

  # it's a node stored in a variable
  if [ -n "${node_txt}" ]; then
    ETCD_NODES="$ETCD_NODES -node ${node_txt}"

  # directly
  else
    ETCD_NODES="$ETCD_NODES -node ${node}"
  fi
done

# etcd certs
KEEPALIVED_CONFD_CLIENT_CAKEYS=""
if [ -n "${KEEPALIVED_CONFD_CLIENT_CAKEYS_FILENAME}" ]; then
  KEEPALIVED_CONFD_CLIENT_CAKEYS="-client-ca-keys /container/service/etcd/assets/certs/$KEEPALIVED_CONFD_CLIENT_CAKEYS_FILENAME"
fi

KEEPALIVED_CONFD_CLIENT_CERT=""
if [ -n "${KEEPALIVED_CONFD_CLIENT_CERT_FILENAME}" ]; then
  KEEPALIVED_CONFD_CLIENT_CERT="-client-cert /container/service/etcd/assets/certs/$KEEPALIVED_CONFD_CLIENT_CERT_FILENAME"
fi

KEEPALIVED_CONFD_CLIENT_KEY=""
if [ -n "${KEEPALIVED_CONFD_CLIENT_KEY_FILENAME}" ]; then
  KEEPALIVED_CONFD_CLIENT_KEY="-client-key /container/service/etcd/assets/certs/$KEEPALIVED_CONFD_CLIENT_KEY_FILENAME"

  chmod 600 /container/service/etcd/assets/certs/$KEEPALIVED_CONFD_CLIENT_KEY_FILENAME
fi

echo "exec confd $ETCD_NODES -interval $KEEPALIVED_CONFD_INTERVAL -log-level $KEEPALIVED_CONFD_LOG_LEVEL $KEEPALIVED_CONFD_CLIENT_CAKEYS $KEEPALIVED_CONFD_CLIENT_CERT $KEEPALIVED_CONFD_CLIENT_KEY"
exec confd $ETCD_NODES -interval $KEEPALIVED_CONFD_INTERVAL -log-level $KEEPALIVED_CONFD_LOG_LEVEL $KEEPALIVED_CONFD_CLIENT_CAKEYS $KEEPALIVED_CONFD_CLIENT_CERT $KEEPALIVED_CONFD_CLIENT_KEY
