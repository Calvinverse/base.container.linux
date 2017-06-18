#!/bin/sh

# You can set CONSUL_BIND_INTERFACE to the name of the interface you'd like to
# bind to and this will look up the IP and pass the proper -bind= option along
# to Consul.
CONSUL_BIND=
if [ -n "$CONSUL_BIND_INTERFACE" ]; then
  CONSUL_BIND_ADDRESS=$(ip -o -4 addr list $CONSUL_BIND_INTERFACE | head -n1 | awk '{print $4}' | cut -d/ -f1)
  if [ -z "$CONSUL_BIND_ADDRESS" ]; then
    echo "Could not find IP for interface '$CONSUL_BIND_INTERFACE', exiting"
    exit 1
  fi

  CONSUL_BIND="-bind=$CONSUL_BIND_ADDRESS"
  echo "==> Found address '$CONSUL_BIND_ADDRESS' for interface '$CONSUL_BIND_INTERFACE', setting bind option..."
fi

# You can set CONSUL_CLIENT_INTERFACE to the name of the interface you'd like to
# bind client intefaces (HTTP, DNS, and RPC) to and this will look up the IP and
# pass the proper -client= option along to Consul.
CONSUL_CLIENT=
if [ -n "$CONSUL_CLIENT_INTERFACE" ]; then
  CONSUL_CLIENT_ADDRESS=$(ip -o -4 addr list $CONSUL_CLIENT_INTERFACE | head -n1 | awk '{print $4}' | cut -d/ -f1)
  if [ -z "$CONSUL_CLIENT_ADDRESS" ]; then
    echo "Could not find IP for interface '$CONSUL_CLIENT_INTERFACE', exiting"
    exit 1
  fi

  CONSUL_CLIENT="-client=$CONSUL_CLIENT_ADDRESS"
  echo "==> Found address '$CONSUL_CLIENT_ADDRESS' for interface '$CONSUL_CLIENT_INTERFACE', setting client option..."
fi

# See if the consul server flag is set, if so mark the consul instance as a server
CONSUL_SERVER=
if [ -n "$CONSUL_SERVER_FLAG" ]; then
  CONSUL_SERVER="-server"
  echo "==> setting server option..."
fi

# See if a datacenter is specified
CONSUL_DATACENTER=
if [ -n "$CONSUL_DATACENTER_NAME" ]; then
  CONSUL_SERVER="-datacenter=$CONSUL_DATACENTER_NAME"
  echo "==> setting datacenter option..."
fi

# See if a retry-join is specified
CONSUL_RETRY_JOIN=
if [ -n "$CONSUL_SERVER_IPS" ]; then
  addresses=$(echo $CONSUL_SERVER_IPS | tr ";" "\n")

  echo "==> processing $addresses for retry-join option..."

  for addr in $addresses
  do
      CONSUL_RETRY_JOIN="$CONSUL_RETRY_JOIN -retry-join $addr"
      echo "==> appending $addr to the retry-join option..."
  done
fi

CONSUL_ENCRYPT_KEY=
if [ -n "$CONSUL_ENCRYPT" ]; then
  CONSUL_ENCRYPT_KEY="-encrypt=$CONSUL_ENCRYPT"
  echo "==> setting encrypt option..."
fi

# CONSUL_DATA_DIR is exposed as a volume for possible persistent storage. The
# CONSUL_CONFIG_DIR isn't exposed as a volume but you can compose additional
# config files in there if you use this image as a base
CONSUL_DATA_DIR=/etc/consul/data
CONSUL_CONFIG_DIR=/etc/consul/conf.d

# If the data or config dirs are bind mounted then chown them.
# Note: This checks for root ownership as that's the most common case.
# if [ "$(stat -c %u /consul/data)" != "$(id -u consul)" ]; then
#   chown consul:consul /consul/data
# fi
# if [ "$(stat -c %u /consul/config)" != "$(id -u consul)" ]; then
#   chown consul:consul /consul/config
# fi

# `/sbin/setuser memcache` runs the given command as the user `memcache`.
# If you omit that part, the command will be run as root.
exec /sbin/setuser consul /usr/bin/consul agent -data-dir="$CONSUL_DATA_DIR" -config-file="/etc/consul/consul.json" -config-dir="$CONSUL_CONFIG_DIR" $CONSUL_BIND $CONSUL_CLIENT $CONSUL_SERVER $CONSUL_DATACENTER $CONSUL_RETRY_JOIN $CONSUL_ENCRYPT_KEY 2>&1 | logger
