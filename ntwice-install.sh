#!/bin/bash
# NTwice 0.1
# http://codincafe.com

#
# Currently Supported Operating Systems:
#
#   Ubuntu 16.04
#

# Variables and functions
export PATH=$PATH:/sbin
export DEBIAN_FRONTEND=noninteractive

user="admin"
HOMEDIR="/home"

# Get main IP
ip=$(ip addr|grep 'inet '|grep global|head -n1|awk '{print $2}'|cut -f1 -d/)

#Define software list
software="mysql-client mysql-common mysql-server nginx fail2ban vim zip curl wget"

# Defining password-gen function
gen_pass() {
    MATRIX='0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
    LENGTH=10
    while [ ${n:=1} -le $LENGTH ]; do
        PASS="$PASS${MATRIX:$(($RANDOM%${#MATRIX})):1}"
        let n+=1
    done
    echo "$PASS"
}

# Generate root password
rootpass=$(gen_pass)

# Defining return code check function
check_result() {
    if [ $1 -ne 0 ]; then
        echo "Error: $2"
        exit $1
    fi
}

# Am I root?
if [ "x$(id -u)" != 'x0' ]; then
    echo 'Error: this script can only be executed by root'
    exit 1
fi

# Checking admin user account
if [ ! -z "$(grep ^admin: /etc/passwd /etc/group)" ]; then
    echo 'Please remove admin user account before proceeding.'
    check_result 1 "User admin exists"
fi

# Detect OS
if [ "$(head -n1 /etc/issue | cut -f 1 -d ' ')" != 'Ubuntu' ]; then
	echo 'OS not supported';
	exit 1
fi

# Printing start message and sleeping for 5 seconds
echo -e "\n\n\n\nInstallation will take about 15 minutes ...\n"
sleep 5

echo '======================================================='
echo 'Checking Swap'
echo '======================================================='
# Checking swap on small instances
if [ -z "$(swapon -s)" ] && [ $memory -lt 1000000 ]; then
    fallocate -l 1G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo "/swapfile   none    swap    sw    0   0" >> /etc/fstab
    echo 'Swap set'
    free -h
fi

# Upgrade apt-get
echo '======================================================='
echo 'Upgrading Packages'
echo '======================================================='
apt-get -y upgrade
check_result $? 'apt-get upgrade failed'

# Update apt-get
echo '======================================================='
echo 'Checking for updates'
echo '======================================================='
apt-get update
check_result $? 'apt-get update failed'

# Disabling daemon autostart on apt-get install
#echo -e '#!/bin/sh\nexit 101' > /usr/sbin/policy-rc.d
#chmod a+x /usr/sbin/policy-rc.d

# Installing apt packages
echo '======================================================='
echo 'Installing required packages'
echo '======================================================='
apt-get -y install $software
check_result $? "apt-get install failed"

# Restoring autostart policy
#rm -f /usr/sbin/policy-rc.d

# Securing installation
echo '======================================================='
echo 'Starting MySQL'
echo '======================================================='
service mysql start
echo '======================================================='
echo 'Securing MySQL'
echo '======================================================='
mpass=$(gen_pass)
mysqladmin -u root password $mpass
echo -e "[client]\npassword='$mpass'\n" > /root/.my.cnf
chmod 600 /root/.my.cnf
mysql -e "DELETE FROM mysql.user WHERE User=''"
mysql -e "DROP DATABASE test" >/dev/null 2>&1
mysql -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%'"
mysql -e "FLUSH PRIVILEGES"

# Setting User
echo '======================================================='
echo 'Setting up user'
echo '======================================================='

# Adding user
/usr/sbin/useradd "$user" -c asd@example.com -m -d "$HOMEDIR/admin"
check_result $? "user creation failed" $E_INVALID

# Adding password
echo "$user:$rootpass" | /usr/sbin/chpasswd

# Building directory tree
mkdir $HOMEDIR/$user/conf
mkdir $HOMEDIR/$user/conf/web $HOMEDIR/$user/web $HOMEDIR/$user/tmp
chmod 751 $HOMEDIR/$user/conf/web 
chmod 700 $HOMEDIR/$user/tmp
chown $user:$user $HOMEDIR/$user/web $HOMEDIR/$user/tmp

# Set permissions
chmod a+x $HOMEDIR/$user

# Switch user to prepare admin level config
echo '======================================================='
echo 'Switching User to admin'
echo '======================================================='
su - admin /"$(pwd)"/nvm-install.sh

# Output info
echo '======================================================='
echo 'CONGRATS'
echo '======================================================='
echo -e "Congratulations, you have just successfully installed \
NTwice

    https://$ip:8083
    username: admin
    password: $rootpass

We hope that you enjoy your installation of NTwice. Please \
feel free to contact us anytime if you have any questions.
Thank you.

--
Sincerely yours
NTwice team
"

# EOF