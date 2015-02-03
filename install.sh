#!/bin/sh
#
# iptables configuration for "straker"
#

echo "** Starting firewall configuration..."

DIR=`dirname $0`

PATH=$DIR:/sbin:/usr/bin:/bin:/usr/local/bin
export PATH

#
# Sanity checks
#
if [ ! -d $DIR/rules.d ]
then
	echo "$0: no such directory: $DIR/rules.d" >&1
	exit 1
fi

#
# Configuration
#

export OUTSIDE_IF=eth0.201
export OUTSIDE_NET=0.0.0.0/0
# external IP is dynamic:
export OUTSIDE_ADDR=`/sbin/ifconfig $OUTSIDE_IF | awk '/inet addr/ { print $2; }' | awk -F: '{ print $2 }'`

if [ -z "$OUTSIDE_ADDR" ]
then
	echo "WARNING: cannot determine external IP address"
fi


export INSIDE_IF=eth0.101
export INSIDE_ADDR=192.168.13.5
export INSIDE_NET=192.168.13.0/24

export DMZ_IF=eth0.104
export DMZ_ADDR=192.168.14.1
export DMZ_NET=192.168.14.0/24

############################################################################

export FROM_INSIDE="-i $INSIDE_IF -s $INSIDE_NET"
export FROM_OUTSIDE="-i $OUTSIDE_IF -s $OUTSIDE_NET"
export FROM_DMZ="-i $DMZ_IF -s $DMZ_NET"
export TO_INSIDE="-o $INSIDE_IF -d $INSIDE_NET"
export TO_OUTSIDE="-o $OUTSIDE_IF -d $OUTSIDE_NET"
export TO_DMZ="-o $DMZ_IF -d $DMZ_NET"

modprobe iptable_nat
modprobe ip_conntrack
modprobe ip_conntrack_ftp
modprobe ip_nat_ftp

. functions.sh

#
# Set default policies and initial blocking rules
#

# set the default policies
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

# clear the current configuration
iptables -F
iptables -F -t nat
iptables -Z
iptables -Z -t nat
iptables -X

# add blocking entries at the front of the chains
iptables -A INPUT -j DROP
iptables -A OUTPUT -j DROP
iptables -A FORWARD -j DROP

for r in $DIR/rules.d/*.sh
do
	echo "running $r..."
	$r
done

# just in case...
accept_from_inside tcp ssh

#
# Drop broadcast traffic from the inside before logging
#
iptables -A INPUT -p tcp -i $INSIDE_IF -d 192.168.13.255/32 -j DROP
iptables -A INPUT -p tcp -i $INSIDE_IF -d 255.255.255.255/32 -j DROP

iptables -A INPUT -p udp -i $INSIDE_IF -d 192.168.13.255/32 -j DROP
iptables -A INPUT -p udp -i $INSIDE_IF -d 255.255.255.255/32 -j DROP

iptables -A INPUT -p igmp -i $INSIDE_IF -d 224.0.0.1/32 -j DROP

#
# Log invalid packets separately
#
iptables -N invalid
iptables -A INPUT -m state --state INVALID -j invalid
iptables -A FORWARD -m state --state INVALID -j invalid
iptables -A invalid -j LOG -m limit --limit 1/s --limit-burst 4  --log-level 3 --log-prefix "fw:ip:invalid "
iptables -A invalid -j DROP
iptables -A invalid -j RETURN

#
# Log anything else
#
iptables -A INPUT -j LOG -m limit --limit 1/s --limit-burst 4  --log-level 3 --log-prefix "fw:ip:INPUT:drop "
iptables -A OUTPUT -j LOG -m limit --limit 1/s --limit-burst 4  --log-level 3 --log-prefix "fw:ip:OUTPUT:drop "
iptables -A FORWARD -j LOG -m limit --limit 1/s --limit-burst 4  --log-level 3 --log-prefix "fw:ip:FORWARD:drop "

# XXX: for debugging
### iptables -A INPUT -j REJECT
### iptables -A OUTPUT -j REJECT
### iptables -A FORWARD -j REJECT

# remove the blocking entries at the front of the chains
iptables -D INPUT 1
iptables -D OUTPUT 1
iptables -D FORWARD 1

echo "** Firewall configuration complete."

exit 0
