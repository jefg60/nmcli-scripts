#!/bin/bash

syntax="$0 mac_to_disable
e.g. $0 FF:FF:FF:FF:FF:FF"

if [ -z $1 ]
then
  echo "Syntax: $syntax"
  exit 1
fi

echo $0 desired_mac is "$desired_mac"

#get params with uppercase mac
desired_mac=${1^^}

function get_mac {
  #e.g. get_mac eth1
  nmcli --get-values general.hwaddr device show $1 | sed 's/\\//g'
}

function get_uuid_by_device {
  #e.g. get_uuid_by_device eth1
  nmcli --get-values name,uuid,device con show | grep $1 | cut -d ":" -f2
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
  echo $0 Checking "$(get_mac $i) - $i"
  if [ "$(get_mac $i)" == "$desired_mac" ]
  then
    echo $0 disabling "$i"
    uuids=$(get_uuid_by_device $i)
    for u in $uuids
    do
      nmcli con delete "$u" || echo "$0 ERROR deleting connection $u" && \
      echo "ERROR: disabling $i failed" && exit 2
    done
  fi
done
