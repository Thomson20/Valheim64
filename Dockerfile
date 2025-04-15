FROM debian:12.4-slim

# Install dependencies
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y \
      libc6:i386 \
      libstdc++6:i386 \
      libgl1:i386 \
      libsdl2-2.0-0:i386 \
      libcurl4:i386 \
      wget \
      tar \
      git \
      cmake \
      python3 \
      python3-pip \
      python-is-python3 && \
    rm -rf /var/lib/apt/lists/*

# Install Box64
RUN git clone https://github.com/ptitSeb/box64 && \
    cd box64 && \
    mkdir build && cd build && \
    cmake .. -DARM_DYNAREC=ON -DCMAKE_BUILD_TYPE=RelWithDebInfo && \
    make -j$(nproc) && \
    make install && \
    cd / && \
    rm -rf /box64

# Configure Box64 environment
ENV BOX64_LD_LIBRARY_PATH=/lib/i386-linux-gnu:/usr/lib/i386-linux-gnu
ENV BOX64_PATH=/usr/local/bin

# Install SteamCMD with Box64 emulation
RUN mkdir -p /steamcmd && cd /steamcmd && \
    wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz && \
    tar -xvzf steamcmd_linux.tar.gz && \
    rm steamcmd_linux.tar.gz && \
    box64 /steamcmd/steamcmd.sh +quit

# Install Valheim server
RUN box64 /steamcmd/steamcmd.sh \
      +login anonymous \
      +force_install_dir /valheim-server \
      +app_update 896660 validate \
      +quit

# Configure runtime
WORKDIR /valheim-server
COPY run.sh /run.sh
RUN chmod +x /run.sh

EXPOSE 2456-2458/udp
CMD ["/bin/sh", "/run.sh"]
