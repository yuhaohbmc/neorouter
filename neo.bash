#!/bin/bash

# Get root permission so don't need to use sudo each time 
sudo -s

# Check and install software updates
apt update && apt upgrade -y

#install software
#Samba for file sharing
#ocserv for VPN
#Qbittorrent-nox-enhanced for torrent and magnet download
#emby for internal media play
#AdGuardHome for DNS and DHCP server
apt install samba ocserv -y

#open ip4 forwarding, TCP BBR and prevent security issues
cp /etc/sysctl.conf  /etc/sysctl.conf.bak
echo net/ipv4/ip_forward=1 >> /etc/sysctl.conf
echo net.ipv4.conf.all.proxy_arp=1 >> /etc/sysctl.conf
echo net.ipv4.conf.all.rp_filter=1 >> /etc/sysctl.conf
echo net.ipv4.conf.default.rp_filter=1 >> /etc/sysctl.conf
echo net.ipv4.tcp_syncookies=1 >> /etc/sysctl.conf
echo net.ipv4.tcp_max_syn_backlog=2048 >> /etc/sysctl.conf
echo net.ipv4.tcp_synack_retries=2 >> /etc/sysctl.conf
echo net.ipv4.tcp_syn_retries=5 >> /etc/sysctl.conf
echo net.core.default_qdisc=fq >> /etc/sysctl.conf
echo net.ipv4.tcp_congestion_control=bbr >> /etc/sysctl.conf
sysctl -p
sysctl net.ipv4.tcp_available_congestion_control
lsmod | grep bbr

#Add NAT to ufw
cp /etc/ufw/before.rules   /etc/ufw/before.rules.bak
echo -e "*nat\n:POSTROUTING ACCEPT [0:0]\n-A POSTROUTING -s 192.168.1.0/24 -o enp3s0 -j MASQUERADE\nCOMMIT" >> /etc/ufw/before.rules.new
cat /etc/ufw/before.rules >> /etc/ufw/before.rules.new
mv /etc/ufw/before.rules.new /etc/ufw/before.rules

#ufw rules for applications and network routing
ufw route allow in on enp2s0 out on enp3s0
ufw allow in on enp3s0 to any port 4443 proto tcp
ufw allow in on enp3s0 to any port 4443 proto udp
ufw allow in on enp3s0 to any port 80 proto tcp
ufw allow in on enp3s0 to any port 443 proto tcp
ufw allow from 192.168.1.0/24


#restart ufw
ufw disable
ufw enable

