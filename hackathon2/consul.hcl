# https://developer.hashicorp.com/consul/docs/agent

data_dir = "/Users/roman/Desktop/lectures/devops-fall2024/tmp-consul/consul"

# an IP address that should be reachable by all other nodes in the cluster. By default, this is "0.0.0.0", meaning Consul
# will bind to all addresses on the local machine and will advertise the private IPv4 address to the rest of the cluster.
bind_addr  = "0.0.0.0"
client_addr = "0.0.0.0"

node_name = "consul-kbtu-node-server"
alt_domain = "halykbank.n


# client = "localhost"

# This flag is used to control if a server is in "bootstrap" mode. It is important that no more than one server per
# datacenter be running in this mode. Technically, a server in bootstrap mode is allowed to self-elect as the Raft leader.
# It is important that only a single node is in this mode; otherwise, consistency cannot be guaranteed as multiple nodes
# are able to self-elect. It is not recommended to use this flag after a cluster has been bootstrapped.
bootstrap = true

datacenter = "kbtu-dc"
ui_config {
  enabled = true
}
log_level  = "DEBUG"