FROM centos:7

ARG TF_REPO=https://github.com/tensorflow/tensorflow.git

ARG TF_SRC=/tensorflow_src

# For TF versions olders than v1.15.0 the behaviour is unknown
ARG TF_BRANCH=v1.15.0

# For now only version 7 is supported
ARG DEV_TOOLSET_VER=7

# Only 2.7 or 3.6 versions are supported
ARG PY_VER=2.7
ARG TARGET_PLATFORM=sandybridge

# Build with v1 or v2 config
ARG CONFIG_VER=v1
ARG TF_WHLS_DIR=/tensorflow_whls

RUN yum clean all && \
    yum update -y && \
    yum install -y \
        git

RUN git clone --single-branch --branch $TF_BRANCH https://github.com/tensorflow/tensorflow.git $TF_SRC

WORKDIR $TF_SRC/tensorflow/tools/ci_build/install

RUN ./install_yum_packages.sh

RUN yum clean all && \
    yum update -y && \
    yum install -y \
        clang \
        python2 \
        python2-devel \
        python2-pip \
        python3 \
        python3-devel \
        python3-pip \
        python$PY_VER \
        python$PY_VER-devel \
        python$PY_VER-pip \
        zip

RUN ./install_centos_pip_packages.sh
RUN ./install_proto3.sh
RUN ./install_bazel.sh

WORKDIR $TF_SRC/tensorflow/tools/ci_build

COPY build_tf_whl.sh .

RUN pip2 install future

RUN ./build_tf_whl.sh

WORKDIR /
