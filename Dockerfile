FROM php:5.6-fpm

RUN apt-get update && apt-get -y upgrade

RUN apt-get install -y \
  wget \
  snmp \
  zip \
  libmcrypt-dev \
  libcurl4-gnutls-dev \
  libxml2-dev \
  libpng-dev \
  libc-client-dev \
  libkrb5-dev \
  build-essential \
  firebird2.5-dev \
  libicu-dev \
  libldb-dev \
  libldap2-dev \
  libedit-dev \
  libsnmp-dev \
  libtidy-dev \
  libxslt-dev \
  sqlite3 \
  sqlite \
  libsqlite3-dev \
  libpq-dev \
  libmagickwand-dev \
  libmemcached-dev

RUN wget https://getcomposer.org/composer.phar && \
  mv composer.phar /usr/bin/composer && \
  chmod a+x /usr/bin/composer

RUN composer global require "laravel/installer"

ENV PATH="$PATH:/root/.composer/vendor/bin"

COPY build/build-php-modules.sh /

RUN chmod +x /build-php-modules.sh

RUN sh /build-php-modules.sh

RUN apt-get -y autoclean && apt-get -y autoremove && apt-get -y clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
