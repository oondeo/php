FROM php:7.2-fpm-alpine
ARG PHP_VERSION=7.2
ARG PHPREDIS_VERSION=4.2.0 
ARG APCU_VERSION=5.1.16
ARG XDEBUG_VERSION=2.6.1
ARG MEMCACHED_VERSION=3.1.3
ARG PHP_EXTENSIONS="bcmath bz2 calendar ctype curl dom exif fileinfo gettext gmp hash iconv intl json ldap mbstring mysqli pcntl pdo pdo_mysql pdo_sqlite phar posix pspell readline recode session shmop simplexml snmp soap sockets tidy wddx xml xmlreader xmlrpc xmlwriter xsl zip"

ENV SUMMARY="PHP 7 image with standar modules"	\
    DESCRIPTION="The image use scripts and configurations compatible \
        with redhat openshift."

LABEL summary="$SUMMARY" \
      description="$DESCRIPTION" \
      io.k8s.description="$DESCRIPTION" \
      io.k8s.display-name="php 7" \
      io.openshift.expose-services="9000:fcgi" \
      io.openshift.tags="builder,php,php7,php72,php7.2,php-cgi,php-fcgi,php-cli" \
      com.redhat.component="php" \
      name="oondeo/php" \
      version="$PHP_VERSION" \
      release="2" \
      maintainer="OONDEO <info@oondeo.es>"

ENV \
    # DEPRECATED: Use above LABEL instead, because this will be removed in future versions.
    STI_SCRIPTS_URL=image:///usr/libexec/s2i \
    # Path to be used in other layers to place s2i scripts into
    STI_SCRIPTS_PATH=/usr/libexec/s2i/bin

ENV \
    # The $HOME is not set by default, but some applications needs this variable
    HOME=/opt/app-root/src \
    PATH=/opt/app-root/src/bin:/opt/app-root/bin:$STI_SCRIPTS_PATH:$PATH


# When bash is started non-interactively, to run a shell script, for example it
# looks for this variable and source the content of this file. This will enable
# the SCL for all scripts without need to do 'scl enable'.
ENV BASH_ENV=/opt/app-root/etc/scl_enable \
    ENV=/opt/app-root/etc/scl_enable \
    XDG_DATA_HOME=$HOME/.local/share \
    DEBIAN_FRONTEND=noninteractive \
    LANG=es_ES.UTF-8 LANGUAGE=es_ES.UTF-8 LC_ALL=es_ES.UTF-8 \
    PROMPT_COMMAND=". /opt/app-root/etc/scl_enable"

# Copy extra files to the image.
COPY ./root/root/ /

RUN apk add --no-cache tini dash bash && ln -s /usr/bin/dash /bin/dash
# Directory with the sources is set as the working directory so all STI scripts
# can execute relative to this path.
WORKDIR ${HOME}

# runDeps="$( \
# 		scanelf --needed --nobanner --format '%n#p' --recursive /usr/local \
# 			| tr ',' '\n' \
# 			| sort -u \
# 			| awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
# 	)" 
RUN apk add --no-cache libsodium && apk add --no-cache --virtual .builddeps unzip bzip2-dev curl-dev gmp-dev libressl-dev net-snmp-dev \
        libmcrypt-dev icu-dev freetype-dev pcre-dev libxml2-dev libxslt-dev openldap-dev recode-dev tidyhtml-dev \
        libjpeg-turbo-dev libpng-dev sqlite-dev curl gettext-dev unixodbc-dev aspell-dev  readline-dev libedit-dev \
    && ln -s /usr/src/php/ext/ /usr/local/include/php/ext/ext \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j "$(nproc)" gd \
    && docker-php-ext-install -j "$(nproc)" ${PHP_EXTENSIONS} \    
    && docker-php-source delete \
    && /usr/bin/install-deps \
    && apk del .builddeps \
    && rm -rf /tmp/* /var/tmp/* /usr/local/etc/php/conf.d/*

#    && mkdir -p  /usr/src/php/ext && cd /usr/src/php/ext \
#    && curl -sL https://github.com/phpredis/phpredis/archive/$PHPREDIS_VERSION.zip -o phpredis.zip \
#    && unzip phpredis.zip && rm phpredis.zip \
#    && docker-php-ext-install "$(nproc)" phpredis-$PHPREDIS_VERSION
#    && pear install DB MDB2 Mail Mail_Mime Mail_mimeDecode Log  HTTP_Request2 XML_RPC2 Date 
RUN apk add --no-cache --virtual .phpize-deps $PHPIZE_DEPS libmemcached-dev zlib-dev \
   && pecl install apcu-$APCU_VERSION xdebug-$XDEBUG_VERSION memcached-$MEMCACHED_VERSION phpredis-$PHPREDIS_VERSION \
   && /usr/bin/install-deps \
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

#install nodejs
RUN apk add --no-cache nodejs npm yarn openssh-client sshfs git curl

ENV PATH="/usr/libexec/s2i/bin:$PATH" \
    STI_SCRIPTS_PATH=/usr/libexec/s2i/bin

COPY s2i/bin $STI_SCRIPTS_PATH
COPY etc /opt/app-root/etc/

RUN /usr/bin/docker-footer

EXPOSE 9000

USER 1001

# ENTRYPOINT [ "/usr/libexec/s2i/bin/run" ]
ENTRYPOINT ["/sbin/tini", "-g" ,"--", "/usr/bin/container-entrypoint"]
CMD [ "$STI_SCRIPTS_PATH/run" ]