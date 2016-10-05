FROM php:7.1-fpm-alpine

RUN apk add --no-cache --update unzip \
        libmcrypt-dev icu-dev freetype-dev pcre-dev libxml2-dev libxslt-dev \
        libjpeg-turbo-dev libpng-dev sqlite-dev curl openssl-dev gettext-dev

RUN docker-php-ext-install -j$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) soap bcmath mcrypt intl iconv \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) mysqli mcrypt xsl zip gd pdo pdo_mysql pdo_sqlite json curl dom hash bcmath gettext mbstring phar simplexml \
    && rm -rf /tmp/* /var/tmp/* /usr/local/etc/php/conf.d/*

ENV PHPREDIS_VERSION=3.0.0 APCU_VERSION=5.1.5 APCU_BC_VERSION=1.0.3 XDEBUG_VERSION=2.4.1

RUN apk add --no-cache --virtual .phpize-deps $PHPIZE_DEPS \
   && pecl install apcu-$APCU_VERSION apcu_bc-$APCU_BC_VERSION xdebug-$XDEBUG_VERSION \
   && pear install DB MDB2 Mail Mail_Mime Mail_mimeDecode Log  HTTP_Request2 XML_RPC2 Date \
   && mkdir -p  /usr/src/php/ext && cd /usr/src/php/ext \
   && curl -sL https://github.com/phpredis/phpredis/archive/$PHPREDIS_VERSION.zip -o phpredis.zip \
   && unzip phpredis.zip && rm phpredis.zip \
   && docker-php-ext-install -j$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) phpredis-$PHPREDIS_VERSION \
   && apk del .phpize-deps && rm -rf  /tmp/* /var/tmp/* /usr/local/etc/php/conf.d/*

# Install php tools (composer / phpunit)
RUN cd /tmp && \
    curl -sL https://getcomposer.org/composer.phar > composer.phar && \
    chmod +x composer.phar && \
    mv composer.phar /usr/local/bin/composer && \
    curl -sL https://phar.phpunit.de/phpunit.phar > phpunit.phar && \
    chmod +x phpunit.phar && \
    mv phpunit.phar /usr/local/bin/phpunit && \
    rm -rf /tmp/* /var/tmp/*

RUN chown -R www-data /usr/local/etc

ADD php.ini /usr/local/etc/php/

ADD start.sh /start.sh

ENV OPTS="" ROOT="/var/www"

VOLUME [ "/etc/php" ]

CMD [ "/start.sh" ]
