FROM ubuntu:xenial

# https://github.com/kframework/evm-semantics/

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get install -y make gcc maven openjdk-8-jdk flex opam pkg-config libmpfr-dev autoconf libtool pandoc zlib1g-dev

# extra stuff not mentioned in the KEVM source repo but essential nevertheless
RUN apt-get install -y python3

RUN adduser --disabled-password --gecos '' kevm

USER kevm
WORKDIR /home/kevm
ENV USER kevm

RUN git clone https://github.com/kframework/evm-semantics

WORKDIR evm-semantics
RUN env
RUN make deps
RUN make

ARG KEVM_PORT
ENV KEVM_PORT ${KEVM_PORT:-8888}

ARG KEVM_HOST
ENV KEVM_HOST ${KEVM_HOST:-0.0.0.0}

ARG KEVM_DEBUG
ENV KEVM_DEBUG ${KEVM_DEBUG:-}

CMD LD_LIBRARY_PATH=./.build/local/lib ./.build/vm/kevm-vm $KEVM_PORT $KEVM_HOST $KEVM_DEBUG