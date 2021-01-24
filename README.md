# Ubuntu-Router
To set Ubuntu server 20.04 LTS as home router


Two Nics:

enp2s0: Lan with 192.168.1.0/24
enp3s0: Wan with dhcp

Basic services:
Samba
Ocserv - Openconnect VPN server
AdGuardHome - serve as DNS and DHCP server

Set IP forwarding, NAT and UFW firewall related.


download neo.sh to your local server, grant permissions and run it.

Jellyfin CSS theme(tested working on 24th, Jan, 2021):

@import url('https://ctalvio.github.io/Monochromic/default_style.css');
