FROM phusion/baseimage:latest

MAINTAINER Maurice Kaag <mkaag@me.com>

ENV HOME /root
ENV DEBIAN_FRONTEND noninteractive
ENV DEBIAN_PRIORITY critical
ENV DEBCONF_NOWARNINGS yes
# Workaround initramfs-tools running on kernel 'upgrade': <http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=594189>
ENV INITRD No

# Workaround initscripts trying to mess with /dev/shm: <https://bugs.launchpad.net/launchpad/+bug/974584>
# Used by our `src/ischroot` binary to behave in our custom way, to always say we are in a chroot.
ENV FAKE_CHROOT 1
RUN mv /usr/bin/ischroot /usr/bin/ischroot.original
ADD build/ischroot /usr/bin/ischroot

# Configure no init scripts to run on package updates.
ADD build/policy-rc.d /usr/sbin/policy-rc.d

# Disable SSH
RUN rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh

# Ensure UTF-8
RUN locale-gen en_US.UTF-8
ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8

CMD ["/sbin/my_init"]

# Start Installation
ENV NEWRELIC_LICENSE false
ENV NEWRELIC_APP false
WORKDIR /opt
RUN \
    sed -i 's/^# \(.*-backports\s\)/\1/g' /etc/apt/sources.list; \
    apt-get update -qqy; \
    apt-get install -qqy wget curl; \
    wget -O - https://download.newrelic.com/548C16BF.gpg | apt-key add -; \
    echo "deb http://apt.newrelic.com/debian/ newrelic non-free" > /etc/apt/sources.list.d/newrelic.list; \
    apt-get update -qqy

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

# PHP-FPM configuration
ADD build/php.ini /etc/php5/fpm/php.ini
ADD build/www.conf /etc/php5/fpm/pool.d/www.conf
ADD build/php-fpm.conf /etc/php5/fpm/php-fpm.conf
RUN \
    mkdir /var/log/php5-fpm; \
    php5dismod xdebug

# SSMTP
ADD build/ssmtp.conf /etc/ssmtp/ssmtp.conf
RUN \
    chmod 640 /etc/ssmtp/ssmtp.conf && \
    chown root:mail /etc/ssmtp/ssmtp.conf

# INIT
ENV NEWRELIC_LICENSE false
ENV NEWRELIC_APP false

ADD build/newrelic.sh /etc/my_init.d/10_setup_newrelic.sh
ADD build/ssmtp.sh /etc/my_init.d/11_setup_ssmtp.sh
ADD build/env.sh /etc/my_init.d/12_setup_env.sh

RUN \
    chmod +x /etc/my_init.d/10_setup_newrelic.sh; \
    chmod +x /etc/my_init.d/11_setup_ssmtp.sh; \
    chmod +x /etc/my_init.d/12_setup_env.sh

VOLUME ["/var/www"]
EXPOSE 9000
CMD ["/usr/sbin/php5-fpm", "-c /etc/php5/fpm"]
# End Installation

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
