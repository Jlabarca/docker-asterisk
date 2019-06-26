FROM debian:jessie

RUN apt-get update && \
    apt-get -y install sudo

ENV user asterisk

RUN useradd -m -d /home/${user} ${user} && \
    chown -R ${user} /home/${user} && \
    adduser ${user} sudo && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

#USER ${user}

RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update -qq -y && \
    apt-get install -y --no-install-recommends \
            subversion \
            automake \
            aptitude \
            autoconf \
            binutils-dev \
            build-essential \
            ca-certificates \
            curl \
            libcurl4-openssl-dev \
            libedit-dev \
            libgsm1-dev \
            libjansson-dev \
            libogg-dev \
            libpopt-dev \
            libresample1-dev \
            libspandsp-dev \
            libspeex-dev \
            libspeexdsp-dev \
            libsqlite3-dev \
            libsrtp0-dev \
            libssl-dev \
            libvorbis-dev \
            libxml2-dev \
            libxslt1-dev \
            portaudio19-dev \
            python-pip \
            unixodbc-dev \
            uuid \
            uuid-dev \
            xmlstarlet \
            unixodbc \
            unixodbc-dev \
            libmyodbc \
            python-dev \
            python-pip \
            python-mysqldb \
            git \
            wget && \
    apt-get purge -y --auto-remove && \
    pip install alembic

## Install sngrep
RUN echo 'deb http://packages.irontec.com/debian jessie main' >> /etc/apt/sources.list && \
    wget http://packages.irontec.com/public.key -q -O - | apt-key add - && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get update -y && \
    apt-get install -y sngrep

RUN rm -rf /var/lib/apt/lists/*

ADD conf /etc/asterisk/conf
ADD keys /etc/asterisk/keys
COPY build-asterisk.sh /build-asterisk.sh
RUN sudo chmod +x /build-asterisk.sh
ENV ASTERISK_VERSION=16.4.0
RUN sudo DEBIAN_FRONTEND=noninteractive bash /build-asterisk.sh

CMD ["/usr/sbin/asterisk", "-f"]
