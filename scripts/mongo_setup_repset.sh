#!/bin/bash

echo "************************************************************"
echo "Setting up replica set"
echo "************************************************************"

mongo admin --eval "help" > /dev/null 2>&1
RET=$?

while [[ RET -ne 0 ]]; do
  echo "Waiting for MongoDB to start..."
  mongo admin --eval "help" > /dev/null 2>&1
  RET=$?
  sleep 1

  if [[ -f /data/db/mongod.lock ]]; then
    echo "Removing Mongo lock file"
    rm /data/db/mongod.lock
  fi
done

# Login as root and configure replica set
mongo admin --eval "rs.initiate();"
if [ -n "$MONGO_SECONDARY" ]
then
  echo "Add the MONGO_SECONDARY to repset"
  mongo admin --eval "rs.add('$MONGO_SECONDARY');"
fi
if [ -n "$MONGO_ARBITER" ]
then
  echo "Add the MONGO_ARBITER to repset"
  mongo admin --eval "rs.addArb('$MONGO_ARBITER');"
fi
