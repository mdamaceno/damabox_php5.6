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

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

RUN wget https://getcomposer.org/composer.phar && \
  mv composer.phar /usr/bin/composer && \
  chmod a+x /usr/bin/composer

COPY build/build-php-modules.sh /

RUN chmod +x /build-php-modules.sh

RUN sh /build-php-modules.sh

RUN apt-get install -y git sudo

RUN composer global require "laravel/installer"

ENV PATH="/root/.composer/vendor/bin:${PATH}"

# Install Node
ENV NVM_DIR="/usr/local/nvm"
ENV NVM_VERSION="0.33.2"
ENV NODE_VERSION="8.4.0"

RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v${NVM_VERSION}/install.sh | bash && \
  . $NVM_DIR/nvm.sh && \
  nvm install $NODE_VERSION && \
  nvm alias default $NODE_VERSION && \
  nvm use default

ENV NODE_PATH="${NVM_DIR}/v${NODE_VERSION}/lib/node_modules"

# Add user damabox
RUN adduser --disabled-password --gecos "" damabox && adduser damabox sudo && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Install Yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - && echo "deb http://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

RUN apt-get update && apt-get install -y yarn

USER damabox

RUN echo "export NVM_DIR=\"/usr/local/nvm\"" >> $HOME/.bashrc && echo "[ -s \"$NVM_DIR/nvm.sh\" ] && \. \"$NVM_DIR/nvm.sh\"" >> $HOME/.bashrc && echo "[ -s \"$NVM_DIR/bash_completion\" ] && \. \"$NVM_DIR/bash_completion\"" >> $HOME/.bashrc

# Install Laravel installer
RUN composer global require "laravel/installer"
ENV PATH="/home/damabox/.composer/vendor/bin:${PATH}"

ENV TERM=xterm

# Install phpunit
RUN sudo wget https://phar.phpunit.de/phpunit.phar
RUN sudo chmod a+x phpunit.phar && sudo mv phpunit.phar /usr/local/bin/phpunit && phpunit --version

# Clean up system
RUN sudo apt-get -y autoclean && sudo apt-get -y autoremove && sudo apt-get -y clean && sudo rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /app
