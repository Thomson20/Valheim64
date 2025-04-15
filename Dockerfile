FROM debian:12.4-slim

# Install x86_64 emulation + dependencies
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
      cmake

# Install Box64 (for x86_64 emulation)
RUN git clone https://github.com/ptitSeb/box64 && \
    cd box64 && \
    mkdir build && cd build && \
    cmake .. -DARM_DYNAREC=ON -DCMAKE_BUILD_TYPE=RelWithDebInfo && \
    make -j$(nproc) && \
    make install && \
    cd / && rm -rf /box64

# Install SteamCMD
RUN mkdir -p /steamcmd && \
    cd /steamcmd && \
    wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz && \
    tar -xvzf steamcmd_linux.tar.gz && \
    rm steamcmd_linux.tar.gz

# Install Valheim
RUN /steamcmd/steamcmd.sh \
      +login anonymous \
      +force_install_dir /valheim-server \
      +app_update 896660 validate \
      +quit

# Install dependencies (replace the existing RUN command)
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
      python-is-python3 && \  # Critical for CMake to find Python
    rm -rf /var/lib/apt/lists/*

# Configure runtime
WORKDIR /valheim-server
ENV LD_LIBRARY_PATH="/lib/i386-linux-gnu:/usr/lib/i386-linux-gnu:${LD_LIBRARY_PATH}"
EXPOSE 2456-2458/udp

# Launch script
COPY run.sh /run.sh
RUN chmod +x /run.sh
CMD ["/bin/sh", "/run.sh"]
