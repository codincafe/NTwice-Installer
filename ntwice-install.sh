#!/bin/bash
# NTwice
# http://codincafe.com

#
# Currently Supported Operating Systems:
#
#   RHEL 5, RHEL 6
#   CentOS 5, CentOS 6
#   Debian 7
#   Ubuntu LTS, Ubuntu 13.04, Ubuntu 13.10
#

# Am I root?
if [ "x$(id -u)" != 'x0' ]; then
    echo 'Error: this script can only be executed by root'
    exit 1
fi

