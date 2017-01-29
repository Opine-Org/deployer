FROM ubuntu:16.04

RUN apt-get update
RUN apt-get -y install curl

# nodejs install
RUN curl https://deb.nodesource.com/setup_6.x -o /root/node.sh
RUN chmod +x /root/node.sh
RUN /root/node.sh
RUN apt-get install -y nodejs

RUN mkdir /var/www
RUN chown www-data /var/www --recursive
RUN chgrp www-data /var/www --recursive

COPY config/run.sh /root/run.sh

ENTRYPOINT ["/root/run.sh"]
