FROM debian:8 as lambic
LABEL maintainer="Sade"

ENV DEBIAN_FRONTEND noninteractive

# Install apache, PHP, and supplimentary programs. openssh-server, curl, and lynx-cur are for debugging the container.
RUN apt-get update && apt-get -y install \
    apache2 php5 php5-mysql libapache2-mod-php5 curl lynx-cur

# config Apache
RUN a2enmod rewrite

# Update the PHP.ini file, enable <? ?> tags and quieten logging.
RUN sed -i "s/short_open_tag = Off/short_open_tag = On/" /etc/php5/apache2/php.ini; \
    sed -i "s/error_reporting = .*$/error_reporting = E_ERROR | E_WARNING | E_PARSE/" /etc/php5/apache2/php.ini

# Manually set up the apache environment variables
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid

EXPOSE 80
EXPOSE 443

VOLUME ["/var/www", "/var/log/apache2", "/etc/apache2"]

# Copy this repo into place.
ADD www /var/www/default

# Update the default apache site with the config we created.
ADD apache-config.conf /etc/apache2/sites-enabled/000-default.conf

# By default start up apache in the foreground, override with /bin/bash for interative.
ENTRYPOINT ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]