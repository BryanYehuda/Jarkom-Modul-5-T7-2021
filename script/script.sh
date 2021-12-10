#!/bin/bash

# Fosha,water7,guanhao,jipangu,Doriki,Maingate,Jorge
FOSHA(){
apt-get update
IPETH0="$(ip -br a | grep eth0 | awk '{print $NF}' | cut -d'/' -f1)"
iptables -t nat -A POSTROUTING -o eth0 -j SNAT --to-source "$IPETH0" -s 10.45.0.0/21

route add -net 10.45.7.0 netmask 255.255.255.128 gw 10.45.7.146 #BLUENO
route add -net 10.45.0.0 netmask 255.255.252.0 gw 10.45.7.146 #CIPHER
route add -net 10.45.7.128 netmask 255.255.255.248 gw 10.45.7.146 #DORIKI & JIPANGU

route add -net 10.45.4.0 netmask 255.255.254.0 gw 10.45.7.150 #ELENA
route add -net 10.45.6.0 netmask 255.255.255.0 gw 10.45.7.150 #FUKORO
route add -net 10.45.7.136 netmask 255.255.255.248 gw 10.45.7.150 #Maingate & Jourge

apt-get install isc-dhcp-relay -y

echo '
SERVERS="10.45.7.131"
INTERFACES="eth2 eth1"
OPTIONS=""
' > /etc/default/isc-dhcp-relay
service isc-dhcp-relay restart
# No.2
iptables -A FORWARD -d 10.45.7.131 -i eth0 -p tcp --dport 80 -j DROP
iptables -A FORWARD -d 10.45.7.130 -i eth0 -p tcp --dport 80 -j DROP

}
WATER7(){
route add -net 0.0.0.0 netmask 0.0.0.0 gw 10.45.7.145
echo "nameserver 192.168.122.1" > /etc/resolv.conf
apt update
apt install isc-dhcp-relay -y
echo '
SERVERS="10.45.7.131"
INTERFACES="eth2 eth3 eth0 eth1"
OPTIONS=""
' > /etc/default/isc-dhcp-relay
service isc-dhcp-relay restart
}
GUANHAO(){
route add -net 0.0.0.0 netmask 0.0.0.0 gw 10.45.7.149
echo "nameserver 192.168.122.1" > /etc/resolv.conf
apt update
apt install isc-dhcp-relay -y
echo '
SERVERS="10.45.7.131"
INTERFACES="eth2 eth3 eth1 eth0"
OPTIONS=""
' > /etc/default/isc-dhcp-relay
service isc-dhcp-relay restart
# No.6
iptables -A PREROUTING -t nat -p tcp -d 10.45.7.130 -m statistic --mode nth --every 2 --packet 0 -j DNAT --to-destination 10.45.7.138:80
iptables -A PREROUTING -t nat -p tcp -d 10.45.7.130 -j DNAT --to-destination 10.45.7.139:80

}
JIPANGU(){
echo "nameserver 192.168.122.1" > /etc/resolv.conf
apt update
apt install isc-dhcp-server -y
echo '
INTERFACES="eth0"
' > /etc/default/isc-dhcp-server

echo '
ddns-update-style none;
option domain-name "example.org";
option domain-name-servers ns1.example.org, ns2.example.org;
default-lease-time 600;
max-lease-time 7200;
log-facility local7;
subnet 10.45.0.0 netmask 255.255.252.0 {
    range 10.45.0.2 10.45.3.254;
    option routers 10.45.0.1;
    option broadcast-address 10.45.3.255;
    option domain-name-servers 10.45.7.130;
    default-lease-time 360;
    max-lease-time 7200;
}
subnet 10.45.7.0 netmask 255.255.255.128 {
    range 10.45.7.2 10.45.7.126;
    option routers 10.45.7.1;
    option broadcast-address 10.45.7.127;
    option domain-name-servers 10.45.7.130;
    default-lease-time 720;
    max-lease-time 7200;
}
subnet 10.45.4.0 netmask 255.255.254.0 {
    range 10.45.4.2 10.45.5.254;
    option routers 10.45.4.1;
    option broadcast-address 10.45.5.255;
    option domain-name-servers 10.45.7.130;
    default-lease-time 720;
    max-lease-time 7200;
}
subnet 10.45.6.0 netmask 255.255.255.0 {
    range 10.45.6.2 10.45.6.254;
    option routers 10.45.6.1;
    option broadcast-address 10.45.6.255;
    option domain-name-servers 10.45.7.130;
    default-lease-time 720;
    max-lease-time 7200;
}
subnet 10.45.7.128 netmask 255.255.255.248 {}
subnet 10.45.7.144 netmask 255.255.255.252 {}
subnet 10.45.7.148 netmask 255.255.255.252 {}
subnet 10.45.7.136 netmask 255.255.255.248 {}
' > /etc/dhcp/dhcpd.conf
service isc-dhcp-server restart

#No. 3 Reject bila terdapat PING ICMP Lebih dari 3
iptables -A INPUT -p icmp -m connlimit --connlimit-above 3 --connlimit-mask 0 -j DROP
}

