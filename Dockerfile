FROM ubuntu:latest

ADD openblas.conf /etc/ld.so.conf.d/openblas.conf

RUN apt-get update
RUN apt-get install -y git-core build-essential gfortran python-dev curl python-pip
RUN pip install cython

RUN git clone -q --branch=master https://github.com/xianyi/OpenBLAS.git && \
                          cd OpenBLAS \
                          && make DYNAMIC_ARCH=1 NO_AFFINITY=1 NUM_THREADS=32 \
                          && make install

RUN ldconfig

RUN git clone -q --branch=v1.9.2 https://github.com/numpy/numpy.git /tmp/numpy
ADD numpy-site.cfg /tmp/numpy/site.cfg
RUN cd /tmp/numpy && python setup.py install

RUN git clone -q --branch=v0.15.1 https://github.com/scipy/scipy.git /tmp/scipy
ADD scipy-site.cfg /tmp/scipy/site.cfg
RUN cd /tmp/scipy && python setup.py install

RUN pip install git+https://github.com/scikit-learn/scikit-learn.git

RUN pip uninstall -y cython
RUN apt-get remove -y --purge curl git-core build-essential python-dev
RUN apt-get autoremove -y
RUN apt-get clean -y
