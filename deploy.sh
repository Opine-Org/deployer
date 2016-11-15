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
    # make sure remote address is set
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

    # create the versions file (if it doesn't exist)
    touch $DEPLOYER_DIR/versions.txt

    # read last version in the file
    VERSION=$(tail -1 $DEPLOYER_DIR/versions.txt)

    # check if there is not version yet
    if [ -z $VERSION ]
    then
        VERSION=1
    else
        VERSION=$(($VERSION + 1))
    fi
    echo $VERSION >> $DEPLOYER_DIR/versions.txt

    # build the backend server

    # build the frontend

    # build opine

    # create a new bundle
    ARCHIVE=$DEPLOYER_DIR/app-v$VERSION.tar.gz
    tar --exclude .git --exclude .deployer --exclude node_modules -zcvf $ARCHIVE $PROJECT_DIR

    # make new remote directory for version
    # copy new application version
    # extract new application version
    # make new docker container
    # stop the current version
    # start the new version
    # update the current.txt file

    echo $ARCHIVE

    exit 0

    # connect to remote server to ensure that the app directory exists
    ssh -tt -o StrictHostKeyChecking=no root@$REMOTE_ADDR -i $DEPLOYER_DIR/id_rsa.pem << EOF
mkdir -p /app
exit
EOF
    ;;


*) echo "Unknown command: $1"
   ;;
esac
