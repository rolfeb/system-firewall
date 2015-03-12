#!/bin/sh
#
# UDP Traceroute packets (replies handled via icmp timeout-exceeded)
#

#
# To/from firewall. Note that the correct behaviour is to reject incoming
# packets.
#
iptables -A INPUT -p udp --dport 33434:33523 -j REJECT
iptables -A OUTPUT -p udp --dport 33434:33523 -j ACCEPT

#
# Allow traceroutes through the firewall
#
iptables -A FORWARD -i $INSIDE_IF -o $OUTSIDE_IF -p udp --dport 33434:33523 -j ACCEPT

exit 0
