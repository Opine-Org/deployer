# Composer Docker Container
FROM composer/composer:base
MAINTAINER Ryan Mahoney <ryan.mahoney@outlook.com>

ENV COMPOSER_VERSION 1.2.1

# Install Composer
RUN php /tmp/composer-setup.php --no-ansi --install-dir=/usr/local/bin --filename=composer --version=${COMPOSER_VERSION} && rm -rf /tmp/composer-setup.php

# Display version information.
RUN composer --version

COPY config/run.sh /root/run.sh
ENTRYPOINT ["/root/run.sh"]
