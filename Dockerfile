# nginx + PHP5-FPM + owncloud +  supervisord on Docker
#
# VERSION               0.0.1
FROM        stackbrew/ubuntu:13.10
MAINTAINER  Rolf Meinecke "github@jsilence.org"

RUN apt-get update && apt-get -qy upgrade
RUN locale-gen de_DE.UTF-8 && dpkg-reconfigure locales

RUN echo "Europe/Berlin" > /etc/timezone
RUN dpkg-reconfigure --frontend noninteractive tzdata

# install curl
RUN apt-get install -y curl

# Configure repos
# RUN apt-get install -y python-software-properties
# RUN apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xcbcb082a1bb943db
# RUN add-apt-repository -y ppa:nginx/stable
# RUN add-apt-repository -y ppa:ondrej/php5

# Install nginx
RUN apt-get -y install nginx

# Install PHP5 and modules
RUN apt-get -y install php5-fpm php-apc php5-imap php5-mcrypt php5-curl php5-gd php5-json

# choose your poison
#RUN apt-get -y install php5-mysql 
RUN apt-get -y install php5-sqlite 

# Install Supervisord
RUN apt-get -y install python-setuptools
RUN easy_install supervisor
ADD supervisord.conf /etc/supervisord.conf

# Install owncloud from tgz
WORKDIR /var/www 
RUN curl http://download.owncloud.org/community/owncloud-6.0.1.tar.bz2 | tar xfj -
RUN chown -R www-data:www-data /var/www

# Configure nginx for PHP websites
ADD nginx_default.conf /etc/nginx/sites-available/default
RUN echo "cgi.fix_pathinfo = 0;" >> /etc/php5/fpm/php.ini
ADD ssl.crt /etc/nginx/ssl.crt
ADD ssl.key /etc/nginx/ssl.key


CMD supervisord -n -c /etc/supervisord.conf 

# use this for debugging from within container
# CMD supervisord -c /etc/supervisord.conf && /bin/bash