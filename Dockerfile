FROM dreg.cloud.sdu.dk/ucloud-apps/spark-cluster:3.5.2

USER 0

ARG POLYNOTE_VERSION
ARG SCALA_VERSION="2.11"
ARG DIST_TAR="polynote-dist.tar.gz"

WORKDIR /opt

## RUN apt update -y && \
##    apt install -y wget python3 python3-dev python3-pip build-essential

RUN wget -q https://github.com/polynote/polynote/releases/download/$POLYNOTE_VERSION/$DIST_TAR && \
    tar xfzp $DIST_TAR && \
    echo "DIST_TAR=$DIST_TAR" && \
    rm $DIST_TAR

COPY —chown="$USERID":"$GROUPID" start_app.sh /usr/local/bin/start_app

USER $USERID

RUN pip3 install -r ./polynote/requirements.txt




WORKDIR /work

RUN chmod +x /usr/local/bin/start_app

ENTRYPOINT /usr/local/bin/start_app