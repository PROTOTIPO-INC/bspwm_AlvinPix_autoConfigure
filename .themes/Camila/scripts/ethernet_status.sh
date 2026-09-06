#!/bin/sh

# Auto-detect active network interface (wlan0, then eth0)
ip=$(/usr/sbin/ifconfig wlan0 2>/dev/null | grep "inet " | awk '{print $2}')
[ -z "$ip" ] && ip=$(/usr/sbin/ifconfig eth0 2>/dev/null | grep "inet " | awk '{print $2}')

if [ -n "$ip" ]; then
  echo "%{F#e0d1d2}  %{F#e0d1d2}$ip%{u-}"
else
  echo "%{F#e0d1d2}  Offline"
fi
