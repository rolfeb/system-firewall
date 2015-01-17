#!/bin/sh

# we are a router
echo 1 > /proc/sys/net/ipv4/conf/all/forwarding

# ignore ICMP broadcast requests
/bin/echo "1" > /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts

/bin/echo "0" > /proc/sys/net/ipv4/conf/all/accept_source_route

/bin/echo "0" > /proc/sys/net/ipv4/conf/all/accept_redirects

/bin/echo "1" > /proc/sys/net/ipv4/icmp_ignore_bogus_error_responses

# log packets arriving with addresses incompatible with the interface
/bin/echo "1" > /proc/sys/net/ipv4/conf/all/log_martians

#
# Defend against various attacks
#

## SYN-FLOODING PROTECTION
# This rule maximises the rate of incoming connections. In order to do this
# we divert tcp packets with the SYN bit set off to a user-defined chain.
# Up to limit-burst connections can arrive in 1/limit seconds ..... in this
# case 4 connections in one second. After this, one of the burst is regained
# every second and connections are allowed again. The default limit is 3/hour.
# The default limit burst is 5.
#
iptables -N syn-flood
iptables -A INPUT -i $OUTSIDE_IF -p tcp --syn -j syn-flood
iptables -A syn-flood -m limit --limit 1/s --limit-burst 4 -j RETURN
iptables -A syn-flood -j DROP

## Make sure NEW tcp connections are SYN packets
iptables -A INPUT -i $OUTSIDE_IF -p tcp ! --syn -m state --state NEW -j DROP

exit 0
