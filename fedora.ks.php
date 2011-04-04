<?php 
header('Content-type: text/plain');

$sHostNumber			=	"62";
$sInstallDisk			=	"sda";
$sInstallCapacity		=	"2TB";

$sRootPassword			= 	'$1$k21VGaAW$TRce5HE6YJ0cyKoV3RhpI0';

$sIp					=	"10.11." . "$sHostNumber" . ".10";
$sHostName				=	"fedora" . "$sHostNumber" . ".krishnan.us";
$sGateway				=	"10.1.1.1";
$lstDnsServer			=	"68.87.76.178,66.240.48.9,4.2.2.3";
$sNetmask				=	"255.0.0.0";

$sUserId				=	"610";
$sUserName				=	"rajesh";
$sUserGecos				=	"Rajesh Krishnan";
$sUserPassword			=	$sRootPassword;
$sGroupId				=	"600";
$sGroupName				=	"krish";

# compute the current full path ...
$sThisHostProtocol	= "";
$sThisHostPortSuffix = "";
$sThisHostPath = "";
if ($_SERVER["HTTPS"] == on)
{
	$sThisHostProtocol = "https";
	$sThisHostPortSuffix = ($_SERVER["SERVER_PORT"] == 443) ? "" : ":" . $_SERVER["SERVER_PORT"];
}
else
{
	$sThisHostProtocol = "http";
	$sThisHostPortSuffix = ($_SERVER["SERVER_PORT"] == 80) ? "" : ":" . $_SERVER["SERVER_PORT"];
}
$sThisHostPath = $sThisHostProtocol . "://"  . $_SERVER["SERVER_NAME"] . $sThisHostPortSuffix .  $_SERVER["REQUEST_URI"] ;

$sThisHostDir = dirname($sThisHostPath) ; 
?>


# -----------------------------------------------------------------------------------------------------
#platform=x86, AMD64, or Intel EM64T
#version=DEVEL
# Install OS instead of upgrade
install
# Use CDROM installation media
cdrom
# Use graphical install
# graphical
text

# Root password
rootpw --iscrypted '<?php echo $sRootPassword?>'
# Network information
network  --bootproto=static --device=eth0 --gateway=<?php echo $sGateway?> --ip=<?php echo $sIp?> --nameserver=<?php echo $lstDnsServer?> --netmask=<?php echo $sNetmask?> --hostname=<?php echo $sHostName ?> --onboot=on 
# System authorization information
auth  --useshadow  --passalgo=sha512
# System keyboard
keyboard us
# System language
lang en_US
# System timezone
timezone --utc  America/Los_Angeles

# Firewall configuration
firewall --disabled
firstboot --disabled
# SELinux configuration
selinux --disabled
# Do not configure the X Window System
skipx

# Installation logging level
logging --level=debug

group --gid=<?php echo $sGroupId?> --name=<?php echo $sUserName?> 
user --name=<?php echo $sUserName  ?> --gecos="<?php echo  $sUserGecos ?>" --groups=wheel,disk --password='<?php echo $sUserPassword ?>' --iscrypted --shell=/bin/bash --homedir=/home/<?php echo  $sUserName ?> --uid=<?php echo $sUserId  ?> 

# Reboot after installation
reboot


# -----------------------------------------------------------------------------------------------------
services --enabled=sshd,puppetd 

sshpw --username=root --plaintext fedora


# -----------------------------------------------------------------------------------------------------
# System bootloader configuration
bootloader --append="vga=0x317" --location=mbr
# Clear the Master Boot Record
zerombr
# Partition clearing information
#  NOTE: initlabel initializes the partition table to msdos scheme, so don't use it.
# clearpart --all --drives=<?php echo $sInstallDisk?> 
# Disk partitioning information
part /boot												--label=<?php echo $sInstallDisk?>-boot		--fstype="ext4" --onpart=<?php echo $sInstallDisk?>1 --noformat 
part swap												--label=<?php echo $sInstallDisk?>-swap		--fstype="swap" --onpart=<?php echo $sInstallDisk?>2 --noformat 
part /													--label=<?php echo $sInstallDisk?>-os3		--fstype="ext4" --onpart=<?php echo $sInstallDisk?>3 --noformat 
part /mnt/localhost/<?php echo $sInstallDisk?>/os4		--label=<?php echo $sInstallDisk?>-os4		--fstype="ext4" --onpart=<?php echo $sInstallDisk?>4 --noformat 
part /mnt/localhost/<?php echo $sInstallDisk?>/os5		--label=<?php echo $sInstallDisk?>-os5		--fstype="ext4" --onpart=<?php echo $sInstallDisk?>5 --noformat 
part /home												--label=<?php echo $sInstallDisk?>-home		--fstype="ext4" --onpart=<?php echo $sInstallDisk?>6 --noformat 
part /mnt/localhost/<?php echo $sInstallDisk?>/servdata	--label=<?php echo $sInstallDisk?>-servdata	--fstype="ext4" --onpart=<?php echo $sInstallDisk?>7 --noformat 
part /mnt/localhost/<?php echo $sInstallDisk?>/storage	--label=<?php echo $sInstallDisk?>-storage	--fstype="ext4" --onpart=<?php echo $sInstallDisk?>8 --noformat 

