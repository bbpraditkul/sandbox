#Centos 6.7 Kickstart net install
#version=1.0

#********************************
# The following kickstart script was able to successfully install Centos 6.7 on a VMWare virtual box.
# To invoke the kickstart, "tab" on the boot screen and add:
# >>> vmlinuz initrd=initrd.img asknetwork ks=http://192.168.1.122/centos-65.ks
#

#********************************
# "interactive": inspect each value entered for debugging
#interactive

#********************************
# "text": perform the installation in text mode (not the default graphical mode)
text

#********************************
# "skipx": skip X installation on the system
skipx

install
url --url http://centos.fastbull.org/centos/6/os/x86_64/

#********************************
# "repo": sources to use for package installation (below)
repo --name=epel --baseurl=http://download.fedoraproject.org/pub/epel/6/x86_64/
repo --name=updates --baseurl=http://centos.fastbull.org/centos/6/updates/x86_64/

lang en_US.UTF-8

#********************************
#keyboard set to "us"
keyboard us

rootpw welcome

#********************************
#firewall
#don't config any iptable rules
firewall --disabled

#********************************
#authconfig sets up authentication for the system
authconfig --enableshadow --passalgo=sha512

#********************************
#disable SELinux on the entire system
selinux --disabled
timezone --utc US/Pacific

#********************************
#bootloader specifies where the boot record should be written
bootloader --location=mbr

#********************************
#any invalid partition tables are initialized (destroys all of the contents of disks)
zerombr

#********************************
#clearpart
#removes partitions prior to creation of new partitions
clearpart --all --initlabel

#********************************
#create the partition first
part /boot --fstype ext4 --fsoptions="noatime" --size=200
part pv.01 --size 1 --grow

#********************************
#then create the logical volume group
volgroup vg0 pv.01

#********************************
#then create the logical volume to occupy the space; consider occupying 90% of remaining space
#logvol (optional) creates logical volume for LVM; tip: don't use "-"
logvol swap --fstype swap --name=swap --vgname=vg0 --size 512
logvol / --fstype ext4 --fsoptions="noatime" --name=root --vgname=vg0 --size 4096 --grow

#********************************
services --enabled=postfix,network,ntpd,ntpdate

reboot

%packages --nobase
epel-release
openssh-clients
openssh-server
yum
at
acpid
vixie-cron
cronie-noanacron
crontabs
logrotate
ntp
ntpdate
rsync
which
wget
-prelink
-selinux-policy-targeted
