ARG PHP_VERSION

FROM oxidesales/oxideshop-docker-php:$PHP_VERSION

ARG HOST_USER_ID
ARG HOST_USER_NAME
ARG HOST_GROUP_ID
ARG HOST_GROUP_NAME
ARG SMTP_HOST
ARG SMTP_PORT

COPY custom.ini /usr/local/etc/php/conf.d/zcustom.ini

# ionCube
RUN cd /tmp \
    && curl -o ioncube.tar.gz http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz \
    && tar -xvvzf ioncube.tar.gz \
    && MAJOR_PHP_VERSION=$(echo $PHP_VERSION | cut -d'.' -f1-2) \
    && mv ioncube/ioncube_loader_lin_$MAJOR_PHP_VERSION.so /usr/local/lib/php/extensions/* \
    && rm -Rf ioncube.tar.gz ioncube \
    && PHP_EXTENSION_PATH=$(php-config --extension-dir) \
    && echo "zend_extension=$PHP_EXTENSION_PATH/ioncube_loader_lin_$MAJOR_PHP_VERSION.so" > /usr/local/etc/php/conf.d/00_ioncube-ext.ini

# set sendmail for php to ssmtp
RUN printf "host mailpit\nport 1025" >> /etc/msmtprc

RUN groupadd -f -g $HOST_GROUP_ID $HOST_GROUP_NAME && \
    useradd -m -d /home/$HOST_USER_NAME -s /bin/bash -g $HOST_GROUP_ID -u $HOST_USER_ID $HOST_USER_NAME || true && \
    echo "$HOST_USER_NAME  ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    chown -R $HOST_USER_NAME:$HOST_GROUP_NAME /var/www/

# add via mounted volume
#RUN mkdir /home/$HOST_USER_NAME/.ssh && \
#    ssh-keyscan -t rsa github.com >> /home/$HOST_USER_NAME/.ssh/known_hosts

RUN apt-get update \
    && apt-get install -y libssl-dev \
    && apt-get install -y libicu-dev \
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-install intl ftp

# add composer global to PATH via .bashrc
RUN echo "export PATH=\"~/.composer/vendor/bin:$PATH\"" >> /home/${HOST_USER_NAME}/.bashrc

WORKDIR /var/www/