# -----------------------------------------------------------------------------------------------------
%pre --interpreter=/bin/bash
	parted -s	/dev/<?php echo $sInstallDisk?> mklabel gpt
	parted -s	/dev/<?php echo $sInstallDisk?> mkpart <?php echo $sInstallDisk?>-boot		1MB		1024MB
	parted -s	/dev/<?php echo $sInstallDisk?> mkpart <?php echo $sInstallDisk?>-swap		1024MB	50GB
	parted -s	/dev/<?php echo $sInstallDisk?> mkpart <?php echo $sInstallDisk?>-os3		50GB	100GB
	parted -s	/dev/<?php echo $sInstallDisk?> mkpart <?php echo $sInstallDisk?>-os4		100GB	150GB
	parted -s	/dev/<?php echo $sInstallDisk?> mkpart <?php echo $sInstallDisk?>-os5		150GB	200GB
	parted -s	/dev/<?php echo $sInstallDisk?> mkpart <?php echo $sInstallDisk?>-home		200GB	500GB
	parted -s	/dev/<?php echo $sInstallDisk?> mkpart <?php echo $sInstallDisk?>-servdata	500GB	1000GB
	parted -s	/dev/<?php echo $sInstallDisk?> mkpart <?php echo $sInstallDisk?>-storage	1000GB	2TB
	
	mkfs.ext4	-m 1	-L	<?php echo $sInstallDisk?>-boot		/dev/<?php echo $sInstallDisk?>1
	mkswap				-L	<?php echo $sInstallDisk?>-swap		/dev/<?php echo $sInstallDisk?>2
	mkfs.ext4	-m 1	-L	<?php echo $sInstallDisk?>-os3		/dev/<?php echo $sInstallDisk?>3
	mkfs.ext4	-m 1	-L	<?php echo $sInstallDisk?>-os4		/dev/<?php echo $sInstallDisk?>4
	mkfs.ext4	-m 1	-L	<?php echo $sInstallDisk?>-os5		/dev/<?php echo $sInstallDisk?>5
	mkfs.ext4	-m 1	-L	<?php echo $sInstallDisk?>-home		/dev/<?php echo $sInstallDisk?>6
	mkfs.ext4	-m 1	-L	<?php echo $sInstallDisk?>-servdata	/dev/<?php echo $sInstallDisk?>7
	mkfs.ext4	-m 1	-L	<?php echo $sInstallDisk?>-storage	/dev/<?php echo $sInstallDisk?>8
%end

# -----------------------------------------------------------------------------------------------------
%post --nochroot
	cp /etc/resolv.conf /mnt/sysimage/etc/resolv.conf
%end


