# Set defaults

ARG BASE_IMAGE="php:7.2-alpine"
ARG PACKAGIST_NAME="phan/phan"
ARG PHPQA_NAME="phan"
ARG VERSION="1.2.6"

# Build image

FROM ${BASE_IMAGE}
ARG COMPOSER_IMAGE
ARG PACKAGIST_NAME
ARG VERSION
ARG PHPQA_NAME
ARG VERSION
ARG BUILD_DATE
ARG VCS_REF
ARG IMAGE_NAME

# Install Tini - https://github.com/krallin/tini

RUN apk add --no-cache tini

# Install Phan - https://github.com/etsy/phan
# - dependency: pcntl on PHP 7.1.x
# - dependency: php-ast

RUN docker-php-ext-install pcntl \
    && apk add --no-cache --virtual .build-dependencies git autoconf gcc g++ make \
    && git clone -q https://github.com/nikic/php-ast.git \
    && cd php-ast \
    && phpize && ./configure && make install \
    && mv ./modules/ast.so /usr/local/lib/php/extensions/ast.so \
    && echo "extension=$(find /usr/local/lib/php/extensions/ -name ast.so)" > $PHP_INI_DIR/conf.d/ast.ini \
    && apk del .build-dependencies \
    && cd .. && rm -rf php-ast

COPY --from=composer:1.6.5 /usr/bin/composer /usr/bin/composer
RUN COMPOSER_HOME="/composer" composer global require --prefer-dist --no-progress --dev ${PACKAGIST_NAME}:${VERSION}
ENV PATH /composer/vendor/bin:${PATH}

# Add entrypoint script

COPY ./docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# Add image labels

LABEL org.label-schema.schema-version="1.0" \
      org.label-schema.vendor="phpqa" \
      org.label-schema.name="${PHPQA_NAME}" \
      org.label-schema.version="${VERSION}" \
      org.label-schema.build-date="${BUILD_DATE}" \
      org.label-schema.url="https://github.com/phpqa/${PHPQA_NAME}" \
      org.label-schema.usage="https://github.com/phpqa/${PHPQA_NAME}/README.md" \
      org.label-schema.vcs-url="https://github.com/phpqa/${PHPQA_NAME}.git" \
      org.label-schema.vcs-ref="${VCS_REF}" \
      org.label-schema.docker.cmd="docker run --rm --volume \${PWD}:/app --workdir /app ${IMAGE_NAME}"

# Package container

WORKDIR "/app"
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["phan"]
