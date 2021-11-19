ARG MONGO_VERSION=4.4.8
FROM  mongo:$MONGO_VERSION
LABEL org.opencontainers.image.authors="thanhlcm90@gmail.com"

# mongod config
ENV MONGO_JOURNALING true
ENV MONGO_REP_SET rs0

COPY scripts $MONGO_SCRIPTS_DIR

EXPOSE 27017

WORKDIR $MONGO_SCRIPTS_DIR

CMD ["./run.sh"]
