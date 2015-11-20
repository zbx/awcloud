#!/bin/bash
#
# veth-peers  OpenStack linuxbridge plugin helper
#
# chkconfig:   - 97 03
# description: Support VLANs using Linux bridging helper
### END INIT INFO

netdev_ex=br-p
netdev_prv=br-ovs-bond0

ex_lb="${netdev_ex}-lb"
lb_ex="lb-${netdev_ex}"
prv_lb="${netdev_prv}-lb"
lb_prv="lb-${netdev_prv}"

prog=veth-peers

start() {
    echo "Starting $prog: "
    ovs-vsctl del-port ${netdev_ex} ${lb_ex}
    ovs-vsctl del-port ${netdev_prv} ${lb_prv}
    ip link add ${ex_lb} type veth peer name ${lb_ex}
    ifconfig ${ex_lb} up
    ifconfig ${lb_ex} up
    ip link add ${prv_lb} type veth peer name ${lb_prv}
    ifconfig ${prv_lb} up
    ifconfig ${lb_prv} up
    ovs-vsctl add-port ${netdev_ex} ${lb_ex}
    ovs-vsctl add-port ${netdev_prv} ${lb_prv}
    ovs-vsctl set port ${lb_ex} vlan_mode=trunk
    ovs-vsctl clear port ${lb_ex} trunks
    ovs-vsctl set port ${lb_prv} vlan_mode=trunk
    ovs-vsctl clear port ${lb_prv} trunks
    echo
    return 0
}

status() {
    ip link show ${ex_lb}
    ip link show ${lb_ex}
    ip link show ${prv_lb}
    ip link show ${lb_prv} 
    ovs-vsctl port-to-br ${lb_ex}
    ovs-vsctl port-to-br ${lb_prv}
    echo physnet1:${ex_lb}
    echo physnet2:${prv_lb}
    retval=$?
    echo
    return $retval
}

stop() {
    echo "Stopping $prog: "
    ovs-vsctl del-port ${netdev_ex} ${lb_ex}
    ovs-vsctl del-port ${netdev_prv} ${lb_prv}
    return 0
}

restart() {
    stop
    start
}

reload() {
    restart
}

force_reload() {
    restart
}


case "$1" in
    start)
        $1
        ;;
    stop)
        $1
        ;;
    restart)
        $1
        ;;
    reload)
        $1
        ;;
    force-reload)
        force_reload
        ;;
    status)
        $1
        ;;
    condrestart|try-restart)
        restart
        ;;
    *)
        echo $"Usage: $0 {start|stop|status|restart|condrestart|try-restart|reload|force-reload}"
        exit 2
esac
exit $?

