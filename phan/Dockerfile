FROM php:7.1-alpine
MAINTAINER Bart Reunes <metalarend@gmail.com>

# Install Composer globally - https://github.com/composer/composer

ENV COMPOSER_HOME /composer
ENV COMPOSER_ALLOW_SUPERUSER 1
ENV PATH /composer/vendor/bin:$PATH

RUN curl https://getcomposer.org/installer -o /tmp/composer-setup.php \
    && curl https://composer.github.io/installer.sig -o /tmp/composer-setup.sig \
    && php -r "if (hash_file('SHA384', '/tmp/composer-setup.php') !== trim(file_get_contents('/tmp/composer-setup.sig'))) { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
    && php /tmp/composer-setup.php --no-ansi --install-dir=/usr/local/bin --filename=composer \
    && php -r "unlink('/tmp/composer-setup.php');" \
    && php -r "unlink('/tmp/composer-setup.sig');"

# Install Tini - https://github.com/krallin/tini

RUN apk add --update --no-cache tini \
    && rm -rf /var/cache/apk/* /var/tmp/* /tmp/*

# Install Phan - https://github.com/etsy/phan
# - dependency: pcntl on PHP 7.1.x
# - dependency: git
# - dependency: php-ast

RUN echo "memory_limit=-1" > $PHP_INI_DIR/conf.d/memory-limit.ini
RUN apk --update add --no-cache --virtual .build-dependencies git autoconf gcc g++ make \
    && cd /tmp \
    && git clone -q https://github.com/nikic/php-ast.git \
    && cd php-ast \
    && phpize && ./configure && make install \
    && mv ./modules/ast.so /usr/local/lib/php/extensions/ast.so \
    && apk del .build-dependencies \
    && rm -rf /tmp/* \
    && echo "extension=$(find /usr/local/lib/php/extensions/ -name ast.so)" > $PHP_INI_DIR/conf.d/ast.ini
RUN composer global require --dev etsy/phan

# Package container

VOLUME ["/app"]
WORKDIR "/app"
ENTRYPOINT ["/sbin/tini", "--", "phan"]
