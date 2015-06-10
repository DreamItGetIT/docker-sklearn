#!/usr/bin/bash

set -xe

mkdir /tmp/build
cd /tmp/build

# System dependencies
apt-get -y update
apt-get -y install git-core build-essential gfortran python-dev curl
curl https://bootstrap.pypa.io/get-pip.py | python
pip install cython

# Build latest stable release from OpenBLAS from source
git clone -q --branch=master https://github.com/xianyi/OpenBLAS.git
(cd OpenBLAS \
    && make DYNAMIC_ARCH=1 NO_AFFINITY=1 NUM_THREADS=32 \
    && make install)

# Rebuild ld cache, this assumes that: /etc/ld.so.conf.d/openblas.conf was installed by Dockerfile and that the
# libraries are in /opt/OpenBLAS/lib
ldconfig

# Build NumPy and SciPy from source against OpenBLAS installed
git clone -q --branch=v1.9.2 https://github.com/numpy/numpy.git
cp /numpy-site.cfg numpy/site.cfg
(cd numpy && python setup.py install)

git clone -q --branch=v0.15.1 https://github.com/scipy/scipy.git
cp /scipy-site.cfg scipy/site.cfg
(cd scipy && python setup.py install)

# Build scikit-learn against OpenBLAS as well, by introspecting the numpy runtime config.
pip install git+git://github.com/scikit-learn/scikit-learn.git

# Reduce the image size
pip uninstall -y cython
apt-get remove -y --purge curl git-core build-essential python-dev
apt-get autoremove -y
apt-get clean -y

cd /
rm -rf /tmp/build
rm -rf /build_sklearn.sh
