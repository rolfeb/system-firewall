#!/bin/sh
#
# Rules controlling traffic from the inside to the outside
#

. functions.sh

# special dispensation for specific hosts
# forward_host_to_outside 192.168.13.35/32    # Scott's laptop

# mail
forward_to_outside tcp smtp
forward_to_outside tcp pop3
forward_to_outside tcp pop3s
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

# Apple push notification service
forward_to_outside tcp 5223 17.0.0.0/8

#
# Stuff from Windows et al.
#
forward_to_outside tcp 40001:40046  # MS updates, errors, authentication
forward_to_outside tcp 12350        # Skype
forward_to_outside tcp 33033        # Skype

#
# Traffic from Android (Galaxy S7 phone)
#
# tcp/7275 = User Plane Location protocol
# udp/443 = Google QUIC protocol
# tcp/5223 = WhatsApp
#
forward_to_outside tcp 7275
forward_to_outside udp 443
forward_to_outside tcp 5223
forward_to_outside udp 3478

#
# Petcare hub
#
forward_to_outside tcp 8883

#
# Jamie's mac uses PIA, so let it do its "pinging" to find the closest server
#
forward_host_to_outside 192.168.13.12 udp 8888

#
# Finally, rewrite the source addresses of all outgoing packets
# (dynamic external address)
#
iptables -t nat -A POSTROUTING $TO_OUTSIDE -j MASQUERADE

exit 0
