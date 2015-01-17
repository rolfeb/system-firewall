#!/bin/sh

forward_to_outside()
{
	proto=$1
	port=$2

	iptables -A FORWARD -p $proto --dport $port \
		$FROM_INSIDE $TO_OUTSIDE \
		-m state --state NEW,ESTABLISHED -j ACCEPT

	iptables -A FORWARD -p $proto --sport $port \
		$FROM_OUTIDE $TO_INSIDE \
		-m state --state ESTABLISHED -j ACCEPT
}

forward_to_inside()
{
	proto=$1
	port=$2

	iptables -A FORWARD -p $proto --dport $port \
		$FROM_OUTIDE $TO_INSIDE \
		-m state --state NEW,ESTABLISHED -j ACCEPT

	iptables -A FORWARD -p $proto --sport $port \
		$FROM_INSIDE $TO_OUTSIDE \
		-m state --state ESTABLISHED -j ACCEPT
}

accept_from_outside()
{
	proto=$1
	port=$2

	iptables -A INPUT -p $proto --dport $port \
		$FROM_OUTSIDE \
		-m state --state NEW,ESTABLISHED -j ACCEPT

	iptables -A OUTPUT -p $proto --sport $port \
		$TO_OUTSIDE \
		-m state --state ESTABLISHED -j ACCEPT
}

accept_from_inside()
{
	proto=$1
	port=$2

	iptables -A INPUT -p $proto --dport $port \
		$FROM_INSIDE \
		-m state --state NEW,ESTABLISHED -j ACCEPT

	iptables -A OUTPUT -p $proto --sport $port \
		$TO_INSIDE \
		-m state --state ESTABLISHED -j ACCEPT
}

accept_from_dmz()
{
	proto=$1
	port=$2

	iptables -A INPUT -p $proto --dport $port \
		$FROM_DMZ \
		-m state --state NEW,ESTABLISHED -j ACCEPT

	iptables -A OUTPUT -p $proto --sport $port \
		$TO_DMZ \
		-m state --state ESTABLISHED -j ACCEPT
}

allow_to_outside()
{
	proto=$1
	port=$2

	iptables -A OUTPUT -p $proto --dport $port \
		$TO_OUTSIDE \
		-m state --state NEW,ESTABLISHED -j ACCEPT

	iptables -A INPUT -p $proto --sport $port \
		$FROM_OUTSIDE \
		-m state --state ESTABLISHED -j ACCEPT
}

allow_to_inside()
{
	proto=$1
	port=$2

	iptables -A OUTPUT -p $proto --dport $port \
		$TO_INSIDE \
		-m state --state NEW,ESTABLISHED -j ACCEPT

	iptables -A INPUT -p $proto --sport $port \
		$FROM_INSIDE \
		-m state --state ESTABLISHED -j ACCEPT
}

accept_from_loopback()
{
	proto=$1
	port=$2

	iptables -A INPUT -p $proto --dport $port \
		-i lo \
		-m state --state NEW,ESTABLISHED -j ACCEPT

	iptables -A OUTPUT -p $proto --sport $port \
		-o lo \
		-m state --state ESTABLISHED -j ACCEPT
}

allow_to_loopback()
{
	proto=$1
	port=$2

	iptables -A OUTPUT -p $proto --dport $port \
		-o lo \
		-m state --state NEW,ESTABLISHED -j ACCEPT

	iptables -A INPUT -p $proto --sport $port \
		-i lo \
		-m state --state ESTABLISHED -j ACCEPT
}

nat_external_to_moonbase()
{
	secure_net=$1
	ext_port=$2
	int_port=$3

	MOONBASE=192.168.13.22
	SID=192.168.13.6

	iptables -t nat -A PREROUTING -p tcp \
		-i eth1 -s $secure_net --dport $ext_port \
		-j DNAT --to-destination $MOONBASE:$int_port

	iptables -t nat -A POSTROUTING -p tcp \
		-o eth0 -d $MOONBASE --dport $int_port \
		-j SNAT --to $SID

	iptables -A FORWARD -p tcp \
		-i eth1 -s $secure_net -d $MOONBASE --dport $int_port \
		-m state --state NEW,ESTABLISHED -j ACCEPT

	iptables -A FORWARD -p tcp \
		-o eth1 -s $MOONBASE --sport $int_port -d $secure_net \
		-m state --state ESTABLISHED -j ACCEPT
}

nat_external_to_raspi()
{
	secure_net=$1
	ext_port=$2
	int_port=$3

	INTERNAL=192.168.13.110
	SID=192.168.13.6

	iptables -t nat -A PREROUTING -p tcp \
		-i eth1 -s $secure_net --dport $ext_port \
		-j DNAT --to-destination $INTERNAL:$int_port

	iptables -t nat -A POSTROUTING -p tcp \
		-o eth0 -d $INTERNAL --dport $int_port \
		-j SNAT --to $SID

	iptables -A FORWARD -p tcp \
		-i eth1 -s $secure_net -d $INTERNAL --dport $int_port \
		-m state --state NEW,ESTABLISHED -j ACCEPT

	iptables -A FORWARD -p tcp \
		-o eth1 -s $INTERNAL --sport $int_port -d $secure_net \
		-m state --state ESTABLISHED -j ACCEPT
}
