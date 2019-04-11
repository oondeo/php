#!/bin/dash
PHP_INI_PATH=${1:-/opt/app-root/etc/php/php.ini}
STI_SCRIPTS_PATH=${STI_SCRIPTS_PATH:-/usr/libexec/s2i/bin}
CONTROL_SOCKET=${2:-/run/control.unit.sock}
# PID_FILE=${PID_FILE:-/run/unit.pid}
CONFIG_DIR=${3:-/opt/app-root/etc/unit}

while true
do
    sleep 10
    conf-php $PHP_INI_PATH $CONTROL_SOCKET $CONFIG_DIR
    inotifywait -e CREATE -r $CONFIG_DIR
    #curl -X PUT --data-binary @$1--unix-socket $2 http://localhost/config
done