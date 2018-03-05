FROM nvidia/cuda:8.0-devel-ubuntu16.04
LABEL authors="Vašek Dohnal <vaclav.dohnal@gmail.com>"

RUN apt-get update && apt-get install -y --no-install-recommends software-properties-common && add-apt-repository ppa:jonathonf/python-3.6 -y
RUN apt-get update && apt-get install -y --no-install-recommends \
    libopenblas-dev \
    python-numpy \
    python3.6 \
    python3.6-dev \
    swig \
    git \
    wget \
    && rm -rf /var/lib/apt/lists/*

RUN curl https://bootstrap.pypa.io/get-pip.py | python3.6
RUN pip3.6 install --no-input --upgrade --no-cache-dir pip setuptools wheel
RUN pip3.6 install --isolated --no-input --compile --exists-action=a --disable-pip-version-check --use-wheel --no-cache-dir matplotlib

WORKDIR /opt
RUN git clone --depth=1 https://github.com/facebookresearch/faiss
WORKDIR /opt/faiss


ENV BLASLDFLAGS /usr/lib/libopenblas.so.0
RUN mv example_makefiles/makefile.inc.Linux ./makefile.inc

RUN make tests/test_blas -j $(nproc) && \
    make -j $(nproc) && \
    make tests/demo_sift1M -j $(nproc)

RUN make py

RUN cd gpu && \
    make -j $(nproc) && \
    make test/demo_ivfpq_indexing_gpu && \
    make py
