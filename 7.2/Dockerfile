ARG PHP_VER=7.2 
ARG NODE_VER=10
# This is going to be a multi-stage build. The main benefit I've found of a multi-stage build is that the final image
# is very minimal in terms of the number of layers and overall image size. Which, in theory, should mean a more
# efficient overall experience.

FROM bitnami/node:${NODE_VER} as node

# First up, we need the non-prod version of the Bitnami PHP-FPM container that you need to build xDebug for.
FROM bitnami/php-fpm:$PHP_VER

# We need to install some build tools.
# Initially, I thought that these would be part of the non-prod container, but seems not.
# It is entirely possible I've misunderstood something. If so, help me correct this!!!
# I am also installing memcached extension which requires additional shared libraries.
RUN install_packages \
    build-essential autoconf ca-certificates pkg-config \
    libmemcached-dev libmemcached11 libmemcachedutil2 libhashkit2 zlib1g-dev \
    build-essential ca-certificates curl ghostscript git imagemagick libbz2-1.0 \
    libc6 libgcc1 libncurses5 libreadline7 libsqlite3-0 libssl1.1 libstdc++6 libtinfo5 pkg-config unzip wget zlib1g

# We are going to use PECL to install xDebug, as well as some additional extensions.
RUN \
    pecl install \
        igbinary \
        memcached \
        msgpack \
        pdo_dblib \
        redis \
        timecop-beta \
        timezonedb \
        xdebug

# So. That's the build of all the extensions.

# Now we need to build our minimal production ready container.

# To do that, we are doing a multi-stage build.


# So. The next step is to use the production ready version of PHP-FPM.
# Make sure you use the same version of the -prod as you did above. Otherwise, you will have built the extensions
# with the wrong ABI and then there will be tears when things don't work.


# RUN install_packages libmemcached11 libmemcachedutil2 libhashkit2 libsybdb5
# Copy dependant shared libraries.
# I found this using trial and error. Each extension could have its own dependant binary libraries.
# If the build container has them, then they can just be copied. If not, they they would need to be installed as part
# of the install_packages command.

COPY --from=node /opt/bitnami/* /opt/bitnami/
# COPY --from=builder \
#     /usr/lib/x86_64-linux-gnu/libmemcached*.so.*.*.* \
#     /usr/lib/x86_64-linux-gnu/libsybdb.so.*.*.* \
#     /usr/lib/x86_64-linux-gnu/

# Make symlinks for shared dependant libraries.
# RUN \
#     ln -sf /usr/lib/x86_64-linux-gnu/libmemcached.so.11.0.0 /usr/lib/x86_64-linux-gnu/libmemcached.so.11.0 && \
#     ln -sf /usr/lib/x86_64-linux-gnu/libmemcached.so.11.0.0 /usr/lib/x86_64-linux-gnu/libmemcached.so.11 && \
#     ln -sf /usr/lib/x86_64-linux-gnu/libmemcached.so.11.0.0 /usr/lib/x86_64-linux-gnu/libmemcached.so && \
#     ln -sf /usr/lib/x86_64-linux-gnu/libmemcachedutil.so.2.0.0 /usr/lib/x86_64-linux-gnu/libmemcachedutil.so.2.0 && \
#     ln -sf /usr/lib/x86_64-linux-gnu/libmemcachedutil.so.2.0.0 /usr/lib/x86_64-linux-gnu/libmemcachedutil.so.2 && \
#     ln -sf /usr/lib/x86_64-linux-gnu/libmemcachedutil.so.2.0.0 /usr/lib/x86_64-linux-gnu/libmemcachedutil.so && \
#     ln -sf /usr/lib/x86_64-linux-gnu/libsybdb.so.5.0.0 /usr/lib/x86_64-linux-gnu/libsybdb.so.5.0 && \
#     ln -sf /usr/lib/x86_64-linux-gnu/libsybdb.so.5.0.0 /usr/lib/x86_64-linux-gnu/libsybdb.so.5 && \
#     ln -sf /usr/lib/x86_64-linux-gnu/libsybdb.so.5.0.0 /usr/lib/x86_64-linux-gnu/libsybdb.so

# Copy the built extensions. I suppose this is the clever bit. Taking the production container and copying binaries
# from the builder container. No build tools, no temp/junk/artefacts. Just the required binaries. Just one of the
# very useful uses of multi-stage builds.
# COPY --from=builder \
#     /opt/bitnami/php/lib/php/extensions/igbinary.so \
#     /opt/bitnami/php/lib/php/extensions/memcached.so \
#     /opt/bitnami/php/lib/php/extensions/msgpack.so \
#     /opt/bitnami/php/lib/php/extensions/pdo_dblib.so \
#     /opt/bitnami/php/lib/php/extensions/redis.so \
#     /opt/bitnami/php/lib/php/extensions/timecop.so \
#     /opt/bitnami/php/lib/php/extensions/timezonedb.so \
#     /opt/bitnami/php/lib/php/extensions/xdebug.so \
#     /opt/bitnami/php/lib/php/extensions/

ENV PATH="/usr/libexec/s2i/bin:/opt/bitnami/node/bin:/opt/bitnami/php/bin:$PATH" \
    STI_SCRIPTS_PATH=/usr/libexec/s2i

ADD s2i/bin $STI_SCRIPTS_PATH

RUN cd /opt/bitnami/php/bin && curl -s https://getcomposer.org/installer | php \
    && curl -sL -o phpunit https://phar.phpunit.de/phpunit-7.phar && chmod +x phpunit

ENTRYPOINT [ "/usr/libexec/s2i/bin/run" ]

# And that's it really.

# Initially, there was no simple way to get the necessary ini entries in, but recently, Bitnami updated their build
# environment to support the '--with-config-file-scan-dir' option, so that means we can now mount a directory of
# ini files into the container rather that needing to bake them into the image.
#
# The Bitnami images that now support the scan directory option are 7.2.3-r2, 7.1.15-r2, 7.0.28-r2, and 5.6.34-r2.

#Application is installed in /app