# Dockerized MongoDB Replica Set

This MongoDB Docker container is intended to be used to set up a 3 node replica set.

Mongo version:  **4.4.8**

## About

A MongoDB [replica set](https://docs.mongodb.org/v3.4/replication/) consists of at least 3 Mongo instances. In this case, they will be a primary, secondary, and an arbiter. To use this project as a replica set, you simply launch three instances of this container across three separate host servers and the primary will configure your users and replica set.  Also note that each server must be able to access the others (discovery must work in both directions).

## Launch

Now you're ready to start launching containers.  You need to launch the secondary and arbiter first so they're ready for the primary to configure them when it starts.

#### Secondary

```sh
docker run -d \
  -p 28018:28018 \
  -e MONGO_PORT="28018"
  thanhlcm90/mongo-rep-set:latest
```

#### Arbiter

The only difference here is you can turn off journaling. From the [official docs](https://docs.mongodb.org/v3.4/tutorial/add-replica-set-arbiter/#considerations):
> An arbiter does not store data, but until the arbiter’s mongod process is added to the replica set, the arbiter will act like any other mongod process and start up with a set of data files and with a full-sized journal. To minimize the default creation of data, you can disable journaling.

```sh
docker run -d \
  -p 28019:28019 \
  -e JOURNLING=false \
  -e MONGO_PORT="28019"
  thanhlcm90/mongo-rep-set:latest
```

#### Primary

The primary is responsible for setting up users and configuring the replica set, so this is where all of the configuration happens. Once your secondary and arbiter are up and running, launch your primary with:

```sh
docker run -d \
  -p 28017:28017 \
  -e MONGO_ROLE="primary" \
  -e MONGO_PORT="28017"
  -e MONGO_SECONDARY="hostname or IP of secondary" \
  -e MONGO_ARBITER="hostname or IP of arbiter" \
  thanhlcm90/mongo-rep-set:latest
```

The primary will start up, configure your root and app users, shut down, and then start up once more and configure the replica set.  Assuming the secondary and arbiter are reachable, the server will now be ready for authenticated connections.  You can use the standard two server Mongo URL to connect to the primary/secondary like this:

#### Connect

Note that the following connection url is using default env var values (more info on those below), so it should work if you haven't overwritten any of the variables yourself.

```sh
mongodb://mongo-rs0-1:28017,mongo-rs0-2:28018,mongo-rs0-3:28019/myAppDatabase?replicaSet=rs0
```

## Environment Variables

Here are all of the available environment variables and their defaults.  Note that if you set `MONGO_REP_SET`, you must set it to the same value on all 3 containers.

```sh
# mongod config
MONGO_JOURNALING true
MONGO_REP_SET rs0
MONGO_PORT 27017
MONGO_SECONDARY mongo2:27017
MONGO_ARBITER mongo3:27017