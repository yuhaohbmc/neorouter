#!/bin/bash

# Check and install software updates;
echo | add-apt-repository ppa:poplite/qbittorrent-enhanced
apt update
apt upgrade -y


#open ip4 forwarding, TCP BBR and prevent security issues;
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

#Add NAT to ufw;
cp /etc/ufw/before.rules   /etc/ufw/before.rules.bak
echo -e "*nat\n:POSTROUTING ACCEPT [0:0]\n-A POSTROUTING -s 192.168.1.0/24 -o enp3s0 -j MASQUERADE\nCOMMIT" >> /etc/ufw/before.rules.new
cat /etc/ufw/before.rules >> /etc/ufw/before.rules.new
mv /etc/ufw/before.rules.new /etc/ufw/before.rules

#ufw rules for applications and network routing;
ufw route allow in on enp2s0 out on enp3s0
ufw allow in on enp3s0 to any port 4443 proto tcp
ufw allow in on enp3s0 to any port 4443 proto udp
ufw allow in on enp3s0 to any port 80 proto tcp
ufw allow in on enp3s0 to any port 443 proto tcp
ufw allow in on enp3s0 to any port 6881 proto tcp
ufw allow in on enp3s0 to any port 6881 proto udp
ufw allow from 192.168.1.0/24


#restart ufw;
ufw disable
ufw enable

#install software;
#Samba for file sharing;
#ocserv for VPN;
#Qbittorrent-nox-enhanced for torrent and magnet download;
#emby for internal media play;
#AdGuardHome for DNS and DHCP server;
apt install samba ocserv qbittorrent-enhanced-nox -y
systemctl enable qbittorrent-enhanced-nox
wget https://github.com/MediaBrowser/Emby.Releases/releases/download/4.5.4.0/emby-server-deb_4.5.4.0_amd64.deb
dpkg -i emby-server-deb_4.5.4.0_amd64.deb
rm emby-server-deb_4.5.4.0_amd64.deb
wget https://static.adguard.com/adguardhome/release/AdGuardHome_linux_amd64.tar.gz
tar xvf AdGuardHome_linux_amd64.tar.gz
mkdir /usr/share/AdGuardHome
mv AdGuardHome  /usr/share/AdGuardHome
chmod 777 -R /usr/share/AdGuardHome
./usr/share/AdGuardHome -s install
reboot
