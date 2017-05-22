# Use phusion/baseimage (https://github.com/phusion/baseimage-docker) as base image so that
# we have a proper Unix init system (see http://blog.phusion.nl/2015/01/20/docker-and-the-pid-1-zombie-reaping-problem/)
FROM phusion/baseimage:0.9.21
LABEL maintainer "Petrik van der Velde (@petrikvdvelde)"

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# install consul

# This is the release of Consul to pull in.
ENV CONSUL_VERSION=0.8.3

# This is the location of the releases.
ENV HASHICORP_RELEASES=https://releases.hashicorp.com

# Create a consul user and group first so the IDs get set the same way, even as
# the rest of this may change over time.
RUN addgroup consul
RUN adduser consul --system --ingroup consul

RUN apt-get update
RUN apt-get --assume-yes install unzip

# The consul script needs the 'ip' tool which is in the iproute2 package
RUN apt-get --assume-yes install iproute2

# Set up certificates, our base tools, and Consul.
RUN gpg --keyserver pgp.mit.edu --recv-keys 91A6E7F85D05C65630BEF18951852D87348FFC4C
RUN mkdir -p /tmp/build
RUN cd /tmp/build

RUN curl -O ${HASHICORP_RELEASES}/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip
RUN curl -O ${HASHICORP_RELEASES}/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_SHA256SUMS
RUN curl -O ${HASHICORP_RELEASES}/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_SHA256SUMS.sig
RUN gpg --batch --verify consul_${CONSUL_VERSION}_SHA256SUMS.sig consul_${CONSUL_VERSION}_SHA256SUMS
RUN grep consul_${CONSUL_VERSION}_linux_amd64.zip consul_${CONSUL_VERSION}_SHA256SUMS | sha256sum -c

RUN unzip -d /usr/bin consul_${CONSUL_VERSION}_linux_amd64.zip
RUN cd /tmp
RUN rm -rf /tmp/build
RUN rm -rf /root/.gnupg

# The /etc/consul/data dir is used by Consul to store state. The agent will be started
# with /etc/consul/conf.d as the configuration directory so you can add additional
# config files in that location.
RUN mkdir -p /etc/consul/data
RUN mkdir -p /etc/consul/conf.d
RUN chown -R consul:consul /etc/consul

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
RUN chmod +x /etc/service/consul/run

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
