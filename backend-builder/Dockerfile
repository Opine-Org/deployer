FROM php:7.0-cli

ENV COMPOSER_VERSION 1.2.1

# install composer
RUN php -r "copy('https://getcomposer.org/installer', '/tmp/composer-setup.php');"
RUN php -r "if (hash_file('SHA384', 'composer-setup.php') === 'e115a8dc7871f15d853148a7fbac7da27d6c0030b848d9b3dc09e2a0388afed865e6a3d6b3c0fad45c48e2b5fc1196ae') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
RUN php /tmp/composer-setup.php --no-ansi --install-dir=/usr/local/bin --filename=composer --version=${COMPOSER_VERSION} && rm -rf /tmp/composer-setup.php
RUN php -r "unlink('/tmp/composer-setup.php');"

# composer wants these folders
RUN mkdir /var/www
RUN mkdir /var/www/.composer
RUN mkdir /var/www/.composer/cache
RUN chown www-data /var/www --recursive
RUN chgrp www-data /var/www --recursive

COPY config/run.sh /root/run.sh
ENTRYPOINT [ "/root/run.sh" ]
