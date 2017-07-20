# Use phusion/baseimage (https://github.com/phusion/baseimage-docker) as base image so that
# we have a proper Unix init system (see http://blog.phusion.nl/2015/01/20/docker-and-the-pid-1-zombie-reaping-problem/)
FROM phusion/baseimage:0.9.21
LABEL maintainer "${CompanyName} (${CompanyUrl})"

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# Create a user and group first so the IDs get set the same way, even as
# the rest of this may change over time.
RUN addgroup consul && adduser consul --system --ingroup consul

# Install all the required tools via apt-get in one big statement so that the Docker layer
# only has the items we need:
# - The consul script needs the 'ip' tool which is in the iproute2 package
# - We need to the dos2unix utility so that we can make sure the shell scripts don't have windows line endings
RUN apt-get update && \
    apt-get --assume-yes install iproute2 && \
    apt-get --assume-yes install -y dos2unix && \
    apt-get --assume-yes install dnsmasq && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#
# INSTALL & CONFIGURE CONSUL
#
COPY consul /usr/bin

# The /etc/consul/data dir is used by Consul to store state. The agent will be started
# with /etc/consul/conf.d as the configuration directory so you can add additional
# config files in that location.
RUN mkdir -p /etc/consul/data && \
    mkdir -p /etc/consul/conf.d && \
    chown -R consul:consul /etc/consul

COPY consul.json /etc/consul

# Expose the consul data directory as a volume since there's mutable state in there.
VOLUME /etc/consul/data

# Server RPC is used for communication between Consul clients and servers for internal
# request forwarding.
EXPOSE 8300

# Serf LAN and WAN (WAN is used only by Consul servers) are used for gossip between
# Consul agents. LAN is within the datacenter and WAN is between just the Consul
# servers in all datacenters.
EXPOSE 8301 8301/udp 8302 8302/udp

# CLI, HTTP, and DNS (both TCP and UDP) are the primary interfaces that applications
# use to interact with Consul.
EXPOSE 8400 8500 8600 8600/udp

# Run consul
RUN mkdir /etc/service/consul
COPY consul.sh /etc/service/consul/run
RUN dos2unix /etc/service/consul/run && \
    chmod +x /etc/service/consul/run

#
# INSTALL & CONFIGURE DNSMASQ
#

RUN mkdir /etc/dnsmasq.d
