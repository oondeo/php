FROM php:7.0-fpm



RUN apt-get update && apt-get install -y --no-install-recommends unzip \
        libmcrypt-dev libicu-dev libfreetype6-dev libpcre3-dev libxml2-dev libxslt1.1 libxslt1-dev \
        libjpeg62-turbo-dev libpng12-dev libsqlite3-dev curl libssl-dev libcurl4-openssl-dev \
        && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN docker-php-ext-install -j$(nproc) soap bcmath mcrypt intl iconv \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) mysqli mcrypt xsl zip gd pdo pdo_mysql pdo_sqlite json curl dom hash bcmath gettext mbstring phar simplexml \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/local/etc/php/conf.d/*

ENV PHPREDIS_VERSION=3.0.0 APCU_VERSION=5.1.5 APCU_BC_VERSION=1.0.3 XDEBUG_VERSION=2.4.0

RUN pecl install apcu-$APCU_VERSION apcu_bc-$APCU_BC_VERSION xdebug-$XDEBUG_VERSION \
    && pear install DB MDB2 Mail Mail_Mime Mail_mimeDecode Log  HTTP_Request2 XML_RPC2 Date \
    && mkdir -p  /usr/src/php/ext && cd /usr/src/php/ext \
   && curl -sL https://github.com/phpredis/phpredis/archive/$PHPREDIS_VERSION.zip -o phpredis.zip \
   && unzip phpredis.zip && rm phpredis.zip \
   && docker-php-ext-install phpredis-$PHPREDIS_VERSION \
   && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/local/etc/php/conf.d/*  /usr/src/php/ext/*

# Install php tools (composer / phpunit)
RUN cd /tmp && \
    curl -sL https://getcomposer.org/composer.phar > composer.phar && \
    chmod +x composer.phar && \
    mv composer.phar /usr/local/bin/composer && \
    curl -sL https://phar.phpunit.de/phpunit.phar > phpunit.phar && \
    chmod +x phpunit.phar && \
    mv phpunit.phar /usr/local/bin/phpunit && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN chown -R www-data /usr/local/etc

ADD php.ini /usr/local/etc/php/

ADD start.sh /start.sh

ENV OPTS="" ROOT="/var/www"

VOLUME [ "/etc/php" ]

CMD [ "/start.sh" ]
