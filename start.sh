#!/bin/dash



if [ -f /etc/bashrc ]
then 
. /etc/bashrc
fi
if [ -f ~/.bashrc ]
then
. ~/.bashrc
fi


if [ -f /etc/php/fpm/php-fpm.conf ]
then
    OPTS=" --fpm-config=/etc/php/fpm/php-fpm.conf $OPTS"
fi
if [ -f /etc/php/php.ini ]
then
    sed -i '/include_path/d' /etc/php/php.ini
    echo "include_path=\".:$ROOT/include:/usr/share/php\"" >> /etc/php/php.ini
    OPTS=" -c /etc/php/php.ini $OPTS"
fi



echo "Starting server"
php-fpm $OPTS

