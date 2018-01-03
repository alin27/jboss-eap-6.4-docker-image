#!/bin/bash

#
# Default usage: docker-entrypoint.sh start-jboss
#
# Default value of environment variables:
#     JBOSS_USER=jbossadmin
#     JBOSS_PASSWORD=jboss@dmin1
#
#     JBOSS_MODE=standalone
#     JBOSS_CONFIG=standalone.xml
#

# set -e

export JBOSS_HOME=$HOME/EAP-6.4.0/jboss-eap-6.4
export JBOSS_CLI=$JBOSS_HOME/bin/jboss-cli.sh
export PATH=/home/jboss/EAP-6.4.0/jboss-eap-6.4/bin:$PATH


#
# Determine JBoss configuration (parse environment variables)
#
if [ -z "$JBOSS_USER" ]; then
    JBOSS_USER=jbossadmin
fi
if [ -z "$JBOSS_PASSWORD" ]; then
    JBOSS_PASSWORD=jboss@dmin1
fi
if [ -z "$JBOSS_MODE" ]; then
    JBOSS_MODE=standalone
fi
if [ -z "$JBOSS_CONFIG" ]; then
    JBOSS_CONFIG=$JBOSS_MODE.xml
fi
echo "Using JBOSS_MODE=$JBOSS_MODE and JBOSS_CONFIG=$JBOSS_CONFIG"


if [ $JBOSS_MODE != "domain" ] && [ $JBOSS_MODE != "standalone" ]; then
    echo "JBOSS_MODE should be domain or standalone"
    exit 1
fi


function wait_for_server() {
    STARTUP_WAIT=30
    count=0

    until `$JBOSS_CLI -c "ls /deployment" &> /dev/null`; do
        sleep 1
        let count=$count+1;

        if [ $count -gt $STARTUP_WAIT ] ; then
            break
        fi
    done

    if [ $count -gt $STARTUP_WAIT ] ; then
        echo "JBoss startup timed out"
        cat /var/log/jboss/console.log
        exit 1
    fi
}


#
# Start JBoss EAP server
#
echo "=> Starting JBoss EAP server"
exec nohup $JBOSS_HOME/bin/$JBOSS_MODE.sh -b 0.0.0.0 -bmanagement 0.0.0.0 -c $JBOSS_CONFIG > /var/log/jboss/console.log 2>&1 &

echo "=> Waiting for the server to boot"
wait_for_server

echo "=> JBoss EAP server startup complete"
