#!/bin/bash
# NTwice 0.1
# http://codincafe.com

#
# Currently Supported Operating Systems:
#
#   Ubuntu 16.04
#

# Create software folder
echo '======================================================='
echo 'Creating NTwice Folder'
echo '======================================================='
mkdir $HOME/.ntwice

# Check wget
echo '======================================================='
echo 'Installing Node.js via NVM (https://github.com/creationix/nvm)'
echo '======================================================='
if [ -e '/usr/bin/wget' ]; then
    wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

nvm install stable
nvm ls
nvm use stable

node -v

echo '======================================================='
echo 'Installing pm2'
echo '======================================================='
npm i -g pm2

echo '======================================================='
echo 'Starting Panel Server'
echo '======================================================='
cp /ntwice/server.js $HOME/.ntwice

pm2 start $HOME/.ntwice/server.js --name=server

echo '======================================================='
echo 'CURL Says'
echo '======================================================='
curl -I http://127.0.0.1:8083 2>/dev/null | head -n 1