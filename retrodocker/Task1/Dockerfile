
FROM ubuntu:16.04

# Set environment variables to avoid interactive prompts during install
ENV DEBIAN_FRONTEND=noninteractive

# Enable i386 architecture and update
RUN dpkg --add-architecture i386 && apt-get update

# Install required packages, including i386 architecture dependencies
RUN apt-get install -y \
    build-essential \
    wget \
    libx11-6:i386 \
    libxext6:i386 \
    libxi6:i386 \
    libxau6:i386 \
    libxt6:i386 \
    libpangoxft-1.0-0:i386 \
    libpangox-1.0-0:i386 \
    libstdc++6:i386 \
    libglib2.0-0:i386 \
    libgtk2.0-0:i386 \
    libgconf2-4:i386 \
    libasound2:i386 \
    libxrender1:i386 \
    libfontconfig1:i386 \
    && apt-get clean

# Download and install the old libraries
RUN wget http://mirrors.kernel.org/ubuntu/pool/universe/g/gtk+1.2/libgtk1.2_1.2.10-18.1build2_i386.deb -O /tmp/libgtk1.2.deb \
    && wget http://mirrors.kernel.org/ubuntu/pool/universe/g/glib1.2/libglib1.2ldbl_1.2.10-19_i386.deb -O /tmp/libglib1.2.deb \
    && dpkg -i /tmp/libgtk1.2.deb /tmp/libglib1.2.deb || true \
    && apt-get install -f -y

# Download and extract Firefox 7.0
RUN wget -q "https://ftp.mozilla.org/pub/firefox/releases/7.0/linux-i686/en-US/firefox-7.0.tar.bz2" -O /tmp/firefox.tar.bz2 \
    && tar -xjf /tmp/firefox.tar.bz2 -C /opt/

CMD ["/opt/firefox/firefox", "https://yandex.ru/games/category/midcore"]
