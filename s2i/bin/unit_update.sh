#!/bin/dash
PHP_INI_PATH=${1:-/opt/app-root/etc/php/php.ini}
STI_SCRIPTS_PATH=${STI_SCRIPTS_PATH:-/usr/libexec/s2i/bin}
UNIT_CONTROL_SOCKET=${2:-/run/control.unit.sock}
UNIT_PID_FILE=${UNIT_PID_FILE:-/run/unit.pid}
UNIT_CONFIG_DIR=${3:-/opt/app-root/etc/unit}

while true
do
    inotifywait -m -r $UNIT_CONFIG_DIR
    conf-php $PHP_INI_PATH $UNIT_CONTROL_SOCKET $UNIT_CONFIG_DIR
    sleep 4
    #curl -X PUT --data-binary @$1--unix-socket $2 http://localhost/config
done