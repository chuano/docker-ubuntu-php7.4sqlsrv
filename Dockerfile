FROM ubuntu:18.04

ENV ACCEPT_EULA=Y

# Fix debconf warnings upon build
ARG DEBIAN_FRONTEND=noninteractive

#Upgrade
RUN apt-get update && apt-get -y dist-upgrade

# Ondrej
RUN apt -y install software-properties-common \
    && add-apt-repository ppa:ondrej/php \
    && apt-get update

# Compile and system dependencies
RUN apt-get -y install apt-utils apt-transport-https curl make gnupg


# Apache & PHP
RUN apt-get -y install apache2 libapache2-mod-php7.4 php-pear php-dev \
    php7.4-curl php7.4-gd php7.4-mbstring php7.4-mysql php7.4-intl php7.4-xml php7.4-zip php7.4-soap

# MS ODBC
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/ubuntu/18.04/prod.list > /etc/apt/sources.list.d/mssql-release.list
RUN apt-get update \
    && apt-get -y --no-install-recommends install mssql-tools msodbcsql17 unixodbc-dev \
    && echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile \
    && echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc \
    && pecl install sqlsrv-5.7.1preview \
    && pecl install pdo_sqlsrv-5.7.1preview \
    && echo "extension=pdo_sqlsrv.so" | tee /etc/php/7.4/mods-available/pdo_sqlsrv.ini \
    && echo "extension=sqlsrv.so" | tee /etc/php/7.4/mods-available/sqlsrv.ini \
    && phpenmod sqlsrv \
    && phpenmod pdo_sqlsrv

#SSL
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/ssl-cert-snakeoil.key \
    -out /etc/ssl/certs/ssl-cert-snakeoil.pem -subj "/C=AT/ST=Vienna/L=Vienna/O=Security/OU=Development/CN=example.com"
RUN a2enmod ssl
RUN a2ensite default-ssl

# Extensions
RUN a2enmod rewrite

EXPOSE 443

WORKDIR /var/www/html

CMD apachectl -D FOREGROUND
