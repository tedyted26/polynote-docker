FROM dreg.cloud.sdu.dk/ucloud-apps/spark-cluster:3.5.2
USER 0

# Polynote version 0.6.0 contains and installs version 0.5.2. This is a known issue. Check https://github.com/polynote/polynote/issues/1447
# We stick to a "fake" 0.6.0 because Polynote 0.5.2 is no longer available in the releases page
ARG POLYNOTE_VERSION="0.6.0"
# Not recommended to change Python and OpenJDK versions until Polynote's official documentation says it supports them.
ARG PYTHON_VERSION="3.7" 
ARG OPENJDK_VERSION="8"
ARG DIST_TAR="polynote-dist.tar.gz"

# Extract Scala version from Spark and set Polynote Scala version
RUN SCALA_VERSION=$(spark-shell --version 2>&1 | grep -o 'Scala version [^ ]*' | awk '{print $3}' | awk -F. '{print $1 "." $2}') \
  && export POLYNOTE_SCALA_VERSION=${SCALA_VERSION} \
  && echo "export POLYNOTE_SCALA_VERSION=${SCALA_VERSION}" >> ~/.bashrc

WORKDIR /opt

RUN apt update -y && \
    apt install -y wget python3 python3-dev python3-pip build-essential

# Create a conda env and install Python, Openjdk
RUN mamba create -n poly python="$PYTHON_VERSION" && \
    mamba install -n poly openjdk="$OPENJDK_VERSION" pip && \
    mamba clean -a

# Initialize the conda env
RUN conda init bash && \
    echo "conda activate poly" >> ~/.bashrc

# Install polynote
RUN wget -q https://github.com/polynote/polynote/releases/download/$POLYNOTE_VERSION/$DIST_TAR && \
    tar xfzp $DIST_TAR && \
    echo "DIST_TAR=$DIST_TAR" && \
    rm $DIST_TAR

# Copy start_app.sh and the configuration file
COPY --chown="$USERID":"$GROUPID" start_app.sh /usr/local/bin/start_app
COPY --chown="$USERID":"$GROUPID" config.yml /opt/polynote/config.yml
RUN chmod +x /usr/local/bin/start_app

# Install pip requirements into the container
RUN mamba run -n poly pip install -r /opt/polynote/requirements.txt

WORKDIR /tmp

# Pull examples from official repository
RUN git init polynote \
    && git -C polynote remote add origin https://github.com/polynote/polynote.git \
    && git -C polynote config core.sparseCheckout true \
    && echo "docs-site/docs/docs/examples/" >> polynote/.git/info/sparse-checkout \
    && git -C polynote pull origin master \
    && mv polynote/docs-site/docs/docs/examples /opt/polynote/examples \
    && rm -rf polynote

WORKDIR /work

# expose the (internal) port that polynote runs on
EXPOSE 8192

ENTRYPOINT /usr/local/bin/start_app
