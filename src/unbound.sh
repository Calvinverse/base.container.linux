#!/bin/sh

CONSUL_DOMAIN=
if [ -n "$CONSUL_DOMAIN_NAME" ]; then
  echo "server:" > /etc/unbound.d/unbound_zones.conf
  echo "  local-zone: \"$CONSUL_DOMAIN_NAME.\" nodefault" >> /etc/unbound.d/unbound_zones.conf
  echo "  domain-insecure: \"$CONSUL_DOMAIN_NAME\"" >> /etc/unbound.d/unbound_zones.conf

  echo "stub-zone:" >> /etc/unbound.d/unbound_zones.conf
  echo "  name: \"$CONSUL_DOMAIN_NAME\"" >> /etc/unbound.d/unbound_zones.conf
  echo "  stub-addr: 127.0.0.1@8600" >> /etc/unbound.d/unbound_zones.conf

  echo "forward-zone:" >> /etc/unbound.d/unbound_zones.conf
  echo "  name: \".\"" >> /etc/unbound.d/unbound_zones.conf
  echo "  forward-addr: 192.168.6.1" >> /etc/unbound.d/unbound_zones.conf

  echo "==> creating the unbound_zones.conf file ..."
fi

# `/sbin/setuser memcache` runs the given command as the user `memcache`.
# If you omit that part, the command will be run as root.
exec /usr/sbin/unbound agent -d -c /etc/unbound/unbound.conf 2>&1 | logger
