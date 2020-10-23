#!/bin/sh

# `/sbin/setuser memcache` runs the given command as the user `memcache`.
# If you omit that part, the command will be run as root.
exec /sbin/setuser otel /usr/bin/otel --config=/etc/otel/otel-agent.yaml 2>&1 | logger
