#!/bin/bash

OSVer= head -n 1 /usr/lib/os-release
SUBCentOS="CentOS"
subUbuntu="Ubuntu"

function installCentOS (){
               #Install Nagios Cole
               dnf install -y gcc glibc glibc-common perl httpd php wget gd gd-devel
               dnf update -y
               #Download source
               cd /tmp
               wget -O nagioscore.tar.gz https://github.com/NagiosEnterprises/nagioscore/archive/nagios-4.4.5.tar.gz
               tar xzf nagioscore.tar.gz
               #compile
               cd /tmp/nagioscore-nagios-4.4.5/
               ./configure
               make all
               #create user and group
               make install-groups-users
               usermod -a -G nagios apache
               #install binaries
               make install
               #install service
               make install-daemoninit
               systemctl enable httpd.service
               #install command mode
               make install-commandmode
               #Install configuration files 
               make install-config
               #install apache config files
               make install-webconf
               #configure firewall
               firewall-cmd --zone=public --add-port=80/tcp
               firewall-cmd --zone=public --add-port=80/tcp --permanent
               #Create Nagios Admin User account
               htpasswd -c /usr/local/nagios/etc/htpasswd.users nagiosadmin
               #Start Apache Web Server
               systemctl start httpd.service
               #Start Service
               systemctl start nagios.service
               #Download Plugins
               yum install -y gcc glibc glibc-common make gettext automake autoconf wget openssl-devel net-snmp net-snmp-utils epel-release
               yum --enablerepo=PowerTools,epel install perl-Net-SNMP
               #Compile and Install
               cd /tmp/nagios-plugins-release-2.2.1/
               ./tools/setup
               ./configure
               make
               make install
               #Service (Start, Stop, Restart, Status)
               systemctl start nagios.service
               systemctl stop nagios.service
               systemctl restart nagios.service
               systemctl status nagios.service
               #check_ldap
               yum install -y openldap-devel
               #check radius
               cd /tmp
               wget -O freeradius-client.tar.gz https://github.com/FreeRADIUS/freeradius-client/archive/release_1_1_7.tar.gz
               tar xzf freeradius-client.tar.gz
               cd freeradius-client-release_1_1_7/
               ./configure
               make
               make install
               #check_dns
               yum install -y bind-utils
               #check_disk_smb
               yum install -y samba-client
               #check_fping
               yum install -y fping
               #check_by_ss
               yum install -y openssh-clients
               #check_sensors
               yum install -y lm_sensors
               #check_pgsql
               yum install -y postgresql-devel
               check_db
               yum install -y libdbi-devel
               check_mysql_query
               yum install -y mariadb-devel mariadb-libs 
           }
 function installubuntu (){
               #Security-Enhanced Linux
               sudo dpkg -l selinux*
               #Prerequisites
               sudo apt-get update
               sudo apt-get install -y autoconf gcc libc6 make wget unzip apache2 php libapache2-mod-php7.4 libgd-dev
               #Downloading the Source
               cd /tmp
               wget -O nagioscore.tar.gz https://github.com/NagiosEnterprises/nagioscore/archive/nagios-4.4.5.tar.gz
               tar xzf nagioscore.tar.gz
               #Compile
               cd /tmp/nagioscore-nagios-4.4.5/
               sudo ./configure --with-httpd-conf=/etc/apache2/sites-enabled
               sudo make all
               #Create User And Group
               sudo make install-groups-users
               sudo usermod -a -G nagios www-data
               #Install Binaries
               sudo make install
               #Install Service / Daemon
               sudo make install-daemoninit
               #Install Command Mode
               sudo make install-commandmode
               #Install Configuration Files
               sudo make install-config
               #Install Apache Config Files
               sudo make install-webconf
               sudo a2enmod rewrite
               sudo a2enmod cgi
               #Configure Firewall
               sudo ufw allow Apache
               sudo ufw reload
               #Create nagiosadmin User Account
               sudo htpasswd -c /usr/local/nagios/etc/htpasswd.users nagiosadmin
               Start Service / Daemon
               sudo systemctl start nagios.service
           }
if [[ "$STR" == *"$SUBCentOS"* ]]; then
  installCentOS
else
  if [[ "$STR" == *"$SUBUbuntu"* ]]; then
    installubuntu
  fi
fi
