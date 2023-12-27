#!/bin/bash

while getopts p: flag
do
    case "${flag}" in
        p) superset_password=${OPTARG};;
    esac
done
echo "Superset password: $superset_password";


ARCHITECTURE=`dpkg --print-architecture`
REPO_URL="http://repo.3cx.com"

apt-get update && apt-get install -y gnupg2 debian-keyring debian-archive-keyring

curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg| gpg --yes -o /usr/share/keyrings/google-archive-keyring.gpg --dearmor
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo tee /usr/share/keyrings/cloud.google.asc

wget -qO /etc/apt/trusted.gpg.d/bullseye-ls.asc https://ftp-master.debian.org/keys/release-11.asc
wget -qO /etc/apt/trusted.gpg.d/bullseye-archive-ls.asc https://ftp-master.debian.org/keys/archive-key-11.asc
wget -qO /etc/apt/trusted.gpg.d/bullseye-security-ls.asc https://ftp-master.debian.org/keys/archive-key-11-security.asc

wget -O- $REPO_URL/key.pub | gpg --dearmor | sudo tee /usr/share/keyrings/3cx-archive-keyring.gpg > /dev/null

rm -rf /etc/apt/sources.list.d/*
# Switch to Debian 12 sources
/bin/echo "deb http://deb.debian.org/debian bookworm main"  	> /etc/apt/sources.list
/bin/echo "deb http://deb.debian.org/debian-security/ bookworm-security main"  	>> /etc/apt/sources.list
/bin/echo "deb http://deb.debian.org/debian bookworm-updates main"  	>> /etc/apt/sources.list

# Include 3CX Debian 12 sources
/bin/echo "deb [arch=$ARCHITECTURE by-hash=yes signed-by=/usr/share/keyrings/3cx-archive-keyring.gpg] $REPO_URL/debian/2000 bookworm main"  	>> /etc/apt/sources.list
/bin/echo "deb [arch=$ARCHITECTURE by-hash=yes signed-by=/usr/share/keyrings/3cx-archive-keyring.gpg] $REPO_URL/debian-security/2000 bookworm-security main" >> /etc/apt/sources.list
/bin/echo "deb [arch=$ARCHITECTURE by-hash=yes signed-by=/usr/share/keyrings/3cx-archive-keyring.gpg] $REPO_URL/3cx bookworm main"  			> /etc/apt/sources.list.d/3cxpbx.list

apt update
apt -y install nfs-kernel-server
apt -y install nfs-common

apt install -y net-tools dphys-swapfile
echo "1" | DEBIAN_FRONTEND=noninteractive apt -q -y --allow-unauthenticated --allow-downgrades --allow-remove-essential install 3cxpbx
#/usr/lib/3cxpbx/PbxWebConfigTool -p /usr/share/3cxpbx/webconfig -nobrowser -port 5015


## Install superset
#curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
#echo   "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
#apt update
#apt-get -y install docker-ce docker-ce-cli containerd.io
#curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /bin/docker-compose
#chmod +x /bin/docker-compose
#mkdir /opt/superset
#mkdir /opt/superset/conf
#chmod a+rwx /opt/superset/conf
#
##create user superset with encrypted password 'JHyuIJIYUtftyg887';
##grant all privileges on database database_single to superset;
##GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO superset;
#
#cd /opt/superset && wget -c https://raw.githubusercontent.com/svetek/terraform-3CX-Azure/main/module/scripts/superset_docker-compose.yml  >> /tmp/install_log
#mv /opt/superset/superset_docker-compose.yml /opt/superset/docker-compose.yml  >> /tmp/install_log
#docker-compose up -d  >> /tmp/install_log &> /dev/null
#sleep 30s
#docker exec -i superset_app superset fab create-admin --username admin --firstname Superset --lastname Admin --email admin@superset.com --password $superset_password >> /tmp/install_log
#docker exec -i superset_app superset db upgrade  >> /tmp/install_log
#docker exec -i superset_app superset init  >> /tmp/install_log