#!/bin/bash
# Interactive PoPToP install script for an KVM VPS
# Tested on Debian 6 dan 7
# April 2, 2013 v1.11
# Author: Commander Waffles
# http://www.putdispenserhere.com/pptp-debian-ubuntu-openvz-setup-script/
  
echo "======================================================"
echo "Fikriansyah.net | We Learn, We Found and We Share"
echo "Pastiin ppp udah di enable"
echo "Pilih nomor 1 jika vps belum terinstall PPTP VPN"
echo "Jika sudah diinstall, Pilih Nomor 2 untuk menambah user"
echo "######################################################"
echo "######################################################"
echo "Pilihan :"
echo "1) Install PPTP VPN dan membuat user"
echo "2) menambah user"
echo "######################################################"
read $x
if test $x -eq 1; then
    echo "Masukkan username:"
    read u
    echo "masukkan password:"
    read p
  
# get the VPS IP
ip=`ifconfig eth0 | grep 'inet addr' | awk {'print $2'} | sed s/.*://`
  
echo "######################################################"
echo "Downloading and Installing PoPToP"
echo "######################################################"
apt-get update
apt-get -y install pptpd nano shorewall unrar
  
echo "######################################################"
echo "Settting server"
echo "######################################################"
cat > /etc/pptpd.conf<<END
localip 9.9.9.1
remoteip 9.9.9.20-50
END
  
cat > /etc/ppp/pptpd-options <<END
ms-dns 8.8.8.8
ms-dns 8.8.4.4
END
  
# adding new user
echo "$u    pptpd   $p  *" >> /etc/ppp/chap-secrets
  
echo "######################################################"
echo "Forwarding IPv4 and Enabling it on boot"
echo "######################################################"
cat >> /etc/sysctl.conf <<END
net.ipv4.ip_forward=1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.all.rp_filter = 1
net.ipv4.tcp_syncookies = 1
END
  
sysctl -p
  
echo "######################################################"
echo "Updating IPtables Routing and Enabling it on boot"
echo "######################################################"
cd /etc/shorewall
wget https://www.dropbox.com/s/k01cjc2zi9eemsq/shorewall-kvm.rar
unrar e shorewall-kvm.rar
rm shorewall-kvm.rar
echo "shorewall start" >> /etc/rc.local
shorewall restart
/etc/init.d/pptpd restart
  
echo "######################################################"
echo "Server setup complete!"
echo "Connect PPTP VPN dengan IP $ip :"
echo "Username:$u ##### Password: $p"
echo "######################################################"
  
# runs this if option 2 is selected
elif test $x -eq 2; then
    echo "Masukkan username:"
    read u
    echo "ketikkan passwordnya:"
    read p
  
# get the VPS IP
ip=`ifconfig eth0 | grep 'inet addr' | awk {'print $2'} | sed s/.*://`
  
# adding new user
echo "$u    pptpd   $p  *" >> /etc/ppp/chap-secrets
  
echo "######################################################"
echo "User PPTP VPN sudah ditambah!"
echo "Connect PPTP VPN dengan IP $ip :"
echo "Username:$u ##### Password: $p"
echo "######################################################"
  
else
echo "Invalid selection, quitting."
exit
fi
