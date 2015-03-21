#! /bin/sh
### BEGIN INIT INFO
# Provides:          tcpdump
# Required-Start:    networking
# Required-Stop:
# Should-Start:      
# Default-Start:     1 2 3 4 5
# Default-Stop:	     0 6
# Short-Description: Start the tcpdump packet monitoring process
# Description:       Start the tcpdump packet monitoring process
### END INIT INFO

PATH=/sbin:/usr/sbin:/bin

. /lib/init/vars.sh
. /lib/lsb/init-functions



FIREWALL_DIR=/home/admin/firewall

do_start () {
	tcpdump -i eth0.101 -Z admin -w /data/log/pkt-int-%Y%m%d-%H%M%S.dat -G 14400 -U >/data/log/tcpdump.out 2>&1 &
	exit 0
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
	killall tcpdump
	;;
  status)
	do_status
	exit $?
	;;
  *)
	echo "Usage: tcpdump.sh [start|stop]" >&2
	exit 3
	;;
esac

:
