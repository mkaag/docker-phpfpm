#!/usr/bin/env bash

NEWRELIC_LICENSE=${NEWRELIC_LICENSE:-false}
if [ "$NEWRELIC_LICENSE" != "false" ]; then
    sed -i "s/^;newrelic.enabled = .*/newrelic_enabled = true/" /etc/php5/mods-available/newrelic.ini
    sed -i "s/^newrelic.license = .*/newrelic.license = \"${NEWRELIC_LICENSE}\"/" /etc/php5/mods-available/newrelic.ini
fi

SSMTP_CONFIG=${SSMTP_CONFIG:-false}
if [ "$SSMTP_CONFIG" == "true" ]; then
    sed -i "s/^mailhub=*/mailhub=${SMTP_HOST}/" /etc/ssmtp/ssmtp.conf
    sed -i "s/^rewriteDomain=*/rewriteDomain=${SMTP_DOMAIN}/" /etc/ssmtp/ssmtp.conf
    sed -i "s/^hostname=*/hostname=${SMTP_DOMAIN}/" /etc/ssmtp/ssmtp.conf
    sed -i "s/^UseTLS=*/UseTLS=${SMTP_TLS}/" /etc/ssmtp/ssmtp.conf
    sed -i "s/^UseSTARTTLS=*/UseSTARTTLS=${SMTP_STARTTLS}/" /etc/ssmtp/ssmtp.conf
    sed -i "s/^AuthUser=*/AuthUser=${SMTP_USERNAME}/" /etc/ssmtp/ssmtp.conf
    sed -i "s/^AuthPass=*/AuthPass=${SMTP_PASSWORD}/" /etc/ssmtp/ssmtp.conf
fi

# Function to update the fpm configuration to make the service environment variables available
function setEnvironmentVariable() {
    if [ -z "$2" ]; then
            echo "Environment variable '$1' not set."
            return
    fi

    # Check whether variable already exists
    if grep -q $1 /etc/php5/fpm/pool.d/www.conf; then
        # Reset variable
        sed -i "s/^env\[$1.*/env[$1] = $2/g" /etc/php5/fpm/pool.d/www.conf
    else
        # Add variable
        echo "env[$1] = $2" >> /etc/php5/fpm/pool.d/www.conf
    fi
}

# Grep for variables that look like docker set them (_PORT_)
for _curVar in `env | grep _PORT_ | awk -F = '{print $1}'`;do
    # awk has split them by the equals sign
    # Pass the name and value to our function
    setEnvironmentVariable ${_curVar} ${!_curVar}
done

/etc/init.d/php5-fpm stop && /usr/sbin/php5-fpm -c /etc/php5/fpm
