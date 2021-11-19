#!/bin/bash
set -m

mongodb_cmd="mongod"
cmd="$mongodb_cmd --bind_ip_all --replSet $MONGO_REP_SET --port $MONGO_PORT"

if [ "$MONGO_JOURNALING" == false ]; then
  cmd="$cmd --nojournal"
fi

$cmd &

if [ "$MONGO_ROLE" == "primary" ]; then
  $MONGO_SCRIPTS_DIR/mongo_setup_repset.sh
fi

fg