# -----------------------------------------------------------------------------------------------------
%post --interpreter=/bin/bash
	yum -y install yum-{metadata-parser,presto,utils,arch,plugin-{aliases,changelog,downloadonly,filter-data,fs-snapshot,keys,list-data,merge-conf,post-transaction-actions,priorities,protectbase,ps,rpm-warm-cache,show-leaves,tmprepo,tsflags,upgrade-helper,verify,versionlock}}
	yum -y install htop most redhat-lsb puppet wget openssh-clients openssh-server augeas gcc make
	yum -y update kernel{,-{doc,devel,headers}}

	/sbin/chkconfig network on

	mkdir -p /tmp/root/
	mkdir -p /root/.ssh/
	chmod go-rwx /root/.ssh/


	if [ -x /usr/bin/wget ] ; then 
		echo "INFO:  Downloading the additional /etc/profile.d scripts  ..."
		wget -P /etc/profile.d/ <?php echo $sThisHostDir ?>/bashrc.local.sh
		wget -P /etc/profile.d/ <?php echo $sThisHostDir ?>/bashrc.local.cpumode.sh
		wget -P /etc/profile.d/ <?php echo $sThisHostDir ?>/bashrc.local.machine.sh

		echo "INFO:  Downloading ssh key for root ..."
		wget -P /root/.ssh/  <?php echo $sThisHostDir ?>/authorized_keys

		echo "INFO:  Downloading additonal RPMs  ..."
		# download additional rpms and install them ...
		wget -P /tmp/root/ -c http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-stable.noarch.rpm
		wget -P /tmp/root/ -c http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-stable.noarch.rpm
		wget -P /tmp/root/ -c http://download.fedora.redhat.com/pub/fedora/linux/releases/13/Everything/x86_64/os/Packages/rubygem-actionmailer-2.3.5-1.fc13.noarch.rpm 
		wget -P /tmp/root/ -c http://download.fedora.redhat.com/pub/fedora/linux/releases/13/Everything/x86_64/os/Packages/rubygem-actionpack-2.3.5-1.fc13.noarch.rpm 
		wget -P /tmp/root/ -c http://download.fedora.redhat.com/pub/fedora/linux/releases/13/Everything/x86_64/os/Packages/rubygem-activeldap-1.2.1-1.fc13.noarch.rpm 
		wget -P /tmp/root/ -c http://download.fedora.redhat.com/pub/fedora/linux/releases/13/Everything/x86_64/os/Packages/rubygem-activerecord-2.3.5-1.fc13.noarch.rpm 
		wget -P /tmp/root/ -c http://download.fedora.redhat.com/pub/fedora/linux/releases/13/Everything/x86_64/os/Packages/rubygem-activeresource-2.3.5-1.fc13.noarch.rpm 
		wget -P /tmp/root/ -c http://download.fedora.redhat.com/pub/fedora/linux/releases/13/Everything/x86_64/os/Packages/rubygem-activesupport-2.3.5-1.fc13.noarch.rpm 
		wget -P /tmp/root/ -c http://download.fedora.redhat.com/pub/fedora/linux/releases/13/Everything/x86_64/os/Packages/rubygem-gettext_activerecord-2.1.0-1.fc13.noarch.rpm 
		yum -y localinstall --nogpgcheck /tmp/root/*.rpm
		
		# initialize repository for flash plugin ...
		if [ $(uname -i) == "x86_64" ] ; then
			wget -P /tmp/root/ -c http://www.linux-ati-drivers.homecall.co.uk/flashplayer.x86_64/flash-release-1-2.noarch.rpm
		elif [ $(uname -i) == "i386" || $(uname -i) == "i586" || $(uname -i) == "i686" ] ; then
			# install Adobe's 32-bit flash rpm repository ...
			wget -P /tmp/root/ -c http://linuxdownload.adobe.com/adobe-release/adobe-release-i386-1.0-1.noarch.rpm
		fi
		# install the flash plugin itself ...
		yum -y install flash-plugin
	fi




	[ -f /etc/vimrc ] && echo set background=dark tabstop=4 softtabstop=4 shiftwidth=4 noexpandtab  >> /etc/vimrc
	[ -f /etc/rc.d/init.d/NetworkManager ]		&& /sbin/chkconfig NetworkManager off
	[ -f /etc/rc.d/init.d/puppetd ]				&& /sbin/chkconfig puppetd on
	[ -f /etc/rc.d/init.d/pcscd ]				&& /sbin/chkconfig pcscd off

	if [ -x /usr/bin/augtool ] ; then
		echo  'set /files/boot/grub/menu.lst/timeout 10'						>> /tmp/root/install-config.aug
		echo  'rm  /files/boot/grub/menu.lst/hiddenmenu'						>> /tmp/root/install-config.aug
		echo  'rm  /files/boot/grub/menu.lst/title/kernel/rhgb'					>> /tmp/root/install-config.aug
		echo  'rm  /files/boot/grub/menu.lst/title/kernel/quiet'				>> /tmp/root/install-config.aug
		echo  'set  /files/etc/resolv.conf/nameserver[last()] 4.2.2.3'			>> /tmp/root/install-config.aug
		echo  'set /files/etc/inittab/id/runlevels 3'							>> /tmp/root/install-config.aug
		
		echo  'save'															>> /tmp/root/install-config.aug
		
		augtool -f /tmp/root/install-config.aug
	fi

	if [ -d /home/<?php echo $sUserName?> ] ; then
		mkdir -p /home/<?php echo $sUserName?>/.ssh/
		chmod go-rwx /home/<?php echo $sUserName?>/.ssh/
		echo "INFO:  Downloading ssh key for user '<?php echo $sUserName?>' ..."
		wget -P /home/<?php echo $sUserName?>/.ssh/  <?php echo $sThisHostPath ?>/authorized_keys
		chown -R <?php echo $sUserName?>  /home/<?php echo $sUserName?>/.ssh/
	fi

%end

# -----------------------------------------------------------------------------------------------------
%packages

@base
@admin-tools
@base
@core
@online-docs
@system-tools
@books
@development-libs
@fedora-packager
@ruby
@system-tools
@text-internet

btrfs-progs
createrepo
fuse
gpm
lynx
lzop
ntpdate
vim*
-redhat-lsb
-PackageKit-yum-plugin
-iptstate
-irda-utils
-irqbalance
-krb5-workstation
-pam_krb5
-pam_passwdqc
-pam_pkcs11
-pcmciautils
-perf
-sendmail
-talk

%end

