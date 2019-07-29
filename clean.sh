#!/bin/bash
docker-php-source delete 
apt-mark auto '.*' > /dev/null 
 [ -z "$savedAptMark" ] || apt-mark manual $savedAptMark 
find /usr/local -type f -executable -exec ldd '{}' ';' \
		| awk '/=>/ { print $(NF-1) }' \
		| sort -u \
		| xargs -r dpkg-query --search \
		| cut -d: -f1 \
		| sort -u \
		| xargs -r apt-mark manual 
apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false 
rm -rf /tmp/* /var/tmp/* /usr/src/php/ext/* /usr/local/php/* /usr/local/etc/php/conf.d/* /var/lib/apt/*