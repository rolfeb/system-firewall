#!/bin/sh
#
# Rules controlling traffic to our external imaps port
#
# First, we want to transfer packets from outside to the imaps port [993]
# on our external address to the imaps port on our mail server.
#
# Secondly, for devices that can be connected to external or internal 
# networks, we redirect connections to the external address directly
# to the mail server.
#

IMAP_SERVER=192.168.13.22	# moonbase

#
# Rewrite/redirect connections to our public imaps port via DNAT (rewrite
# destination address) and SNAT (rewrite source address).
#
iptables -t nat -A PREROUTING -p tcp \
	-i $OUTSIDE_IF --dport imaps \
	-j DNAT --to-destination $IMAP_SERVER:993

iptables -t nat -A POSTROUTING -p tcp \
	-o $INSIDE_IF -d $IMAP_SERVER --dport imaps \
	-j SNAT --to $INSIDE_ADDR

#
# Forward the incoming connections through the firewall
#
iptables -A FORWARD -p tcp \
	-i $OUTSIDE_IF \
	-o $INSIDE_IF -d $IMAP_SERVER --dport imaps \
	-m state --state NEW,ESTABLISHED -j ACCEPT

iptables -A FORWARD -p tcp \
	-i $INSIDE_IF -s $IMAP_SERVER --sport imaps \
	-o $OUTSIDE_IF \
	-m state --state ESTABLISHED -j ACCEPT

#
# Redirect outgoing connections to the public imaps port back to the
# internal server.
#
if [ "$OUTSIDE_ADDR" ]
then
	iptables -t nat -A PREROUTING -p tcp \
		-i $INSIDE_IF -s $INSIDE_NET -d $OUTSIDE_ADDR --dport imaps \
		-j DNAT --to-destination $IMAP_SERVER:993
else
	echo "NOTE: not redirecting outgoing imaps connections to mail server"
fi

exit 0
