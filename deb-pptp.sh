#!/bin/bash
# Interactive PoPToP install script for an OpenVZ VPS
# Tested on Debian 5, 6, and Ubuntu 11.04
# April 2, 2013 v1.11
# http://www.putdispenserhere.com/pptp-debian-ubuntu-openvz-setup-script/

echo "######################################################"
echo "Interactive PoPToP Install Script for an OpenVZ VPS"
echo
echo "Make sure to contact your provider and have them enable"
echo "IPtables and ppp modules prior to setting up PoPToP."
echo "PPP can also be enabled from SolusVM."
echo
echo "You need to set up the server before creating more users."
echo "A separate user is required per connection or machine."
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
	echo "Enter username that you want to create (eg. client1 or john):"
	read u
	echo "Specify password that you want the server to use:"
	read p

# get the VPS IP
ip=`ifconfig venet0:0 | grep 'inet addr' | awk {'print $2'} | sed s/.*://`

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
echo "$u	*	$p	*" >> /etc/ppp/chap-secrets

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
echo "===================================="
echo "Restart PoPToP"
echo "===================================="
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
ip=`ifconfig venet0:0 | grep 'inet addr' | awk {'print $2'} | sed s/.*://`

# adding new user
echo "$u	*	$p	*" >> /etc/ppp/chap-secrets

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
