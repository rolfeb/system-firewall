#!/bin/sh

forward_to_outside()
{
	proto=$1
	port=$2

        if [ "$3" ]
        then
            src_restrict="-i $OUTSIDE_IF -s $3"
            dst_restrict="-o $OUTSIDE_IF -d $3"
        else
            src_restrict=$FROM_OUTSIDE
            dst_restrict=$TO_OUTSIDE
        fi

	iptables -A FORWARD -p $proto --dport $port \
		$FROM_INSIDE $dst_restrict \
		-m state --state NEW,ESTABLISHED -j ACCEPT

	iptables -A FORWARD -p $proto --sport $port \
		$src_restrict $TO_INSIDE \
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

forward_host_to_outside()
{
	host=$1

	iptables -A FORWARD \
        -i $INSIDE_IF -s $host \
		$TO_OUTSIDE \
		-m state --state NEW,ESTABLISHED -j ACCEPT

	iptables -A FORWARD \
        -o $INSIDE_IF -d $host \
		$FROM_OUTSIDE \
		-m state --state ESTABLISHED -j ACCEPT
}
