# Jarkom-Modul-5-T7-2021      
### Laporan Resmi Pengerjaan Sesi Lab Jaringan Komputer     
        
#### Nama Anggota Kelompok :      
1. Naufal Aprilian (05311940000007)     
2. Bryan Yehuda Mannuel (05311940000021)      
3. Mulki Kusumah    


## Soal Modul 5
Setelah kalian mempelajari semua modul yang telah diberikan, Luffy ingin meminta bantuan untuk terakhir kalinya kepada kalian. Dan kalian dengan senang hati mau membantu Luffy.      
1. Tugas pertama kalian yaitu membuat topologi jaringan sesuai dengan rancangan yang diberikan Luffy
2. Keterangan : 	Doriki adalah DNS Server
		Jipangu adalah DHCP Server
		Maingate dan Jorge adalah Web Server
		Jumlah Host pada Blueno adalah 100 host
		Jumlah Host pada Cipher adalah 700 host
		Jumlah Host pada Elena adalah 300 host
		Jumlah Host pada Fukurou adalah 200 host
3. Karena kalian telah belajar subnetting dan routing, Luffy ingin meminta kalian untuk membuat topologi tersebut menggunakan teknik CIDR atau VLSM. setelah melakukan subnetting, 
4. Kalian juga diharuskan melakukan Routing agar setiap perangkat pada jaringan tersebut dapat terhubung.
5. Tugas berikutnya adalah memberikan ip pada subnet Blueno, Cipher, Fukurou, dan Elena secara dinamis menggunakan bantuan DHCP server. Kemudian kalian ingat bahwa kalian harus setting DHCP Relay pada router yang menghubungkannya.

## Jawaban Modul 

### Routing
[ Foosha ]
```
route add -net 10.45.7.0 netmask 255.255.255.128 gw 10.45.7.146 #BLUENO
route add -net 10.45.0.0 netmask 255.255.252.0 gw 10.45.7.146 #CIPHER
route add -net 10.45.7.128 netmask 255.255.255.248 gw 10.45.7.146 #DORIKI & JIPANGU

route add -net 10.45.4.0 netmask 255.255.254.0 gw 10.45.7.150 #ELENA
route add -net 10.45.6.0 netmask 255.255.255.0 gw 10.45.7.150 #FUKORO
route add -net 10.45.7.136 netmask 255.255.255.248 gw 10.45.7.150 #Maingate & Jourge
```
[ Water7 ]
```
route add -net 0.0.0.0 netmask 0.0.0.0 gw 10.45.7.145
```

[ Guanhao ]
```
route add -net 0.0.0.0 netmask 0.0.0.0 gw 10.45.7.149
```   
[ Doriki adalah DNS Server ]
```
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
```
[ Jipangu adalah DHCP Server ]
```
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
```

[ Maingate dan Jorge adalah Web Server ]
```
apt update
apt install apache2 -y
service apache2 start
echo "$HOSTNAME" > /var/www/html/index.html
```

### Soal Nomor 1
Agar topologi yang kalian buat dapat mengakses keluar, kalian diminta untuk mengkonfigurasi Foosha menggunakan iptables, tetapi Luffy tidak ingin menggunakan MASQUERADE.

### Jawaban Nomor 1
[ FOOSHA ]
```
iptables -A INPUT -p icmp -m connlimit --connlimit-above 3 --connlimit-mask 0 -j DROP
```

### nomor 2
[ FOSHA ]
iptables -A FORWARD -d 10.45.7.131 -i eth0 -p tcp --dport 80 -j DROP
iptables -A FORWARD -d 10.45.7.130 -i eth0 -p tcp --dport 80 -j DROP

### nomor 3
[ Jipangu ]
iptables -A INPUT -p icmp -m connlimit --connlimit-above 3 --connlimit-mask 0 -j DROP

[ Doriki ]
#No. 3 Reject bila terdapat PING ICMP Lebih dari 3
iptables -A INPUT -p icmp -m connlimit --connlimit-above 3 --connlimit-mask 0 -j DROP

### nomor 4
[ Doriki ]
#No. 4 Akses dari subnet Blueno dan Cipher
#Blueno
iptables -A INPUT -s 10.45.7.0/25 -m time --weekdays Fri,Sat,Sun -j REJECT
iptables -A INPUT -s 10.45.7.0/25 -m time --timestart 00:00 --timestop 06:59 --weekdays Mon,Tue,Wed,Thu -j REJECT
iptables -A INPUT -s 10.45.7.0/25 -m time --timestart 15:01 --timestop 23:59 --weekdays Mon,Tue,Wed,Thu -j REJECT
#Cipher
iptables -A INPUT -s 10.45.0.0/22 -m time --weekdays Fri,Sat,Sun -j REJECT
iptables -A INPUT -s 10.45.0.0/22 -m time --timestart 00:00 --timestop 06:59 --weekdays Mon,Tue,Wed,Thu -j REJECT
iptables -A INPUT -s 10.45.0.0/22 -m time --timestart 15:01 --timestop 23:59 --weekdays Mon,Tue,Wed,Thu -j REJECT

### nomor 5
#No. 5 Akses dari subnet Elena dan Fukuro
iptables -A INPUT -s 10.45.4.0/23 -m time --timestart 07:00 --timestop 15:00 -j REJECT #Elena
iptables -A INPUT -s 10.45.6.0/24 -m time --timestart 07:00 --timestop 15:00 -j REJECT #Fukuro

### nomor 6
[ Guanhao ]
# No.6
iptables -A PREROUTING -t nat -p tcp -d 10.45.7.130 -m statistic --mode nth --every 2 --packet 0 -j DNAT --to-destination 10.45.7.138:80
iptables -A PREROUTING -t nat -p tcp -d 10.45.7.130 -j DNAT --to-destination 10.45.7.139:80