DORIKI(){
echo "nameserver 192.168.122.1" > /etc/resolv.conf
apt update
apt install bind9 -y
echo '
options {
        directory "/var/cache/bind";
        forwarders {
                192.168.122.1;
        };
        allow-query { any; };
        auth-nxdomain no;    # conform to RFC1035
        listen-on-v6 { any; };
};

' > /etc/bind/named.conf.options
service bind9 restart
#No. 3 Reject bila terdapat PING ICMP Lebih dari 3
iptables -A INPUT -p icmp -m connlimit --connlimit-above 3 --connlimit-mask 0 -j DROP
#No. 4 Akses dari subnet Blueno dan Cipher
#Blueno
iptables -A INPUT -s 10.45.7.0/25 -m time --weekdays Fri,Sat,Sun -j REJECT
iptables -A INPUT -s 10.45.7.0/25 -m time --timestart 00:00 --timestop 06:59 --weekdays Mon,Tue,Wed,Thu -j REJECT
iptables -A INPUT -s 10.45.7.0/25 -m time --timestart 15:01 --timestop 23:59 --weekdays Mon,Tue,Wed,Thu -j REJECT
#Cipher
iptables -A INPUT -s 10.45.0.0/22 -m time --weekdays Fri,Sat,Sun -j REJECT
iptables -A INPUT -s 10.45.0.0/22 -m time --timestart 00:00 --timestop 06:59 --weekdays Mon,Tue,Wed,Thu -j REJECT
iptables -A INPUT -s 10.45.0.0/22 -m time --timestart 15:01 --timestop 23:59 --weekdays Mon,Tue,Wed,Thu -j REJECT
#No. 5 Akses dari subnet Elena dan Fukuro
iptables -A INPUT -s 10.45.4.0/23 -m time --timestart 07:00 --timestop 15:00 -j REJECT #Elena
iptables -A INPUT -s 10.45.6.0/24 -m time --timestart 07:00 --timestop 15:00 -j REJECT #Fukuro
}

MAINGATE(){
echo "nameserver 192.168.122.1" > /etc/resolv.conf
apt update
apt install apache2 -y
service apache2 start
echo "$HOSTNAME" > /var/www/html/index.html
apt install netcat -y
}

JORGE(){
echo "nameserver 192.168.122.1" > /etc/resolv.conf
apt update
apt install apache2 -y
service apache2 start
echo "$HOSTNAME" > /var/www/html/index.html
apt install netcat -y
}

BLUENO(){
apt update
}
CIPHER(){
apt update
}
ELENA(){
apt update
apt install netcat -y
}
FUKOROU(){
apt update
apt install netcat -y
}

if [ $HOSTNAME == "FOSHA" ]
then
    FOSHA
elif [ $HOSTNAME == "WATER7" ]
then
    WATER7
elif [ $HOSTNAME == "GUANHAO" ]
then
    GUANHAO
elif [ $HOSTNAME == "JIPANGU" ]
then
    JIPANGU
elif [ $HOSTNAME == "DORIKI" ]
then
    DORIKI
elif [ $HOSTNAME == "MAINGATE" ]
then
    MAINGATE
elif [ $HOSTNAME == "JORGE" ]
then
    JORGE
elif [ $HOSTNAME == "BLUENO" ]
then
    BLUENO
elif [ $HOSTNAME == "CIPHER" ]
then
    CIPHER
elif [ $HOSTNAME == "ELENA" ]
then
    ELENA
elif [ $HOSTNAME == "FUKOROU" ]
then
    FUKOROU
fi