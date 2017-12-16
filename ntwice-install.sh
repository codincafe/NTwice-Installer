#!/bin/bash
# NTwice
# http://codincafe.com

#
# Currently Supported Operating Systems:
#
#   Ubuntu 16.04
#

# Am I root?
if [ "x$(id -u)" != 'x0' ]; then
    echo 'Error: this script can only be executed by root'
    exit 1
fi

# Make dir's
mkdir /root/.ntwice

# Update apt-get
apt-get update

# Upgrade apt-get
apt-get upgrade -y