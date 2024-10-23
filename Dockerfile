FROM dreg.cloud.sdu.dk/ucloud-apps/spark-cluster:3.5.2
USER 0

ARG POLYNOTE_VERSION="0.6.0"
ARG PYTHON_VERSION="3.7"
ARG OPENJDK_VERSION="8"
ARG SCALA_VERSION="2.12"
ARG DIST_TAR="polynote-dist.tar.gz"

WORKDIR /opt

RUN apt update -y && \
    apt install -y wget python3 python3-dev python3-pip build-essential

# Create a conda env 
RUN mamba create -n poly python="$PYTHON_VERSION" && \
    mamba install -n poly openjdk="$OPENJDK_VERSION" pip && \
    mamba clean -a

# Initialize the conda env
RUN mamba init bash && \
    echo "mamba activate poly" >> ~/.bashrc

# Install polynote
RUN wget -q https://github.com/polynote/polynote/releases/download/$POLYNOTE_VERSION/$DIST_TAR && \
    tar xfzp $DIST_TAR && \
    echo "DIST_TAR=$DIST_TAR" && \
    rm $DIST_TAR

# Copy start_app.sh and the configuration file
COPY --chown="$USERID":"$GROUPID" start_app.sh /usr/local/bin/start_app
COPY --chown="$USERID":"$GROUPID" config.yml /opt/polynote/config.yml
# Since examples dissapear in newer versions, copy them into the directory they would be (check this for future releases)
COPY --chown="$USERID":"$GROUPID" examples /opt/polynote/examples
RUN chmod +x /usr/local/bin/start_app

# Fixme: just trying if this works
RUN git init polynote \
    && git -C polynote remote add origin https://github.com/polynote/polynote.git \
    && git -C polynote config core.sparseCheckout true \
    && echo "docs-site/docs/docs/examples/" >> .git/info/sparse-checkout \
    && git -C polynote pull origin master \
    && mv polynote/docs-site/docs/docs/examples /work/examples \
    && rm -rf polynote

# Install pip requirements into the container
RUN mamba run -n poly pip install -r /opt/polynote/requirements.txt

WORKDIR /work

# expose the (internal) port that polynote runs on
EXPOSE 8192

# use the same scala version for server - take this from spark-shell --version output
ENV POLYNOTE_SCALA_VERSION=${SCALA_VERSION}

ENTRYPOINT /usr/local/bin/start_app
