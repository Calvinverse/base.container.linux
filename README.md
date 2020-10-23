# base.container.linux

This repository contains the code used to build a container containing the base operating system and
tools that are required by all Linux resources.

## Image

### Contents

The current process uses the [`phusion/baseimage'](https://github.com/phusion/baseimage-docker) docker image as the base image and will then
configure the following [tools and services in the container](https://github.com/phusion/baseimage-docker#wait-i-thought-docker-is-about-running-a-single-process-in-a-container):

* [Consul](https://consul.io) - Provides service discovery for the environment as well as a distributed
  key-value store.
* [Consul-Template](https://github.com/hashicorp/consul-template) - Renders template files based on
  information stored in the `Consul` key-value store and the [Vault](https://vaultproject.io) secret
  store.
* [OpenTelemetry](https://opentelemetry.io/) - OpenTelemetry is a collection of tools, APIs, and SDKs. You use it to instrument, generate, collect, and export telemetry data (metrics, logs, and traces) for analysis in order to understand your software's performance and behavior.
* [Syslog-ng](https://syslog-ng.org/) - Captures logs send to the
  [syslog stream](https://en.wikipedia.org/wiki/Syslog) and stores them both locally and forwards
  them onto the [central log storage server](https://github.com/Calvinverse/resource.documents.storage).
* [Telegraf](https://www.influxdata.com/time-series-platform/telegraf/) - Captures metrics for the
  resource and forwards them onto the [time series database](https://github.com/Calvinverse/resource.metrics.storage)
  for storage and processing.
* [Unbound](https://www.unbound.net/) - A local DNS resolver to allow resolving DNS requests via
  Consul for the environment specific requests and external DNS servers for all other requests.

### Configuration

* Configurations for `Consul` and `Unbound` should be provided via the
  a mounted directory. All other services and applications should
  obtain their configuration via `Consul-Template` and the `Consul` key-value store.

### Provisioning

For provisoning the unbound configuration file can be mounted on the `/etc/unbound.d/unbound_zones.conf`

Consul can be configured by providing environment variables and mounting the Consul CA bundle on `/etc/consul/conf.d/certs/bundle.crt`. The environment variables for Consul are:

* `CONSUL_BIND_INTERFACE` - The name of the interface for the Consul [bind address](https://www.consul.io/docs/agent/options.html#_bind)
* `CONSUL_CLIENT_INTERFACE` - The name of the interface on which Consul should bind the [clients](https://www.consul.io/docs/agent/options.html#_client)
* `CONSUL_DATACENTER_NAME` - The name of the Consul datacenter
* `CONSUL_DOMAIN_NAME` - The name of the Consul domain
* `CONSUL_SERVER_IPS` - The semi-colon separated list of Consul server IP addresses
* `CONSUL_ENCRYPT` - The Consul [encrypt](https://www.consul.io/docs/security/encryption#gossip-encryption) key


### Logs

Logs are collected via [Syslog-ng](https://github.com/phusion/baseimage-docker#system-logging).

### Metrics

Metrics are collected through different means.

* Metrics for Consul are collected by Consul sending [StatsD](https://www.consul.io/docs/agent/telemetry.html)
  metrics to [Telegraf](https://www.influxdata.com/time-series-platform/telegraf/).
* Metrics for Unbound are collected by Telegraf pulling the metrics.
* System metrics, e.g. CPU, disk, network and memory usage, are collected by Telegraf.

## Build, test and release

The build process follows the standard procedure for
[building Calvinverse images](https://www.calvinverse.net/documentation/how-to-build).

    msbuild entrypoint.msbuild /t:build


## Deploy

The base image should never be deployed to live running infrastructure hence it will not be needing deploy information.
