#!/bin/bash -e
# this script is run during the image build

# override the keepalived image config file with the confd template
ln -sf /container/service/confd/assets/templates/keepalived.tmpl /container/service/keepalived/assets/keepalived.conf
