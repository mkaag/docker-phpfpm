docker-phpfpm
=============

This repository contains the **Dockerfile** and the configuration files to build a Load Balancer based on Nginx for [Docker](https://www.docker.com/).
SSMTP and [NewRelic](https://newrelic.com) have been added and the configuration is managed by ENV variables.

### Base Docker Image

* [phusion/baseimage](https://github.com/phusion/baseimage-docker), the *minimal Ubuntu base image modified for Docker-friendliness*...
* ...[including image's enhancement](https://github.com/racker/docker-ubuntu-with-updates) from [Paul Querna](https://journal.paul.querna.org/articles/2013/10/15/docker-ubuntu-on-rackspace/)

### Installation

```bash
docker build -t mkaag/phpfpm github.com/mkaag/docker-phpfpm
```

### Usage

#### Basic usage

```bash
docker run -d -p 9000:9000 mkaag/phpfpm
```

#### Using persistent volume

```bash
docker run -d -p 9000:9000 \
-v /opt/apps/public:/var/www \
mkaag/phpfpm
```

#### Using NewRelic

```bash
docker run -d \
-e "NEWRELIC_LICENSE=your_license" \
-e "NEWRELIC_APP=your_app" \
-p 9000:9000 mkaag/phpfpm
```

#### Using ssmtp

```bash
docker run -d \
-e "SMTP_HOST=mail.domain.com:587" \
-e "SMTP_DOMAIN=domain.com" \
-e "SMTP_TLS=true" \
-e "SMTP_STARTTLS=true" \
-e "SMTP_USERNAME=username" \
-e "SMTP_PASSWORD=password" \
-p 9000:9000 mkaag/phpfpm
```

#### All together

```bash
docker run -d \
-v /opt/apps/public:/var/www \
-e "NEWRELIC_LICENSE=your_license" \
-e "NEWRELIC_APP=your_app" \
-e "SMTP_HOST=mail.domain.com:587" \
-e "SMTP_DOMAIN=domain.com" \
-e "SMTP_TLS=true" \
-e "SMTP_STARTTLS=true" \
-e "SMTP_USERNAME=username" \
-e "SMTP_PASSWORD=password" \
-p 9000:9000 mkaag/phpfpm
```
