FROM mkaag/baseimage:latest
MAINTAINER Maurice Kaag <mkaag@me.com>

# -----------------------------------------------------------------------------
# Environment variables
# -----------------------------------------------------------------------------
ENV NEWRELIC_LICENSE    false
ENV NEWRELIC_APP        false

# -----------------------------------------------------------------------------
# Pre-install
# -----------------------------------------------------------------------------
RUN \
    sed -i 's/^# \(.*-backports\s\)/\1/g' /etc/apt/sources.list && \
    wget -O - https://download.newrelic.com/548C16BF.gpg | apt-key add - && \
    echo "deb http://apt.newrelic.com/debian/ newrelic non-free" > /etc/apt/sources.list.d/newrelic.list && \
    apt-get update -qqy

# -----------------------------------------------------------------------------
# Install
# -----------------------------------------------------------------------------
RUN \
    apt-get install -qqy \
    php5-fpm \
    php5-mysql \
    php5-imagick \
    php5-mcrypt \
    php5-curl \
    php5-cli \
    php5-memcache \
    php5-intl \
    php5-gd \
    php5-xdebug \
    newrelic-php5 \
    newrelic-sysmond \
    ssmtp

# -----------------------------------------------------------------------------
# Post-install
# -----------------------------------------------------------------------------
ADD build/php.ini /etc/php5/fpm/php.ini
ADD build/www.conf /etc/php5/fpm/pool.d/www.conf
ADD build/php-fpm.conf /etc/php5/fpm/php-fpm.conf
RUN \
    mkdir /var/log/php5-fpm && \
    php5dismod xdebug

ADD build/ssmtp.conf /etc/ssmtp/ssmtp.conf
RUN \
    chmod 640 /etc/ssmtp/ssmtp.conf && \
    chown root:mail /etc/ssmtp/ssmtp.conf

ADD build/newrelic.sh /etc/my_init.d/10_setup_newrelic.sh
ADD build/ssmtp.sh /etc/my_init.d/11_setup_ssmtp.sh
ADD build/env.sh /etc/my_init.d/12_setup_env.sh
RUN \
    chmod +x /etc/my_init.d/10_setup_newrelic.sh && \
    chmod +x /etc/my_init.d/11_setup_ssmtp.sh && \
    chmod +x /etc/my_init.d/12_setup_env.sh

EXPOSE 9000
VOLUME ["/var/www"]

CMD ["/sbin/my_init"]
CMD ["/usr/sbin/php5-fpm", "-c /etc/php5/fpm"]

# -----------------------------------------------------------------------------
# Clean up
# -----------------------------------------------------------------------------
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
