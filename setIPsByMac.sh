#!/bin/bash

syntax="$0 mac_to_configure ip_to_configure netmask <gw_to_configure> \n
e.g. $0 FF:FF:FF:FF:FF:FF 192.168.34.1 255.255.255.0 192.168.34.1"

if [ -z $3 ]
then
  echo "Syntax: $syntax"
  exit 1
fi

echo $0 desired_mac is "$desired_mac"

function IPprefix_by_netmask {
#function returns prefix for given netmask in arg1
 ipcalc -p 1.1.1.1 $1 | sed -n 's/^PREFIX=\(.*\)/\/\1/p'
}

#get params with uppercase mac
desired_mac=${1^^}
desired_netmask=$3
cidr=$(IPprefix_by_netmask $desired_netmask)
desired_ip="$2$cidr"
if [ ! -z $4 ]
then
  desired_gw=$4
else
  desired_gw=0
fi

function get_mac {
  #e.g. get_mac eth1
  nmcli --get-values general.hwaddr device show $1 | sed 's/\\//g'
}

function get_ip {
  #e.g. get_ip eth1
  nmcli --get-values ip4.address device show $1
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
    current_ip=$(get_ip $i)
    if [ "$desired_ip" == "$current_ip" ]
    then
      echo $0 IP of "$i" is already "$current_ip"
      exit 0
    fi
    echo $0 configuring "$i" with ip "$desired_ip"
    uuids=$(get_uuid_by_device $i)
    for u in $uuids
    do
      nmcli con delete "$u" || echo $0 ERROR deleting connection "$u"
    done
    if [ $desired_gw -eq 0 ]
    then
      nmcli con add con-name "static-$i" ifname "$i" type ethernet \
      ip4 "$desired_ip" && exit 0
    else
      nmcli con add con-name "static-$i" ifname "$i" type ethernet \
      ip4 "$desired_ip" gw4 "$desired_gw" && exit 0
    fi
    echo ERROR configuring "$i" failed
    exit 2
  fi
done
