#!/usr/bin/env bash

# determine this files directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR=$DIR/../app
DEPLOYER_DIR=$PROJECT_DIR/.deployer
WORK_DIR=$DEPLOYER_DIR/workspace

if [ $# -lt 1 ]
then
    echo "Usage : init-local, id-make, id-public, htpasswd, set-remote-addr, init-remote, init-local, deploy, versions, current"
    exit
fi

case "$1" in

id-make)  echo "create credential"
    mkdir -p $DEPLOYER_DIR
    ssh-keygen -t rsa -N "" -f $DEPLOYER_DIR/id_rsa
    openssl rsa -in $DEPLOYER_DIR/id_rsa -outform pem > $DEPLOYER_DIR/id_rsa.pem
    chmod 400 $DEPLOYER_DIR/id_rsa.pem
    ;;

id-public)
    cat $DEPLOYER_DIR/id_rsa.pub
    ;;

htpasswd) echo "create htpasswd for nginx"
    echo -n 'admin:' > $PROJECT_DIR/.htpasswd
    openssl passwd -apr1 -stdin <<< "$2" >> $PROJECT_DIR/.htpasswd
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
    ssh -o StrictHostKeyChecking=no root@$REMOTE_ADDR -i $DEPLOYER_DIR/id_rsa.pem << EOF
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
EOF
    ;;

deploy)  echo  "deploy a new version"

    # initialize working dir
    mkdir -p $WORK_DIR
    rm -rf $WORK_DIR
    mkdir -p $WORK_DIR

    # create a working bundle
    WORK_ARCHIVE=$WORK_DIR/app.tar
    if tar --exclude .git --exclude .deployer --exclude node_modules -cf $WORK_ARCHIVE $PROJECT_DIR ; then
        echo -e "\nCREATE WORKING ARCHIVE: OK"
    else
        echo -e "\nCREATE WORKING ARCHIVE: FAILED"
        exit 1
    fi

    # extract a working bundle
    if tar -xf $WORK_ARCHIVE -C $WORK_DIR; then
        echo -e "\nEXTRACT WORKING ARCHIVE: OK"
    else
        echo -e "\nEXTRACT WORKING ARCHIVE: FAILED"
        exit 1
    fi
    rm $WORK_DIR/app.tar

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
    echo -e "NEW VERSION: $VERSION"

    # build the node server
    if $WORK_DIR/app/frontend/builder/run.sh webpack.prod.server.js ; then
        echo -e "\nBUILD JAVASCTIPT SERVER: OK"
    else
        echo -e "\nBUILD JAVASCTIPT SERVER: FAILED"
        exit 1
    fi

    # build the javascript client
    if $WORK_DIR/app/frontend/builder/run.sh webpack.prod.client.js ; then
        echo -e "\nBUILD JAVASCTIPT CLIENT: OK"
    else
        echo -e "\nBUILD JAVASCTIPT CLIENT: FAILED"
        exit 1
    fi

    # compose the php project
    if $WORK_DIR/app/backend/composer/run.sh ; then
        echo -e "\nBUILD PHP BACKEND COMPOSE: OK"
    else
        echo -e "\nBUILD PHP COMPOSE: FAILED"
        exit 1
    fi

    # build the php project
    if $WORK_DIR/app/backend/builder/run.sh build production ; then
        echo -e "\nBUILD PHP BACKEND: OK"
    else
        echo -e "\nBUILD PHP BACKEND: FAILED"
        exit 1
    fi

    # create a new bundle
    ARCHIVE=$DEPLOYER_DIR/app-v$VERSION.tar.gz
    if tar --exclude node_modules -czf $ARCHIVE $WORK_DIR ; then
        echo -e "\nCREATE DEPLOYMENT ARCHIVE: OK"
    else
        echo -e "\nCREATE DEPLOYMENT ARCHIVE: FAILED"
        exit 1
    fi

    # make new remote directory for version
    ssh -o StrictHostKeyChecking=no root@$REMOTE_ADDR -i $DEPLOYER_DIR/id_rsa.pem << EOF
mkdir -p /app/persistent
mkdir -p /app/persistent/log
mkdir -p /app/persistent/web
mkdir -p /app
mkdir -p /app/version
mkdir -p /app/version/$VERSION
EOF
    echo -e "\nCREATE REMOTE DIRECTORY: OK"

    # copy new application version
    scp -o StrictHostKeyChecking=no -i $DEPLOYER_DIR/id_rsa.pem $ARCHIVE root@$REMOTE_ADDR:/app/version/$VERSION/app.tar.gz
    echo -e "\nCOPY DEPLOYMENT ARCHIVE: OK"

    # extract new application version
    ssh -o StrictHostKeyChecking=no root@$REMOTE_ADDR -i $DEPLOYER_DIR/id_rsa.pem << EOF
cd /app/version/$VERSION && tar xzf ./app.tar.gz --strip-components=3
EOF
    echo -e "\nREMOTE ARCHIVE EXTRATED: OK"

    # stop the current version
    ssh -o StrictHostKeyChecking=no root@$REMOTE_ADDR -i $DEPLOYER_DIR/id_rsa.pem << EOF
cd /app/version/$VERSION/app && ./stop.sh
EOF
    echo -e "\nSTOP PREVIOUS VERSION: OK"

    # start the new version in production mode
    ssh -o StrictHostKeyChecking=no root@$REMOTE_ADDR -i $DEPLOYER_DIR/id_rsa.pem << EOF
cd /app/version/$VERSION/app && ./run.sh production
EOF
    echo -e "\nSTART NEW VERSION: OK"

    # update the current.txt file
    echo $VERSION > $DEPLOYER_DIR/current.txt

    ;;


*) echo "Unknown command: $1"
   ;;
esac
