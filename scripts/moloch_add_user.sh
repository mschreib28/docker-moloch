#!/bin/sh
export NODE_EXTRA_CA_CERTS=/usr/local/share/ca-certificates/root-certificate/ca.crt
/data/moloch/bin/node /data/moloch/viewer/addUser.js -c /data/moloch/etc/config.ini "$@"
