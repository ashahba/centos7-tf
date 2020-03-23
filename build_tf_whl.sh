#!/bin/bash

set -e

# This script will build the whls inside a CentOS 7 container
# If you expect the wheel to be saved localy use docker volumes

# Check our environment
TF_SRC=${TF_SRC:-"/tensorflow_src"}
DEV_TOOLSET_VER="${DEV_TOOLSET_VER:-7}"
PY_VER=${PY_VER:-"2.7"}
SET_BUILD_ENV_SCRIPT="${TF_SRC}/tensorflow/tools/ci_build/linux/mkl/set-build-env.py"
TARGET_PLATFORM=${TARGET_PLATFORM:-"sandybridge"}
TF_WHLS_DIR=${TF_WHLS_DIR:-"/tensorflow_whls"}
CONFIG_VER=${CONFIG_VER:-"v1"}

if [[ "${CONFIG_VER}" == "v1" ]]; then
  CONFIG_VER="--disable-v2"
  echo "Disabling v2; building TensorFlow 1.x"
else
  CONFIG_VER=""
fi

# Switch to the specified Dev-Toolset environment to pick up a modern version of gcc
DEV_TOOLSET_BIN="/opt/rh/devtoolset-${DEV_TOOLSET_VER}/root/usr/bin"
export PATH=${DEV_TOOLSET_BIN}:$PATH

# Use given Python version to configure
cd ${TF_SRC}
yes "" | python${PY_VER} configure.py

# Use the set-build-env.py to set the bazel build command
python${PY_VER} ${SET_BUILD_ENV_SCRIPT} -p ${TARGET_PLATFORM} -f /root/.mkl.bazelrc \
  ${CONFIG_VER} --secure-build

cat << EOF > /root/.bazelrc
import /root/.mkl.bazelrc
EOF

echo "-----------> bazel build options <---------------------"
cat /root/.mkl.bazelrc
echo "\n"
echo "--------------------------------------------------------"

# Build TF
bazel --bazelrc=/root/.bazelrc build -c opt \
  //tensorflow/tools/pip_package:build_pip_package

# Building whl at ${TF_WHLS_DIR}
bazel-bin/tensorflow/tools/pip_package/build_pip_package "${TF_WHLS_DIR}"
