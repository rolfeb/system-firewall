#!/bin/sh
#
# Rules controlling incoming SSH traffic
#

SSH_SERVER=192.168.13.1	    # shado

#
# Rewrite/redirect connections to our public ssh port via DNAT (rewrite
# destination address).
#
iptables -t nat -A PREROUTING -p tcp \
	-i $OUTSIDE_IF --dport 13022 \
	-j DNAT --to-destination $SSH_SERVER:22

#
# Forward the incoming connections through the firewall
#
iptables -A FORWARD -p tcp \
	-i $OUTSIDE_IF \
	-o $INSIDE_IF -d $SSH_SERVER --dport 22 \
	-m state --state NEW,ESTABLISHED -j ACCEPT

iptables -A FORWARD -p tcp \
	-i $INSIDE_IF -s $SSH_SERVER --sport 22 \
	-o $OUTSIDE_IF \
	-m state --state ESTABLISHED -j ACCEPT

exit 0
