#! /bin/sh
### BEGIN INIT INFO
# Provides:          firewall
# Required-Start:    networking
# Required-Stop:
# Should-Start:      
# Default-Start:     1 2 3 4 5
# Default-Stop:      0 6
# Short-Description: Initialise the firewall rules
# Description:       Initialises the iptables firewall rules.
### END INIT INFO

PATH=/sbin:/bin

. /lib/init/vars.sh
. /lib/lsb/init-functions

FIREWALL_DIR=/home/admin/firewall

do_start () {
	if [ ! -d $FIREWALL_DIR ]
	then
		echo "Error: config directory $FIREWALL_DIR not found" >&2
		exit 2
	fi
	$FIREWALL_DIR/install.sh > /var/tmp/firewall.log 2>&1
	ES=$?
	exit $ES
}

do_status () {
	return 0
}

case "$1" in
  start|"")
	do_start
	;;
  restart|reload|force-reload)
	do_start
	;;
  stop)
	# No-op
	;;
  status)
	do_status
	exit $?
	;;
  *)
	echo "Usage: firewall.sh [start|stop]" >&2
	exit 3
	;;
esac

:
