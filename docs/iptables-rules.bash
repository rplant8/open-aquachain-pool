#!/bin/sh

if [ "$SYSCTL" = "" ]
then
    echo "1" > /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts
else
    $SYSCTL net.ipv4.icmp_echo_ignore_broadcasts="1"
fi

/sbin/iptables -F
/sbin/iptables --policy INPUT DROP
/sbin/iptables --policy OUTPUT ACCEPT
/sbin/iptables --policy FORWARD DROP

# try and block ethereum noise
/sbin/iptables -A INPUT -pudp --sport 30300 -j DROP
/sbin/iptables -A INPUT -ptcp --sport 30300 -j DROP
/sbin/iptables -A INPUT -pudp --sport 30303 -j DROP
/sbin/iptables -A INPUT -ptcp --sport 30303 -j DROP

# allow ssh
/sbin/iptables -A INPUT -ptcp --dport 22 -j ACCEPT

# allow http(s)
/sbin/iptables -A INPUT -ptcp --dport 443 -j ACCEPT
/sbin/iptables -A INPUT -ptcp --dport 80 -j ACCEPT

# people mine to 8888, change if different.
/sbin/iptables -A INPUT -ptcp --dport 8888 -j ACCEPT

/sbin/iptables -A OUTPUT -p icmp -m conntrack --ctstate INVALID -j DROP
/sbin/iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
/sbin/iptables -A INPUT -s localhost -d localhost -j ACCEPT

