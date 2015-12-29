#!/bin/bash -e
# this script is run during the image build

# add bin
ln -s /container/service/multirootca/assets/multirootca /usr/local/bin/multirootca
