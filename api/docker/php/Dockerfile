ARG PHP_VERSION=8.1.15

FROM php:${PHP_VERSION}-fpm-alpine

#persistent / runtime deps
RUN apk add --no-cache \
		acl \
		file \
		gettext \
		mysql-client \
		zip \
	;

ARG APCU_VERSION=5.1.12
RUN set -eux; \
	apk add --no-cache --virtual .build-deps \
		$PHPIZE_DEPS \
		icu-dev \
		libzip-dev \
		libintl \
		mysql-dev \
		zlib-dev \
    && pecl install xdebug-3.1.5 \
    && docker-php-ext-enable xdebug \
	; 
	RUN docker-php-ext-install \
		intl \
		pdo_mysql \
		zip \
		bcmath \
	; \
	\
    # Install php-ext-gmp
    \
    apk add --no-cache --no-progress --virtual BUILD_DEPS_PHP_GMP gmp-dev \
    && apk add --no-cache --no-progress gmp \
    && docker-php-ext-install gmp; \
    \
	pecl install \
		apcu-${APCU_VERSION} \
	; \
	pecl clear-cache; \
	docker-php-ext-enable \
		apcu \
		opcache \
	; \
	\
	runDeps="$( \
		scanelf --needed --nobanner --format '%n#p' --recursive /usr/local/lib/php/extensions \
			| tr ',' '\n' \
			| sort -u \
			| awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
	)"; \
	apk add --no-cache --virtual .api-phpexts-rundeps $runDeps; \
	\
	apk del .build-deps BUILD_DEPS_PHP_GMP

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
COPY docker/php/php.ini /usr/local/etc/php/php.ini
RUN echo "xdebug.client_host=$(/sbin/ip route|awk '/default/ { print $3 }')" >> /usr/local/etc/php/php.ini

# https://getcomposer.org/doc/03-cli.md#composer-allow-superuser
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN set -eux; \
	php -dmemory_limit=-1 /usr/bin/composer clear-cache
ENV PATH="${PATH}:/root/.composer/vendor/bin"

WORKDIR /srv/api

# build for dev
ARG APP_ENV=dev

# prevent the reinstallation of vendors at every changes in the source code
COPY composer.json composer.lock ./
RUN set -eux; \
	php -dmemory_limit=-1 /usr/bin/composer install --prefer-dist --no-autoloader --no-scripts --no-progress --no-suggest; \
	php -dmemory_limit=-1 /usr/bin/composer clear-cache

COPY . ./

RUN set -eux; \
	mkdir -p var/cache var/log; \
	php -dmemory_limit=-1 /usr/bin/composer dump-autoload --classmap-authoritative --no-dev; \
	chmod +x bin/console; sync
VOLUME /srv/api/var

COPY docker/php/docker-entrypoint.sh /usr/local/bin/docker-entrypoint
RUN chmod +x /usr/local/bin/docker-entrypoint

# fix xdebug log error permission
RUN touch /var/log/xdebug.log; \
    chmod 666 /var/log/xdebug.log

ENTRYPOINT ["docker-entrypoint"]
CMD ["php-fpm"]
