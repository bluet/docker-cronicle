#!/bin/bash

ROOT_DIR=/opt/cronicle
CONF_DIR=$ROOT_DIR/conf
ETC_DIR=$ROOT_DIR/etc
BIN_DIR=$ROOT_DIR/bin

# Only run setup when setup needs to be done
if [ ! -f $ETC_DIR/.setup_done ]
then
  $BIN_DIR/control.sh setup

  mv $CONF_DIR/config.json $CONF_DIR/config.json.origin

  if [ -f $ETC_DIR/config.json.import ]
  then
    # Move in custom configuration
    cp $ETC_DIR/config.json.import $CONF_DIR/config.json
  else
    # Use default configuration with changes through ENV variables
	cat $CONF_DIR/config.json.origin | \
	  jq '.web_socket_use_hostnames = ${WEB_SOCKET_USE_HOSTNAMES:-0}' | \
	  jq '.server_comm_use_hostnames = ${SERVER_COMM_USE_HOSTNAMES:-0}' | \
	  jq '.WebServer.https_port = ${WEBSERVER_HTTPS_PORT:-3013}' | \
	  jq ".base_app_url = \"${BASE_APP_URL:-http://localhost:3012}\"" | \
	  > $CONF_DIR/config.json
  fi

  # Marking setup done
  touch $ETC_DIR/.setup_done
fi

# Run cronicle
NODE_EXTRA_CA_CERTS=/etc/ssl/certs/ca-certificates.crt $BIN_DIR/debug.sh --master
