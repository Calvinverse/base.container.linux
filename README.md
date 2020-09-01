# base.container.linux

* Contains the base services that we need in each container in our infrastructure
  * Consul
  * Envoy (to enable Consul Connect)
  * OpenTelemetry agent (to handle distributed traces)
  * Unbound



* Mount a consul CA bundle at `/etc/consul/conf.d/certs/bundle.crt`.