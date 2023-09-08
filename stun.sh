#!/usr/bin/env bash

NS="split"
BR="br0"
IF="eno1"

create() {
  # Create namespace
  ip netns add "$NS"

  # Up lo
  ip netns exec "$NS" ip link set lo up

  # Create veth pairs (veth0, veth1)
  ip link add veth0 type veth peer name veth1

  ip link set veth0 up

  # Moving veth1 to namespace
  ip link set veth1 netns "$NS"

  # Set veth1 as default route inside namespace
  # ip netns exec "$NS" ip route add default dev veth1 via 10.1.1.1

  # Create bridge
  ip link add "$BR" type bridge

  # Add veth0 to bridge
  ip link set veth0 master "$BR"

  # Set IPs
  ip addr add 10.1.1.1/24 dev "$BR"
  ip netns exec "$NS" ip addr add 10.1.1.2/24 dev veth1

  ip link set "$BR" up
  ip netns exec "$NS" ip link set veth1 up
  ip -n "$NS" route add default dev veth1 via 10.1.1.1

  # Don't route to wg
  ip rule add from 10.1.1.2 table main priority 99

  # IPTables NAT
  iptables -t nat -A POSTROUTING -s 10.1.1.1/24 -o "$IF" -j MASQUERADE
  iptables -A FORWARD -i "$IF" -o "$BR" -j ACCEPT
  iptables -A FORWARD -o "$IF" -i "$BR" -j ACCEPT

  mkdir -p /etc/netns/"$NS"
  echo 'nameserver 1.1.1.1' > /etc/netns/"$NS"/resolv.conf
  cp /etc/hosts /etc/netns/"$NS"/hosts
}

destroy() {
  rm -Rf /etc/netns/"$NS"

  iptables -t nat -D POSTROUTING -s 10.1.1.1/24 -o "$IF" -j MASQUERADE
  iptables -D FORWARD -i "$IF" -o "$BR" -j ACCEPT
  iptables -D FORWARD -o "$IF" -i "$BR" -j ACCEPT

  ip rule delete from 10.1.1.2 table main priority 99

  ip link delete veth0
  ip link delete "$BR"

  ip netns delete "$NS"
}

if [[ "$1" == "create" ]]; then 
  create
elif [[ "$1" == "destroy" ]]; then
  destroy
else
  echo "USAGE: split_tunnel create|destroy"
fi
