FROM debian:12.4-slim

# Install dependencies
RUN apt-get update && \
    apt-get install -y \
      wget \
      lib32gcc-s1 \
      libsdl2-2.0-0:i386 \
      curl && \
    rm -rf /var/lib/apt/lists/*

# Download pre-compiled Valheim server binary (ARM64 compatible)
RUN mkdir -p /valheim-server && cd /valheim-server && \
    wget https://valheim-server.example.com/linux-arm64/valheim_server.x86_64 -O valheim_server.x86_64 && \
    chmod +x valheim_server.x86_64

# Create startup script
RUN echo '#!/bin/sh\n\
cd /valheim-server\n\
export LD_LIBRARY_PATH=./linux64:$LD_LIBRARY_PATH\n\
exec ./valheim_server.x86_64 -nographics -batchmode \
  -name "${SERVER_NAME:-Dedicated}" \
  -port 2456 \
  -world "${WORLD_NAME:-World}" \
  -password "${SERVER_PASS:-secret}" \
  -public 1' > /run.sh && \
    chmod +x /run.sh

EXPOSE 2456-2458/udp
WORKDIR /valheim-server
CMD ["/bin/sh", "/run.sh"]
