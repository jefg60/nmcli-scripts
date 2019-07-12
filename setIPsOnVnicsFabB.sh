#!/bin/bash
function get_mac {
  nmcli -f general.hwaddr device show $1 | awk '{print $NF}'
}

function get_ip {
  nmcli -f ip4.address device show $1 | awk '{print $NF}'
}

eth0_mac=$(get_mac eth0)
eth0_ip=$(get_ip eth0)
eth1_mac=$(get_mac eth1)
eth1_ip=$(get_ip eth1)

echo eth0: mac: $eth0_mac ip: $eth0_ip
echo eth1: mac: $eth1_mac ip: $eth1_ip
