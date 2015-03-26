#!/bin/sh
#
# Rules controlling traffic from the inside to the outside
#

. functions.sh

# mail
forward_to_outside tcp smtp
forward_to_outside tcp pop3
forward_to_outside tcp imap
forward_to_outside tcp imaps

# SSH
forward_to_outside tcp ssh

# web
forward_to_outside tcp http
forward_to_outside tcp https
forward_to_outside tcp 81
forward_to_outside tcp 8000
forward_to_outside tcp 8080
forward_to_outside tcp 8081

# Adobe flash security policy
forward_to_outside tcp 843

# Akamai CDN
forward_to_outside tcp 1935

# telnet
forward_to_outside tcp telnet

# DNS
forward_to_outside tcp domain
forward_to_outside udp domain

# NTP
forward_to_outside tcp ntp
forward_to_outside udp ntp

# ms-streaming
forward_to_outside tcp 1755

# RTSP / RealPlayer
forward_to_outside tcp 554
forward_to_outside tcp 322

# cpanel
forward_to_outside tcp 2083

# IJ Cloud Printing service
forward_to_outside tcp 5222

# Android market
forward_to_outside tcp 5228

# DynDNS query URL
forward_to_outside tcp 8245

# Allow Jenny to RDP to uni
forward_to_outside tcp 3389

# GIT Repos
forward_to_outside tcp 9418

# Pobox SMTP
forward_to_outside tcp 465

# subversion: svn://
forward_to_outside tcp 3690

# Yum repos
forward_to_outside tcp 4040

#
# Stuff from Windows et al.
#
forward_to_outside tcp 40001:40046  # MS updates, errors, authentication
forward_to_outside tcp 12350        # Skype
forward_to_outside tcp 33033        # Skype



#
# Finally, rewrite the source addresses of all outgoing packets
# (dynamic external address)
#
iptables -t nat -A POSTROUTING $TO_OUTSIDE -j MASQUERADE

exit 0
