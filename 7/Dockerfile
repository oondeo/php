FROM php:7-fpm

ENV SUMMARY="Base image which allows using of source-to-image."	\
    DESCRIPTION="The s2i-core image provides any images layered on top of it \
with all the tools needed to use source-to-image functionality while keeping \
the image size as small as possible."

LABEL summary="$SUMMARY" \
      description="$DESCRIPTION" \
      io.k8s.description="$DESCRIPTION" \
      io.k8s.display-name="s2i core" \
      io.openshift.s2i.scripts-url=image:///usr/libexec/s2i \
      io.s2i.scripts-url=image:///usr/libexec/s2i \
      com.redhat.component="s2i-core-docker" \
      name="centos/s2i-core-centos7" \
      version="1" \
      release="1" \
      maintainer="OONDEO <info@oondeo.es>"

ENV \
    # DEPRECATED: Use above LABEL instead, because this will be removed in future versions.
    STI_SCRIPTS_URL=image:///usr/libexec/s2i \
    # Path to be used in other layers to place s2i scripts into
    STI_SCRIPTS_PATH=/usr/libexec/s2i \
    # The $HOME is not set by default, but some applications needs this variable
    HOME=/opt/app-root/src \
    PATH=/opt/app-root/src/bin:/opt/app-root/bin:$PATH


# When bash is started non-interactively, to run a shell script, for example it
# looks for this variable and source the content of this file. This will enable
# the SCL for all scripts without need to do 'scl enable'.
ENV BASH_ENV=/opt/app-root/etc/scl_enable \
    ENV=/opt/app-root/etc/scl_enable \
    PROMPT_COMMAND=". /opt/app-root/etc/scl_enable"

RUN apt-get update && apt-get install -y --no-install-recommends unzip \
        libmcrypt-dev libicu-dev libfreetype6-dev libpcre3-dev libxml2-dev libxslt1.1 libxslt1-dev \
        libjpeg62-turbo-dev libpng12-dev libsqlite3-dev curl libssl-dev libcurl4-openssl-dev \
        && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN docker-php-ext-install -j$(nproc) soap bcmath mcrypt intl iconv \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) mysqli mcrypt xsl zip gd pdo pdo_mysql pdo_sqlite json curl dom hash bcmath gettext mbstring phar simplexml \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/local/etc/php/conf.d/*

ENV PHPREDIS_VERSION=3.1.4 APCU_VERSION=5.1.5 XDEBUG_VERSION=2.5.5

RUN pecl install apcu-$APCU_VERSION xdebug-$XDEBUG_VERSION \
    && pear install DB MDB2 Mail Mail_Mime Mail_mimeDecode Log  HTTP_Request2 XML_RPC2 Date \
    && mkdir -p  /usr/src/php/ext && cd /usr/src/php/ext \
   && curl -sL https://github.com/phpredis/phpredis/archive/$PHPREDIS_VERSION.zip -o phpredis.zip \
   && unzip phpredis.zip && rm phpredis.zip \
   && docker-php-ext-install -j$(nproc) phpredis-$PHPREDIS_VERSION \
   && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/local/etc/php/conf.d/*

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
ADD docker.conf /usr/local/etc/php-fpm.d/docker.conf
ADD zz-docker.conf /usr/local/etc/php-fpm.d/zz-docker.conf

ADD start.sh /start.sh

ENV OPTS="" ROOT="/var/www"

VOLUME [ "/etc/php" ]

CMD [ "/start.sh" ]
