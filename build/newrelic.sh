#!/usr/bin/bash

NEWRELIC_LICENSE=${NEWRELIC_LICENSE:-false}
if [ "$NEWRELIC_LICENSE" != "false" ]; then
    sed -i "s/^;newrelic.enabled = .*/newrelic_enabled = true/" /etc/php5/mods-available/newrelic.ini
    sed -i "s/^newrelic.license = .*/newrelic.license = \"${NEWRELIC_LICENSE}\"/" /etc/php5/mods-available/newrelic.ini
fi

exit 0
