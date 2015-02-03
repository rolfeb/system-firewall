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
