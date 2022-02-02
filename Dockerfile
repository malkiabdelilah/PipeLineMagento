###############################################################################################
# Dockerfile for apache image initialization
###############################################################################################

FROM php:7.4.0-apache

LABEL  (Jaouad EL HAMMOUMI) <jaouad.elhammoumi@gmail.com>

ENV APACHE_DOCUMENT_ROOT /var/www/html

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# 3. mod_rewrite for URL rewrite and mod_headers for .htaccess extra headers like Access-Control-Allow-Origin-
RUN a2enmod rewrite headers

# Install System Dependencies

RUN apt-get update \
	&& DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
	software-properties-common \
	&& apt-get update \
	&& DEBIAN_FRONTEND=noninteractive apt-get install -y \
	libfreetype6-dev \
	libicu-dev \
	libssl-dev \
	libjpeg62-turbo-dev \
	libmcrypt-dev \
	libedit-dev \
	libedit2 \
	libxslt1-dev \
	libzip-dev \
	apt-utils \
	gnupg \
	redis-tools \
	mariadb-client \
	git \
	vim \
	wget \
	curl \
	lynx \
	psmisc \
	unzip \
	tar \
	cron \
	bash-completion \
	&& apt-get clean

# Install Magento Dependencies

RUN apt-get install -y libonig-dev

RUN docker-php-ext-configure \
  	gd --with-freetype --with-jpeg \
  	&& docker-php-ext-install \
  	opcache \
  	gd \
  	bcmath \
  	intl \
  	mbstring \
  	pdo_mysql \
  	soap \
  	xsl \
  	zip \
	sockets
	

# Install oAuth

RUN apt-get update \
  	&& apt-get install -y \
  	libpcre3 \
  	libpcre3-dev \
  	# php-pear \
  	&& pecl install oauth \
  	&& echo "extension=oauth.so" > /usr/local/etc/php/conf.d/docker-php-ext-oauth.ini

RUN	apt-get update

# Install Composer 2
ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_HOME /tmp
RUN	curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin/ --filename=composer --version=2.2.4
ENV PATH="/var/www/.composer/vendor/bin/:${PATH}"

# Configuring system

ADD docker/config/php.ini /usr/local/etc/php/php.ini
ADD docker/config/magento.conf /etc/apache2/sites-available/magento.conf


COPY docker/bin/* /usr/local/bin/
ADD docker/certif/apache-selfsigned.crt /etc/ssl/certs/apache-selfsigned.crt
ADD docker/certif/apache-selfsigned.key /etc/ssl/private/apache-selfsigned.key
#COPY .docker/users/* /var/www/
RUN chmod +x /usr/local/bin/*
RUN ln -s /etc/apache2/sites-available/magento.conf /etc/apache2/sites-enabled/magento.conf

WORKDIR /var/www/html 

COPY . /var/www/html/
RUN composer validate
RUN composer install

RUN chown -R www-data:www-data /var/www/html
RUN chmod -R 777 /var/www/html

RUN usermod -u 1000 www-data
RUN chsh -s /bin/bash www-data
RUN a2enmod rewrite
RUN a2enmod ssl


EXPOSE 80 443 22


VOLUME /var/www/html
WORKDIR /var/www/html

CMD apachectl -DFOREGROUND

#CMD ["/usr/local/bin/startup.sh"]
