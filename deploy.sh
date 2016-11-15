#!/usr/bin/env bash

# determine this files directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR=$DIR/../app
DEPLOYER_DIR=$PROJECT_DIR/.deployer

if [ $# -lt 1 ]
then
    echo "Usage : init-local, credential, set-remote-addr, init-remote, init-local, deploy, versions, current"
    exit
fi

case "$1" in

credential)  echo "create credential"
    mkdir -p $DEPLOYER_DIR
    ssh-keygen -t rsa -N "" -f $DEPLOYER_DIR/id_rsa
    openssl rsa -in $DEPLOYER_DIR/id_rsa -outform pem > $DEPLOYER_DIR/id_rsa.pem
    chmod 400 $DEPLOYER_DIR/id_rsa.pem
    ;;

init-local)  echo "initialize local application"
    mkdir -p $DEPLOYER_DIR
    touch $DEPLOYER_DIR/remote_addr.txt
    touch $DEPLOYER_DIR/versions.txt
    touch $DEPLOYER_DIR/current.txt
    ;;

set-remote-addr)  echo "set the IP address of remote server"
    echo $2 > $DEPLOYER_DIR/remote_addr.txt
    echo "REMOTE_ADDR: $2"
    ;;

test) echo "test"
    if [ ! -f $DEPLOYER_DIR/remote_addr.txt ]
    then
        echo "remote address is not set"
        exit 1
    fi
    REMOTE_ADDR=$(<$DEPLOYER_DIR/remote_addr.txt)
    if [ -z $REMOTE_ADDR ]
    then
        echo "remote address is not set"
        exit 1
    fi
    ssh -o StrictHostKeyChecking=no root@$REMOTE_ADDR -i $DEPLOYER_DIR/id_rsa.pem << EOF
EOF
    ;;

init-remote)  echo  "initialize remote server"
    if [ ! -f $DEPLOYER_DIR/remote_addr.txt ]
    then
        echo "remote address is not set"
        exit 1
    fi
    REMOTE_ADDR=$(<$DEPLOYER_DIR/remote_addr.txt)
    if [ -z $REMOTE_ADDR ]
    then
        echo "remote address is not set"
        exit 1
    fi
    ssh -tt -o StrictHostKeyChecking=no root@$REMOTE_ADDR -i $DEPLOYER_DIR/id_rsa.pem << EOF
apt-get update
apt-get install -y apt-transport-https ca-certificates
apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
echo "deb https://apt.dockerproject.org/repo ubuntu-xenial main" | tee /etc/apt/sources.list.d/docker.list
apt-get update
apt-cache policy docker-engine
apt-get install -y linux-image-extra-$(uname -r) linux-image-extra-virtual
apt-get install -y docker-engine
service docker start
systemctl enable docker
exit
EOF
    ;;

deploy)  echo  "deploy a new version"
    if [ ! -f $DEPLOYER_DIR/remote_addr.txt ]
    then
        echo "remote address is not set"
        exit 1
    fi
    REMOTE_ADDR=$(<$DEPLOYER_DIR/remote_addr.txt)
    if [ -z $REMOTE_ADDR ]
    then
        echo "remote address is not set"
        exit 1
    fi

    ssh -tt -o StrictHostKeyChecking=no root@$REMOTE_ADDR -i $DEPLOYER_DIR/id_rsa.pem << EOF
mkdir -p /app
exit
EOF
    ;;
9) echo  "Sending SIGKILL signal"
   ;;
*) echo "Unknown command: $1"
   ;;
esac
