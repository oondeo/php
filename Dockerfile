FROM php:fpm



ENV PHPREDIS_VERSION=php7 COMPOSER_SHA='7228c001f88bee97506740ef0888240bd8a760b046ee16db8f4095c0d8d525f2367663f22a46b48d072c816e7fe19959'



# Install mcrypc
RUN apt-get update && apt-get install -y --no-install-recommends \
        libmcrypt-dev libicu-dev libfreetype6-dev libpcre3-dev libxml2-dev \
        libjpeg62-turbo-dev libpng12-dev libsqlite3-dev curl libssl-dev libcurl4-openssl-dev \
        && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN docker-php-ext-install -j$(nproc) soap bcmath mcrypt intl iconv \  
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd pdo pdo_mysql pdo_sqlite json curl dom hash bcmath gettext mbstring phar simplexml \
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
    php -r "readfile('https://getcomposer.org/installer');" > composer-setup.php && \
    php -r "if (hash('SHA384', file_get_contents('composer-setup.php')) === "$COMPOSER_SHA") { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');" && \
    curl -sL https://phar.phpunit.de/phpunit.phar > phpunit.phar && \
    chmod +x phpunit.phar && \
    mv phpunit.phar /usr/local/bin/phpunit && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN chown -R www-data /usr/local/etc

#curl -L https://pecl.php.net/get/xdebug-2.3.3.tgz >> /usr/src/php/ext/xdebug.tgz \
#&& tar -xf /usr/src/php/ext/xdebug.tgz -C /usr/src/php/ext/ \
#&& rm /usr/src/php/ext/xdebug.tgz \
#&& docker-php-ext-install xdebug-2.3.3 

ADD start.sh /start.sh

USER www-data

ENV OPTS="" ROOT="/var/www"

VOLUME [ "/etc/php" ]

CMD [ "/start.sh" ]