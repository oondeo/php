FROM php:5.6-fpm



RUN apt-get update && apt-get install -y --no-install-recommends \
        libmcrypt-dev libicu-dev libfreetype6-dev libpcre3-dev libxml2-dev libxslt1.1 libxslt1-dev \
        libjpeg62-turbo-dev libpng12-dev libsqlite3-dev curl libssl-dev libcurl4-openssl-dev \
        && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN docker-php-ext-install -j$(nproc) soap bcmath mcrypt intl iconv \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) mysql mysqli mcrypt xsl zip gd pdo pdo_mysql pdo_sqlite json curl dom hash bcmath gettext mbstring phar simplexml \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/local/etc/php/conf.d/*

ENV PHPREDIS_VERSION=2.2.7 APCU_VERSION=4.0.10 XDEBUG_VERSION=2.3.3

RUN pecl install apcu-$APCU_VERSION xdebug-$XDEBUG_VERSION \
    && pear install DB MDB2 Mail Mail_Mime Mail_mimeDecode Log  HTTP_Request2 XML_RPC2 Date \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/local/etc/php/conf.d/* /usr/src/php/ext/*

RUN cd /usr/src/php/ext \
    && curl -q https://codeload.github.com/phpredis/phpredis/tar.gz/$PHPREDIS_VERSION | tar -xz \
    && docker-php-ext-install phpredis-$PHPREDIS_VERSION && rm -rf /usr/local/etc/php/conf.d/* /usr/src/php/ext/*

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

ADD php.ini /usr/local/etc/php/php.ini

ADD start.sh /start.sh

ENV OPTS="" ROOT="/var/www"

VOLUME [ "/etc/php" ]

CMD [ "/start.sh" ]
