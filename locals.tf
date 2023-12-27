locals {
  cloud_init = <<EOT
#cloud-config
package_update: true
package_upgrade: true
packages:
  - vim
  - ca-certificates
  - curl
  - gnupg
write_files:
  - path: /tmp/deploy.sh
    content: |
        #!/bin/bash
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

runcmd:
  - chmod a+x /tmp/deploy.sh
  - /tmp/deploy.sh
  EOT
}