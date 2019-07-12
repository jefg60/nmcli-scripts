#!/bin/bash

syntax="$0 mac_to_configure ip_to_configure"

if [ -z $2 ]
then
  echo "Syntax: $syntax"
  exit 1
fi

desired_mac=$1
desired_ip=$2

function get_mac {
  #e.g. get_mac eth1
  nmcli --get-values general.hwaddr device show $1
}

function get_ip {
  #e.g. get_ip eth1
  nmcli --get-values ip4.address device show $1
}

function get_uuid_by_device {
  #e.g. get_uuid_by_device eth1
  nmcli --get-values name,uuid,device con show | grep $1 | cut -d ":" -f2
}

function set_ip_by_mac {
  mac=$1
  new_ip=$2
  nmcli con
}

eth0_mac=$(get_mac eth0)
eth0_ip=$(get_ip eth0)
eth1_mac=$(get_mac eth1)
eth1_ip=$(get_ip eth1)

echo eth0: mac: $eth0_mac old ip: $eth0_ip
echo eth1: mac: $eth1_mac old ip: $eth1_ip


