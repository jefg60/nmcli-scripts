#!/bin/bash
function get_mac {
  nmcli -f general.hwaddr device show $1 | awk '{print $NF}'
}

eth0_mac=$(get_mac eth0)
eth1_mac=$(get_mac eth1)

echo eth0: $eth0_mac
echo eth1: $eth1_mac
