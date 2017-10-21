FROM php:5-fpm

ENV SUMMARY="PHP 5 image with standar modules"	\
    DESCRIPTION="The image use scripts and configurations compatible \
        with redhat openshift."

LABEL summary="$SUMMARY" \
      description="$DESCRIPTION" \
      io.k8s.description="$DESCRIPTION" \
      io.k8s.display-name="php 5" \
      io.openshift.s2i.scripts-url=image:///usr/libexec/s2i \
      io.s2i.scripts-url=image:///usr/libexec/s2i \
      com.redhat.component="php" \
      name="oondeo/php" \
      version="5" \
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
    XDG_DATA_HOME=$HOME/.local/share \
    DEBIAN_FRONTEND=noninteractive \
    LANG=es_ES.UTF-8 LANGUAGE=es_ES.UTF-8 LC_ALL=es_ES.UTF-8 \
    PROMPT_COMMAND=". /opt/app-root/etc/scl_enable"

# Copy extra files to the image.
COPY ./root/root/ /
COPY ./s2i/bin/ $STI_SCRIPTS_PATH

#Install tiny on debian 
ENV TINI_VERSION=v0.16.1
RUN cp /bin/sh /sh && apt-get update && apt-get install -y --no-install-recommends curl dash locales \
    && curl -o /sbin/tini -SLk https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini \
    && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
    && echo $LANG UTF-8 >> /etc/locale.gen \
    && locale-gen \     
    && chmod +x /sbin/tini && rm -rf /var/lib/apt/* /var/tmp/* /tmp/* /var/log/* 

# Directory with the sources is set as the working directory so all STI scripts
# can execute relative to this path.
WORKDIR ${HOME}

ENTRYPOINT ["/sbin/tini", "-g" ,"--", "container-entrypoint"]

RUN apt-get update && apt-get install -y --no-install-recommends libbz2-dev libzip-dev \
        libmcrypt-dev libicu-dev libfreetype6-dev libpcre3-dev libxml2-dev libxslt1.1 libxslt1-dev \
        libjpeg62-turbo-dev libpng12-dev libsqlite3-dev libssl-dev libcurl4-openssl-dev libgmp-dev \
        && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/log/* /usr/share/doc/* /usr/share/man/* /root/.cache

#included in php: mysqlnd curl 
ENV PHP_EXTENSIONS="soap iconv intl bz2 gmp mysql mysqli mcrypt xsl zip gd pdo pdo_mysql pdo_sqlite json dom hash bcmath gettext mbstring phar simplexml"
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h \
    && docker-php-ext-install -j$(nproc)  ${PHP_EXTENSIONS} \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/local/etc/php/conf.d/* /var/log/* /usr/share/doc/* /usr/share/man/* /root/.cache

ENV PHPREDIS_VERSION=3.1.4 APCU_VERSION=5.1.8 XDEBUG_VERSION=2.5.5

RUN pecl install apcu-$APCU_VERSION xdebug-$XDEBUG_VERSION redis-${PHPREDIS_VERSION} \
    && pear install DB MDB2 Mail Mail_Mime Mail_mimeDecode Log  HTTP_Request2 XML_RPC2 Date \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/local/etc/php/conf.d/* /var/log/* /usr/share/doc/* /usr/share/man/* /root/.cache

# RUN mkdir -p /usr/src/php/ext && cd /usr/src/php/ext \
#     && curl -q https://codeload.github.com/phpredis/phpredis/tar.gz/$PHPREDIS_VERSION | tar -xz \
#     && docker-php-ext-install -j$(nproc) phpredis-$PHPREDIS_VERSION && rm -rf /usr/local/etc/php/conf.d/*

# Install php tools (composer / phpunit)
RUN cd /tmp && \
    curl -sL https://getcomposer.org/composer.phar > composer.phar && \
    chmod +x composer.phar && \
    mv composer.phar /usr/local/bin/composer && \
    curl -sL https://phar.phpunit.de/phpunit.phar > phpunit.phar && \
    chmod +x phpunit.phar && \
    mv phpunit.phar /usr/local/bin/phpunit && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN apt-get update && apt-get install -y --no-install-recommends git \
       && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/log/* /usr/share/doc/* /usr/share/man/* /root/.cache

RUN mkdir -p /opt/app-root/etc/php /opt/app-root/etc/php-fpm.d
ENV PHP_INI_PATH="/opt/app-root/etc/php/php.ini" \
    PHP_FPM_PATH="/opt/app-root/etc/php-fpm.d" \
    PHP_LIB_PATH="/opt/app-root/lib/php" \
    OPTS=" --fpm-config=/usr/local/etc/php-fpm.conf -c \$PHP_INI_PATH "

ADD php.ini $PHP_INI_PATH
# ADD docker.conf /opt/app-root/etc/php-fpm.d/docker.conf
# ADD zz-docker.conf /opt/app-root/etc/php-fpm.d/zz-docker.conf
RUN mkdir -p ${PHP_LIB_PATH} \
    && mkdir -p $PHP_FPM_PATH \
    && { \
			echo '[global]'; \
			echo "include=$PHP_FPM_PATH/etc/php-fpm.d/*.conf"; \
    } | tee /usr/local/etc/php-fpm.d/user.conf \
    && sed -i '/include_path/d' $PHP_INI_PATH \
    && echo "include_path=\".:$HOME/app/include:$HOME/include:$PHP_LIB_PATH:/usr/local/lib/php:/usr/share/php\"" >> /opt/app-root/etc/php.ini


EXPOSE 9000



CMD [ "run" ]


# Reset permissions of modified directories and add default user
RUN useradd -u 1001 -r -g 0 -d ${HOME} -s /sbin/nologin \
      -c "Default Application User" default \
    && chown -R 1001:0 /opt/app-root \
    && mkdir -p ${HOME}/.pki/nssdb \
    && chown -R 1001:0 ${HOME}/.pki 
USER 1001    
VOLUME [ "/opt/app-root/etc", "/opt/app-root/lib" ,"/opt/app-root/src" ]