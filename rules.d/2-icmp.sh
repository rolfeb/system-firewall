#!/bin/sh

iptables -N icmp-i
iptables -N icmp-o
iptables -N icmp-f
iptables -A INPUT -p icmp -j icmp-i
iptables -A OUTPUT -p icmp -j icmp-o
iptables -A FORWARD -p icmp -j icmp-f


#
# Traffic through the firewall
#
iptables -A icmp-f $FROM_INSIDE $TO_OUTSIDE -p icmp --icmp-type echo-request -j ACCEPT
iptables -A icmp-f $FROM_OUTSIDE $TO_INSIDE -p icmp --icmp-type echo-reply -j ACCEPT

iptables -A icmp-f $FROM_INSIDE $TO_DMZ -p icmp --icmp-type echo-request -j ACCEPT
iptables -A icmp-f $FROM_DMZ $TO_INSIDE -p icmp --icmp-type echo-reply -j ACCEPT

iptables -A icmp-f $FROM_DMZ $TO_OUTSIDE -p icmp --icmp-type echo-request -j ACCEPT
iptables -A icmp-f $FROM_OUTSIDE $TO_DMZ -p icmp --icmp-type echo-reply -j ACCEPT

#
# Traffic to the firewall
#
iptables -A icmp-i $FROM_INSIDE -p icmp --icmp-type echo-request -j ACCEPT
iptables -A icmp-o $TO_INSIDE -p icmp --icmp-type echo-reply -j ACCEPT

iptables -A icmp-i $FROM_DMZ -p icmp --icmp-type echo-request -j ACCEPT
iptables -A icmp-o $TO_DMZ -p icmp --icmp-type echo-reply -j ACCEPT

iptables -A icmp-i $FROM_OUTSIDE -p icmp --icmp-type echo-request -j ACCEPT
iptables -A icmp-o $TO_OUTSIDE -p icmp --icmp-type echo-reply -j ACCEPT

#
# Traffic from the firewall
#
iptables -A icmp-o $TO_INSIDE -p icmp --icmp-type echo-request -j ACCEPT
iptables -A icmp-i $FROM_INSIDE -p icmp --icmp-type echo-reply -j ACCEPT

iptables -A icmp-o $TO_DMZ -p icmp --icmp-type echo-request -j ACCEPT
iptables -A icmp-i $FROM_DMZ -p icmp --icmp-type echo-reply -j ACCEPT

iptables -A icmp-o $TO_OUTSIDE -p icmp --icmp-type echo-request -j ACCEPT
iptables -A icmp-i $FROM_OUTSIDE -p icmp --icmp-type echo-reply -j ACCEPT

#
# ICMP traffic messages
#
iptables -A icmp-f -p icmp --icmp-type destination-unreachable -j ACCEPT
iptables -A icmp-f -p icmp --icmp-type parameter-problem -j ACCEPT
iptables -A icmp-f -p icmp --icmp-type source-quench -j ACCEPT
iptables -A icmp-f -p icmp --icmp-type time-exceeded -j ACCEPT

iptables -A icmp-i -p icmp --icmp-type destination-unreachable -j ACCEPT
iptables -A icmp-i -p icmp --icmp-type parameter-problem -j ACCEPT
iptables -A icmp-i -p icmp --icmp-type source-quench -j ACCEPT
iptables -A icmp-i -p icmp --icmp-type time-exceeded -j ACCEPT

iptables -A icmp-o -p icmp --icmp-type destination-unreachable -j ACCEPT
iptables -A icmp-o -p icmp --icmp-type parameter-problem -j ACCEPT
iptables -A icmp-o -p icmp --icmp-type source-quench -j ACCEPT
iptables -A icmp-o -p icmp --icmp-type time-exceeded -j ACCEPT

#
# Log and drop any other ICMP
#
iptables -A icmp-i -j LOG --log-level 3 --log-prefix "fw:icmp:INPUT:drop "
iptables -A icmp-i -j DROP
iptables -A icmp-o -j LOG --log-level 3 --log-prefix "fw:icmp:OUTPUT:drop "
iptables -A icmp-o -j DROP
iptables -A icmp-f -j LOG --log-level 3 --log-prefix "fw:icmp:FORWARD:drop "
iptables -A icmp-f -j DROP

iptables -A icmp-i -j RETURN
iptables -A icmp-o -j RETURN
iptables -A icmp-f -j RETURN

exit 0
