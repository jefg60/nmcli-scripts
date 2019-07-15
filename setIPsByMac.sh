#!/bin/bash

syntax="$0 mac_to_configure ip_to_configure/cidr gw_to_configure \n
e.g. $0 FF:FF:FF:FF:FF:FF 192.168.34.1/24 192.168.34.1"

if [ -z $3 ]
then
  echo "Syntax: $syntax"
  exit 1
fi

desired_mac=$1
desired_ip=$2
desired_gw=$3

echo $0 desired_mac is "$desired_mac"

function get_mac {
  #e.g. get_mac eth1
  nmcli --get-values general.hwaddr device show $1 | sed 's/\\//g'
}

function get_ip {
  #e.g. get_ip eth1
  nmcli --get-values ip4.address device show $1
}

#Get list of devices as array
for i in $(nmcli --get-values general.device device show)
do
  devices+=($i)
done

echo $0 got list of devices:
echo ${devices[*]}

for i in ${devices[*]}
do
  echo $0 Checking "$(get_mac $i)"
  if [ "$(get_mac $i)" == "$desired_mac" ]
  then
    if [ "$(get_ip $i)" == "$desired_ip" ]
    then
      echo $0 IP of "$i" is already "$desired_ip"
      exit 0
    fi
    echo $0 configuring "$i" with ip "$desired_ip"
    nmcli con add con-name "static-$i" ifname "$i" type ethernet \
    ip4 "$desired_ip" gw4 "$desired_gw" && exit 0
    echo ERROR configuring "$i" failed
    exit 2
  fi
done
