#!/bin/dash



if [ -f /etc/bashrc ]
then 
. /etc/bashrc
fi
if [ -f ~/.bashrc ]
then
. ~/.bashrc
fi


if [ -f /etc/php/php-fpm.conf ]
then
    cp /etc/php/php-fpm.conf /usr/local/etc/php-fpm.conf
    OPTS=" --fpm-config=/usr/local/etc/php-fpm.conf $OPTS"
fi
if [ -f /etc/php/php.ini ]
then
    cp /etc/php/php.ini /usr/local/etc/php.ini
    sed -i '/include_path/d' /usr/local/etc/php.ini
    echo "include_path=\".:$ROOT/include:/usr/share/php\"" >> /usr/local/etc/php.ini
    OPTS=" -c /usr/local/etc/php.ini $OPTS"
fi



echo "Starting server"
php-fpm $OPTS

