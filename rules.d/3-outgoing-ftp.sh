#!/bin/sh
#
# Rules controlling traffic from the inside to the outside - FTP
#

. functions.sh

#
# control port
#
# client: -> server: 21   (new allowed)
# client: <- server: 21   (established only)
#
iptables -A FORWARD -p tcp --dport ftp \
    $FROM_INSIDE $TO_OUTSIDE \
    -m state --state NEW,ESTABLISHED -j ACCEPT

iptables -A FORWARD -p tcp --sport ftp \
    $FROM_OUTSIDE $TO_INSIDE \
    -m state --state ESTABLISHED -j ACCEPT

#
# data port - active mode
#
# client: <- server: 20   (related allowed)
# client: -> server: 20   (established only)
#
iptables -A FORWARD -p tcp --sport ftp-data \
    $FROM_OUTSIDE $TO_INSIDE \
    -m state --state RELATED,ESTABLISHED -j ACCEPT

iptables -A FORWARD -p tcp --dport ftp-data \
    $FROM_INSIDE $TO_OUTSIDE \
    -m state --state ESTABLISHED -j ACCEPT

#
# data port - passive mode
#
# client: >1023 -> server: >1023    (related allowed)
# client: >1023 <- server: >1023    (established only)
#
iptables -A FORWARD -p tcp --sport 1023: --dport 1023: \
    $FROM_INSIDE $TO_OUTSIDE \
    -m state --state RELATED,ESTABLISHED -j ACCEPT

iptables -A FORWARD -p tcp --sport 1023: --dport 1023: \
    $FROM_OUTSIDE $TO_INSIDE \
    -m state --state ESTABLISHED -j ACCEPT

exit 0
