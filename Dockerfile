FROM ubuntu:xenial as builder

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

FROM ubuntu:xenial

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get install -y libmpfr4 libgmp10 zlib1g

RUN adduser --disabled-password --gecos '' kevm

USER kevm
WORKDIR /home/kevm
ENV USER kevm

WORKDIR evm-semantics

ARG KEVM_PORT
ENV KEVM_PORT ${KEVM_PORT:-8888}

ARG KEVM_HOST
ENV KEVM_HOST ${KEVM_HOST:-0.0.0.0}

ARG KEVM_DEBUG
ENV KEVM_DEBUG ${KEVM_DEBUG:-}

COPY --from=builder /home/kevm/evm-semantics/.build/vm/kevm-vm ./.build/vm/kevm-vm
COPY --from=builder /home/kevm/evm-semantics/.build/local/lib ./.build/local/lib

CMD LD_LIBRARY_PATH=./.build/local/lib ./.build/vm/kevm-vm $KEVM_PORT $KEVM_HOST $KEVM_DEBUG
