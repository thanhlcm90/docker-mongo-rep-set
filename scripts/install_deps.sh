#!/bin/bash

set -e

printf "\n[-] Installing base OS dependencies...\n\n"

# base
apt-get update
apt-get install -y --no-install-recommends ca-certificates openssl numactl wget


# Gosu
# https://github.com/tianon/gosu
dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"
wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"
wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc"
export GNUPGHOME="$(mktemp -d)"
for server in $(shuf -e ha.pool.sks-keyservers.net \
                        hkp://p80.pool.sks-keyservers.net:80 \
                        keyserver.ubuntu.com \
                        hkp://keyserver.ubuntu.com:80 \
                        pgp.mit.edu) ; do \
    gpg --keyserver "$server" --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 && break || : ; \
done && \
gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu
rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc
chmod +x /usr/local/bin/gosu
gosu nobody true


# generate a key file for the replica set
# https://docs.mongodb.com/v3.4/tutorial/enforce-keyfile-access-control-in-existing-replica-set
printf "\n[-] Generating a replica set keyfile...\n\n"
openssl rand -base64 741 > $MONGO_KEYFILE
chown mongodb:mongodb $MONGO_KEYFILE
chmod 400 $MONGO_KEYFILE


# install Mongo
printf "\n[-] Installing MongoDB ${MONGO_VERSION}...\n\n"

apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4

echo "deb http://repo.mongodb.org/apt/debian jessie/mongodb-org/$MONGO_MAJOR main" > "/etc/apt/sources.list.d/mongodb-org-$MONGO_MAJOR.list"

apt-get update

apt-get install -y \
  ${MONGO_PACKAGE}=$MONGO_VERSION \
  ${MONGO_PACKAGE}-server=$MONGO_VERSION \
  ${MONGO_PACKAGE}-shell=$MONGO_VERSION \
  ${MONGO_PACKAGE}-mongos=$MONGO_VERSION \
  ${MONGO_PACKAGE}-tools=$MONGO_VERSION


# cleanup
printf "\n[-] Cleaning up...\n\n"

rm -rf /var/lib/apt/lists/*
rm -rf /var/lib/mongodb
mv /etc/mongod.conf /etc/mongod.conf.orig

apt-get purge -y --auto-remove openssl wget
