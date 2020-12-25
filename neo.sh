#!/bin/bash

lannic="enp2s0"
wannic="enp3s0"
lancdir="192.168.1.0/24"

# Check and install software updates;
echo | add-apt-repository ppa:poplite/qbittorrent-enhanced
apt update
apt upgrade -y


#open ip4 forwarding, TCP BBR and prevent security issues;
cp /etc/sysctl.conf  /etc/sysctl.conf.bak
echo net/ipv4/ip_forward=1 >> /etc/sysctl.conf

# Protect from IP Spoofing  
echo net.ipv4.conf.all.rp_filter = 1 >> /etc/sysctl.conf
echo net.ipv4.conf.default.rp_filter = 1 >> /etc/sysctl.conf

# Ignore ICMP broadcast requests
echo net.ipv4.icmp_echo_ignore_broadcasts = 1 >> /etc/sysctl.conf

# Protect from bad icmp error messages
echo net.ipv4.icmp_ignore_bogus_error_responses = 1 >> /etc/sysctl.conf

# Disable source packet routing
echo net.ipv4.conf.all.accept_source_route = 0 >> /etc/sysctl.conf
echo net.ipv4.conf.default.accept_source_route = 0 >> /etc/sysctl.conf


# Turn on exec shield
echo kernel.exec-shield = 1 >> /etc/sysctl.conf
echo kernel.randomize_va_space = 1 >> /etc/sysctl.conf

# Block SYN attacks
echo net.ipv4.tcp_syncookies = 1 >> /etc/sysctl.conf
echo net.ipv4.tcp_max_syn_backlog = 2048 >> /etc/sysctl.conf
echo net.ipv4.tcp_synack_retries = 2 >> /etc/sysctl.conf
echo net.ipv4.tcp_syn_retries = 5 >> /etc/sysctl.conf

# Log Martians  
echo net.ipv4.conf.all.log_martians = 1 >> /etc/sysctl.conf
echo net.ipv4.icmp_ignore_bogus_error_responses = 1 >> /etc/sysctl.conf

# Ignore send redirects
echo net.ipv4.conf.all.send_redirects = 0 >> /etc/sysctl.conf
echo net.ipv4.conf.default.send_redirects = 0 >> /etc/sysctl.conf

# Ignore ICMP redirects
echo net.ipv4.conf.all.accept_redirects = 0 >> /etc/sysctl.conf
echo net.ipv4.conf.default.accept_redirects = 0 >> /etc/sysctl.conf
echo net.ipv4.conf.all.secure_redirects = 0 >> /etc/sysctl.conf
echo net.ipv4.conf.default.secure_redirects = 0 >> /etc/sysctl.conf

#enable ARP for same subnet in OpenConnect VPN
net.ipv4.conf.all.proxy_arp=1

#increase maximum file size that the system can handle
fs.file-max=100000

# This will increase the amount of memory available for socket input/output queues
echo net.core.rmem_default = 256960 >> /etc/sysctl.conf
echo net.core.rmem_max = 33554432 >> /etc/sysctl.conf
echo net.ipv4.tcp_rmem = 10240 87380 33554432 >> /etc/sysctl.conf
echo net.core.wmem_default = 256960 >> /etc/sysctl.conf
echo net.core.wmem_max = 33554432 >> /etc/sysctl.conf
echo net.ipv4.tcp_wmem = 10240 87380 33554432 >> /etc/sysctl.conf
echo net.ipv4.tcp_mem = 33554432 33554432 33554432 >> /etc/sysctl.conf
echo net.core.optmem_max = 87380 >> /etc/sysctl.conf


#Enable TCP BBR
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
ufw default allow routed
ufw default deny incoming
ufw default deny outgoing
ufw allow out on ${wannic} to any
ufw allow in on ${wannic} to any port 4443 proto tcp
ufw allow in on ${wannic} to any port 1030 proto udp
ufw allow in on ${wannic} to any port 80 proto tcp
ufw allow in on ${wannic} to any port 443 proto tcp
ufw allow in on ${wannic} to any port 6881 proto tcp
ufw allow in on ${wannic} to any port 6881 proto udp
ufw allow proto tcp from ${lancdir} to 192.168.1.1 port 22
ufw allow from ${lancdir}


#restart ufw;
ufw disable
ufw enable -y

#install software;
#Samba for file sharing;
#Qbittorrent-nox-enhanced for torrent and magnet download;
#emby for internal media play;
#AdGuardHome for DNS and DHCP server;
apt install samba qbittorrent-enhanced-nox -y
systemctl enable qbittorrent-enhanced-nox
wget https://github.com/MediaBrowser/Emby.Releases/releases/download/4.5.4.0/emby-server-deb_4.5.4.0_amd64.deb
dpkg -i emby-server-deb_4.5.4.0_amd64.deb
rm emby-server-deb_4.5.4.0_amd64.deb
wget https://static.adguard.com/adguardhome/release/AdGuardHome_linux_amd64.tar.gz
tar xvf AdGuardHome_linux_amd64.tar.gz
mv AdGuardHome  /usr/share/
chmod 777 -R /usr/share/AdGuardHome
./usr/share/AdGuardHome -s install

# Install BT Panel for Website Hosting and SSL;
curl -sSO http://download.bt.cn/install/install_panel.sh && bash install_panel.sh -y

#Compile the latest version of ocserv 1.1.2 and install
wget https://raw.githubusercontent.com/NYOOBEO/Ubuntu-Router/main/ocserv.sh
chmod 777 ocserv.sh
./ocserv.sh
