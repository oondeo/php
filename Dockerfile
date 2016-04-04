FROM php:fpm



ENV PHPREDIS_VERSION=php7



# Install mcrypc
RUN apt-get update && apt-get install -y --no-install-recommends \
        libmcrypt-dev libicu-dev libfreetype6-dev libpcre3-dev libxml2-dev \
        libjpeg62-turbo-dev libpng12-dev libsqlite3-dev curl \
        && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN docker-php-ext-install -j$(nproc) soap bcmath mcrypt intl iconv \  
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && pecl install apcu \
    && pear install MDB2 Mail Mail_Mime Mail_mimeDecode Log  HTTP_Request2 XML_RPC2 Date \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#    #&& curl -q https://codeload.github.com/phpredis/phpredis/tar.gz/$PHPREDIS_VERSION | tar -xz \
#RUN cd /usr/src/php/ext \
#    && curl -sL https://github.com/phpredis/phpredis/archive/php7.zip > phpredis.zip \
#    unzip phpredis.zip && rm phpredis.zip \
#    && docker-php-ext-install phpredis-$PHPREDIS_VERSION 

# Install php tools (composer / phpunit)
RUN cd /tmp && \
    wget https://getcomposer.org/composer.phar && \
    chmod +x composer.phar && \
    mv composer.phar /usr/local/bin/composer && \
    wget https://phar.phpunit.de/phpunit.phar && \
    chmod +x phpunit.phar && \
    mv phpunit.phar /usr/local/bin/phpunit && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#curl -L https://pecl.php.net/get/xdebug-2.3.3.tgz >> /usr/src/php/ext/xdebug.tgz \
#&& tar -xf /usr/src/php/ext/xdebug.tgz -C /usr/src/php/ext/ \
#&& rm /usr/src/php/ext/xdebug.tgz \
#&& docker-php-ext-install xdebug-2.3.3 

ADD start.sh /start.sh

USER www-data

ENV OPTS="" ROOT="/var/www"

VOLUME [ "/etc/php" ]

CMD [ "/start.sh" ]