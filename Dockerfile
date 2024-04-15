FROM ubuntu:20.04

USER root

SHELL ["/bin/bash", "-c"]
ENV DEBIAN_FRONTEND noninteractive

# Install baseline packages
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install --no-install-recommends -y \
    bash \
    build-essential \
    curl \
    man \
    locales \
    less \
    git \
    htop \
    sudo \
    wget \
    unzip \
    libtool \
    autotools-dev \
    automake \
    pkg-config \
    libssl-dev \
    libevent-dev \
    bsdmainutils \
    libdb-dev \
    libdb++-dev \
    libboost-system-dev \
    libboost-filesystem-dev \
    libboost-chrono-dev \
    libboost-program-options-dev \
    libboost-test-dev \
    libboost-thread-dev \
    libzmq3-dev \
    python3-pip \
    python3-dev \
    libffi-dev \
    libminiupnpc-dev \
    libdb5.3++-dev \
    libdb5.3-dev \
    libdb5.3++ \
    libdb5.3 \
    libssl-dev \
    nano \
    cron \
    libevent-dev

# Install pip packages
RUN pip3 install --upgrade pip
RUN pip3 install matplotlib
RUN sudo apt install python3-venv -y

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

# Install veco
RUN wget https://github.com/vecocoin/veco/releases/download/v1.13.4/vecocore-1.13.4-x86_64-ubuntu20-gnu.tar.gz --no-check-certificate && \
    tar -xvf vecocore-1.13.4-x86_64-ubuntu20-gnu.tar.gz && \
    sudo cp vecocore-1.13.4/bin/* /usr/local/bin/ && \
    rm -rf vecocore-1.13.4-x86_64-ubuntu20-gnu.tar.gz vecocore-1.13.4

# Install boost
RUN wget https://boostorg.jfrog.io/artifactory/main/release/1.71.0/source/boost_1_71_0.tar.bz2 --no-check-certificate && \
    tar -xvf boost_1_71_0.tar.bz2 && \
    cd boost_1_71_0 && \
    ./bootstrap.sh && \
    sudo ./b2 install && \
    cd .. && \
    sudo rm -rf boost_1_71_0.tar.bz2 boost_1_71_0

# Set library path
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib

# Add aliases to .bashrc
RUN echo "\
    # General Aliases\n\
    alias ll='ls -l --color=auto'\n\
    " >> /home/veco/.bashrc

# Create data directory
RUN mkdir -p /home/veco/.vecocore

# Install sentinel
RUN pip install Cython
RUN cd ~ && git clone https://github.com/vecopay/sentinel.git
RUN cd sentinel && python3 -m venv ./venv && ./venv/bin/pip install -r requirements.txt
RUN (crontab -l 2>/dev/null; echo "* * * * * cd /home/veco/sentinel && ./venv/bin/python bin/sentinel.py >/dev/null 2>&1") | crontab -

# I need to add a volume for the data directory
VOLUME ["/home/veco/.vecocore"]

# Expose ports
EXPOSE 26919 26919

# Start veco
USER veco
CMD ["/usr/local/bin/vecod"]