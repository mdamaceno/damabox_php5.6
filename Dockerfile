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

# Install Composer
RUN wget https://getcomposer.org/composer.phar && \
  mv composer.phar /usr/bin/composer && \
  chmod a+x /usr/bin/composer

RUN ln -s /usr/lib/x86_64-linux-gnu/libldap.so /usr/lib/libldap.so \
  && ln -s /usr/lib/x86_64-linux-gnu/liblber.so /usr/lib/liblber.so

# Install PHP extensions
RUN docker-php-ext-install -j$(nproc) bcmath
RUN docker-php-ext-install -j$(nproc) calendar
RUN docker-php-ext-install -j$(nproc) ctype
RUN docker-php-ext-install -j$(nproc) curl
RUN docker-php-ext-install -j$(nproc) dba
RUN docker-php-ext-install -j$(nproc) dom
RUN docker-php-ext-install -j$(nproc) exif
RUN docker-php-ext-install -j$(nproc) fileinfo
RUN docker-php-ext-install -j$(nproc) gd
RUN docker-php-ext-install -j$(nproc) gettext
RUN docker-php-ext-install -j$(nproc) hash
RUN docker-php-ext-install -j$(nproc) iconv
RUN docker-php-ext-install -j$(nproc) interbase
RUN docker-php-ext-install -j$(nproc) intl
RUN docker-php-ext-install -j$(nproc) json
RUN docker-php-ext-install -j$(nproc) ldap
RUN docker-php-ext-install -j$(nproc) mbstring
RUN docker-php-ext-install -j$(nproc) mcrypt
RUN docker-php-ext-install -j$(nproc) mysqli
RUN docker-php-ext-install -j$(nproc) opcache
RUN docker-php-ext-install -j$(nproc) pdo
RUN docker-php-ext-install -j$(nproc) pdo_firebird
RUN docker-php-ext-install -j$(nproc) pdo_mysql
RUN docker-php-ext-install -j$(nproc) pdo_pgsql
RUN docker-php-ext-install -j$(nproc) pdo_sqlite
# RUN docker-php-ext-install -j$(nproc) phar
RUN docker-php-ext-install -j$(nproc) posix
RUN docker-php-ext-install -j$(nproc) readline
RUN docker-php-ext-install -j$(nproc) shmop
RUN docker-php-ext-install -j$(nproc) simplexml
RUN docker-php-ext-install -j$(nproc) snmp
RUN docker-php-ext-install -j$(nproc) soap
RUN docker-php-ext-install -j$(nproc) sockets
RUN docker-php-ext-install -j$(nproc) tidy
RUN docker-php-ext-install -j$(nproc) xml
RUN docker-php-ext-install -j$(nproc) xsl
RUN docker-php-ext-install -j$(nproc) zip

RUN printf "\n" | pecl install imagick-beta xdebug mongodb

RUN docker-php-ext-enable imagick xdebug mongodb

RUN apt-get install -y git sudo vim nano

RUN composer global require "laravel/installer"

ENV PATH="/root/.composer/vendor/bin:${PATH}"

# Install Node
# ENV NVM_DIR="/usr/local/nvm"
# ENV NVM_VERSION="0.33.6"
# ENV NODE_VERSION="8.8.1"

# RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v${NVM_VERSION}/install.sh | bash && \
#   . $NVM_DIR/nvm.sh && \
#   nvm install $NODE_VERSION && \
#   nvm alias default $NODE_VERSION && \
#   nvm use default

# ENV NODE_PATH="${NVM_DIR}/v${NODE_VERSION}/lib/node_modules"

# Add user damabox
RUN adduser --disabled-password --gecos "" damabox && adduser damabox sudo && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Install Yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - && echo "deb http://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

RUN apt-get update && apt-get install -y yarn

USER damabox

RUN /bin/bash -l -c 'cd $HOME && curl -L https://git.io/n-install | bash -s -- -y'

# RUN echo "export NVM_DIR=\"/usr/local/nvm\"" >> $HOME/.bashrc && echo "[ -s \"$NVM_DIR/nvm.sh\" ] && \. \"$NVM_DIR/nvm.sh\"" >> $HOME/.bashrc && echo "[ -s \"$NVM_DIR/bash_completion\" ] && \. \"$NVM_DIR/bash_completion\"" >> $HOME/.bashrc

# Install Laravel installer
RUN composer global require "laravel/installer"
ENV PATH="/home/damabox/.composer/vendor/bin:${PATH}"

# Install phpunit
RUN sudo wget https://phar.phpunit.de/phpunit-5.7.phar -O phpunit.phar
RUN sudo chmod a+x phpunit.phar && sudo mv phpunit.phar /usr/local/bin/phpunit && phpunit --version

ENV TERM=xterm

# Bash customization
RUN echo "STARTCOLOR='\e[0;36m'" >> $HOME/.bashrc
RUN echo 'ENDCOLOR="\e[0m"' >> $HOME/.bashrc
RUN echo 'export PS1="\n\[$STARTCOLOR\]\u@\h:\! <\t> \w\n\$ \[$ENDCOLOR\]"' >> $HOME/.bashrc

# Clean up system
RUN sudo apt-get -y autoclean && sudo apt-get -y autoremove && sudo apt-get -y clean && sudo rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /app
