#!/bin/bash

network_info=$(nmcli device show wlp3s0)

ip=$(echo $network_info | awk -F: '{ print $12 }')

echo $ip | awk -F ' ' '{ print $1 }'
