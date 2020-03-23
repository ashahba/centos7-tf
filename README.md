# TensorFlow With MKL on CentOS 7
Build TensorFlow+MKL v1.15.x and newer wheels on CentOS 7

### Background
`TensorFlow v1.14.x` was the last versoin that could successfully built on `gcc 4.8.5`.
This is because some components like `mlir` require `c++14` support which is only available on `gcc 4.9.2` or better.
However `CentOS 7` was shipped with `gcc 4.8.5` and to obtain upgraded `gcc` versions the cleanest way is using `Developer Toolset` collection.
`TensorFlow` community already has scripts that help with putting everything toghether and the files provided here, just combine those scripts
in once place while adding proper flags to allow building `TensorFlow v1.15` or better with `MKL` support for both `Python2.7` and `Python3.6`.

Althought support for `Python2.7` has been dropped due to this version of `Python` being EOL'ed and `CentOS 7` support has always been unclear,
but many people still have lots of legacy `Python2.7` scripts that run on `CentOS 7`, so that's why this repo is put together.

### Building TensorFlow wheels 
To build `TensorFlow v1.15.2` for `Python3.6` that supports `v2` confing, run this command:
```bash
docker build --build-arg TF_BRANCH=v1.15.2 --build-arg PY_VER=3.6 --build-arg CONFIG_VER=v2 -f Dockerfile . -t centos-tf-3.6-v2
```
Once the docker build is done, the desired wheels is saved in `/tensorflow_whl` directory.
To test the wheel, first spin up a container from the image that was just built, and count the number of `MKL` symbols.
Finally install the wheel and from within `Python` check if `MKL` support is provided

```bash
docker run -it centos-tf-3.6-v2 bash

nm -D  /tensorflow_src/bazel-out/k8-opt/bin/tensorflow/libtensorflow_framework.so.1 | grep -i mkl | wc -l
15718

pip3 install /tensorflow_whls/tensorflow-1.15.2-cp36-cp36m-linux_x86_64.whl
```

```python
python3
Python 3.6.8 (default, Aug  7 2019, 17:28:10) 
[GCC 4.8.5 20150623 (Red Hat 4.8.5-39)] on linux
Type "help", "copyright", "credits" or "license" for more information.

>>> import tensorflow_core as tf_core
>>> tf_core.python.pywrap_tensorflow.IsMklEnabled()
True
```

If the wheels are built with `--build-arg CONFIG_VER=v1` then check for `MKL` should be as follows:
```python
python3
Python 3.6.8 (default, Aug  7 2019, 17:28:10) 
[GCC 4.8.5 20150623 (Red Hat 4.8.5-39)] on linux
Type "help", "copyright", "credits" or "license" for more information.

>>> import tensorflow as tf
>>> tf.python.pywrap_tensorflow.IsMklEnabled()
True
```


To build `Python2.7`, `Python3.6` for `v1` and `v2` configs run the following:
```bash
for py in 2.7 3.6; do
  for config in v1 v2; do
    docker build --build-arg TF_BRANCH=v1.15.2 --build-arg PY_VER=$py --build-arg CONFIG_VER=$config -f Dockerfile . -t centos-tf-$py-$config
  done
done
```


### Limitations
- Only `Python2.7` and `Python3.6` are supported and support for other versions must be added to the `Dockerfile`
- Building `TensorFlow` versions older than `v1.15.0` may result in unknown behavior and it's not tested.
