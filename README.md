# TensorFlow With MKL on CentOS 7
Build TensorFlow+MKL v1.15.x and newer wheels on CentOS 7

# Background
TBD

To build `Python2.7`, `Python3.6` for `v1` and `v2` configs run the following:
```bash
for py in 2.7 3.6; do
  for config in v1 v2; do
    docker build --build-arg TF_BRANCH=v1.15.2 --build-arg PY_VER=$py --build-arg CONFIG_VER=$config -f Dockerfile . -t centos-tf-$py-$config
  done
done
```
