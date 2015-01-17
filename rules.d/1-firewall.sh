#!/bin/sh
#
# Rules controlling traffic to/from the firewall itself 
#

. ./functions.sh

# allow everything on the loopback interface
iptables -A INPUT  -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# logging
allow_to_inside tcp 514

# DNS
allow_to_outside tcp domain
allow_to_outside udp domain

# NTP
allow_to_outside udp ntp

# DHCP
allow_to_outside udp 67:68
accept_from_outside udp 68

# DNS
accept_from_inside udp domain
accept_from_dmz udp domain

# DNS (temporary)
allow_to_inside udp domain

exit 0

