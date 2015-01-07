#!/bin/bash

NEWRELIC_LICENSE=${NEWRELIC_LICENSE:-false}
if [ "$NEWRELIC_LICENSE" != "false" ]; then
    sed -i "s/^;newrelic.enabled = .*/newrelic_enabled = true/" /etc/php5/mods-available/newrelic.ini
    sed -i "s/^newrelic.license = .*/newrelic.license = \"${NEWRELIC_LICENSE}\"/" /etc/php5/mods-available/newrelic.ini
    sed -i "s/^;newrelic.error_collector.enabled = .*/newrelic.error_collector.enabled = true/" /etc/php5/mods-available/newrelic.ini
    sed -i "s/^;newrelic.transaction_tracer.enabled = .*/newrelic.transaction_tracer.enabled = true/" /etc/php5/mods-available/newrelic.ini
    sed -i "s/^;newrelic.transaction_tracer.threshold = .*/newrelic.transaction_tracer.threshold = \"apdex_f\"/" /etc/php5/mods-available/newrelic.ini
    sed -i "s/^;newrelic.transaction_events.enabled = .*/newrelic.transaction_events.enabled = true/" /etc/php5/mods-available/newrelic.ini
fi

NEWRELIC_APP=${NEWRELIC_APP:-false}
if [ "$NEWRELIC_APP" != "false" ]; then
    sed -i "s/^newrelic.appname = .*/newrelic.appname = \"${NEWRELIC_APP}\"/" /etc/php5/mods-available/newrelic.ini
fi

exit 0
