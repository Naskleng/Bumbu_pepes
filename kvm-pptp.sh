#!/bin/bash
# Interactive PoPToP install script for XEN VPS
# Tested on Debian 5, 6, and Ubuntu 11.04
# July, 2013 v1.11
# Author: Commander Waffles modified by Regolithmedia
# http://www.putdispenserhere.com/pptp-debian-ubuntu-openvz-setup-script/
echo "######################################################"
echo "Interactive PoPToP Install Script for an Debian KVM VPS"
echo "Modified by Danyjrx"
echo
echo "######################################################"
echo
echo
echo "============================================"
echo "Netzone PPTP Script Installer By Danyjrx"
echo "Pilh Salah Satu:"
echo "1) Install PoPToP server dan buat satu user"
echo "2) Membuat User"
echo "============================================"
read x
if test $x -eq 1; then
    echo "Masukan username yang akan di buat (Contoh : Dany, Meinaki):"
	  read u
	  echo "Masukan Password nya:"
	  read p
# get the VPS IP
ip=`grep address /etc/network/interfaces | grep -v 127.0.0.1 | awk '{print $2}'`
echo
echo "===================================="
echo "Lagi download sama install PoPToP"
echo "===================================="
apt-get update
apt-get -y install pptpd
echo
echo "===================================="
echo "Membuat Konfigurasi Server"
echo "===================================="
cat > /etc/ppp/pptpd-options <<END
name pptpd
refuse-pap
refuse-chap
refuse-mschap
require-mschap-v2
require-mppe-128
ms-dns 8.8.8.8
ms-dns 8.8.4.4
proxyarp
nodefaultroute
lock
nobsdcomp
END
# setting up pptpd.conf
echo "option /etc/ppp/pptpd-options" > /etc/pptpd.conf
echo "logwtmp" >> /etc/pptpd.conf
echo "localip $ip" >> /etc/pptpd.conf
echo "remoteip 10.1.0.1-100" >> /etc/pptpd.conf
# adding new user
echo "$u    *    $p    *" >> /etc/ppp/chap-secrets
echo
echo echo "===================================="
echo "Mengalihkan IPv4 dan menerapkan saat boot"
echo echo "===================================="
cat >> /etc/sysctl.conf <<END
net.ipv4.ip_forward=1
END
sysctl -p
echo
echo "===================================="
echo "Update iptables routing dan menerapkan saat boot"
echo "===================================="
iptables -t nat -A POSTROUTING -j SNAT --to $ip
# saves iptables routing rules and enables them on-boot
iptables-save > /etc/iptables.conf
cat > /etc/network/if-pre-up.d/iptables <<END
#!/bin/sh
iptables-restore < /etc/iptables.conf
END
chmod +x /etc/network/if-pre-up.d/iptables
cat >> /etc/ppp/ip-up <<END
ifconfig ppp0 mtu 1400
END
echo
echo "######################################################"
echo "Restarting PoPToP"
echo "######################################################"
sleep 5
/etc/init.d/pptpd restart
echo
echo "===================================="
echo "Sudah Selesai"
echo "Silahkan konek VPN PPTP $ip dengan user & pass berikut:"
echo "Username:$u ##### Password: $p"
echo "===================================="
echo "Script Edited By Dany Meinaki"
# runs this if option 2 is selected
elif test $x -eq 2; then
    echo "Masukan username yang akan di buat (Contoh : Dany, Meinaki):"
	  read u
	  echo "Masukan Password nya:"
	  read p
# get the VPS IP
ip=`grep address /etc/network/interfaces | grep -v 127.0.0.1 | awk '{print $2}'`
# adding new user
echo "$u    *    $p    *" >> /etc/ppp/chap-secrets
echo
echo "===================================="
echo "User PPTP Sukses di buat!"
echo "Silahkan konek VPN PPTP $ip dengan user & pass berikut:"
echo "Username:$u ##### Password: $p"
echo "===================================="
echo "Script Edited By Dany Meinaki"
else
echo "Invalid selection, quitting."
exit
fi
