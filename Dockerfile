FROM dreg.cloud.sdu.dk/ucloud-apps/spark-cluster:3.2.2
# Changed spark version from 3.5.2 to 3.2.2
USER 0

ARG POLYNOTE_VERSION
ARG SCALA_VERSION="2.11"
ARG DIST_TAR="polynote-dist.tar.gz"

WORKDIR /opt

RUN wget -q https://github.com/polynote/polynote/releases/download/$POLYNOTE_VERSION/$DIST_TAR && \
    tar xfzp $DIST_TAR && \
    echo "DIST_TAR=$DIST_TAR" && \
    rm $DIST_TAR

COPY --chown="$USERID":"$GROUPID" start_app.sh /usr/local/bin/start_app
COPY --chown="$USERID":"$GROUPID" config.yml /opt/polynote/config.yml
RUN chmod +x /usr/local/bin/start_app

USER $USERID

RUN pip3 install -r ./polynote/requirements.txt

USER 0

WORKDIR /work

# expose the (internal) port that polynote runs on
EXPOSE 8192

# use the same scala version for server
ENV POLYNOTE_SCALA_VERSION=${SCALA_VERSION}

ENTRYPOINT /usr/local/bin/start_app
