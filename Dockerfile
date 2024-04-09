FROM ubuntu:20.04

USER root

SHELL ["/bin/bash", "-c"]
ENV DEBIAN_FRONTEND noninteractive

# Install baseline packages
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y \
    bash \
    build-essential \
    curl \
    man \
    locales \
    less \
    git \
    htop \
    sudo \
    git \
    jq \
    vim \
    wget \
    unzip

# Make cleanup
RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add veco user
RUN useradd veco \
    --create-home \
    --shell=/bin/bash \
    --uid=1000 \
    --user-group && \
    echo "veco ALL=(ALL) NOPASSWD:ALL" >>/etc/sudoers.d/nopasswd

ENV LANG en_US.UTF-8

USER veco
WORKDIR /home/veco

RUN sudo locale-gen en_US.UTF-8 && sudo update-locale

RUN wget https://github.com/vecocoin/veco/releases/download/v1.13.4/vecocore-1.13.4-x86_64-ubuntu20-gnu.tar.gz && \
    tar -xvf vecocore-1.13.4-x86_64-ubuntu20-gnu.tar.gz && \
    sudo cp vecocore-1.13.4/bin/* /usr/local/bin/ && \
    rm -rf vecocore-1.13.4-x86_64-ubuntu20-gnu.tar.gz vecocore-1.13.4