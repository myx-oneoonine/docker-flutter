# Flutter Development Environment with FVM support
ARG FLUTTER_VERSION=stable
FROM ubuntu:22.04

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    wget \
    unzip \
    lib32stdc++6 \
    libglu1-mesa \
    default-jdk \
    build-essential \
    make \
    cmake \
    ninja-build \
    clang \
    libgtk-3-dev \
    libblkid1 \
    liblzma5 \
    libc6 \
    libc6-dev \
    libstdc++6 \
    ca-certificates \
    gnupg \
    xz-utils \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create flutter user
RUN useradd -m -s /bin/bash flutter && \
    usermod -aG sudo flutter && \
    echo 'flutter ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Use the official Flutter Docker approach - install as root then change ownership
# Set environment variables to skip SSL verification for downloads
ENV GIT_SSL_NO_VERIFY=1
ENV FLUTTER_STORAGE_BASE_URL=https://storage.googleapis.com

# Install Flutter directly using git 
RUN cd /opt && \
    git config --global http.sslverify false && \
    git clone https://github.com/flutter/flutter.git && \
    cd flutter && \
    (git checkout ${FLUTTER_VERSION} || git checkout tags/${FLUTTER_VERSION} || git checkout stable) && \
    cd .. && \
    chown -R flutter:flutter /opt/flutter && \
    git config --global --add safe.directory /opt/flutter

# Create workspace directory with proper ownership
RUN mkdir -p /workspace && chown flutter:flutter /workspace

# Switch to flutter user
USER flutter
WORKDIR /home/flutter

# Set up environment paths
ENV PATH="/opt/flutter/bin:/opt/flutter/bin/cache/dart-sdk/bin:${PATH}"
ENV FLUTTER_ROOT="/opt/flutter"
ENV PUB_CACHE="/home/flutter/.pub-cache"
ENV FLUTTER_NO_ANALYTICS=1
ENV FLUTTER_SUPPRESS_ANALYTICS_REPORTING=1

# Configure git for flutter user
RUN git config --global http.sslverify false && \
    git config --global --add safe.directory /opt/flutter

# Configure curl to ignore SSL issues (for Flutter downloads)
RUN echo 'insecure' > ~/.curlrc && \
    echo '--insecure' > ~/.curlrc && \
    mkdir -p ~/.config/configstore && \
    echo '{"optOut": true, "lastUpdateNotification": 1500000000000}' > ~/.config/configstore/update-notifier-flutter-tools.json

# Download Dart SDK and configure Flutter - pre-cache during build
RUN cd /opt/flutter && \
    ./bin/flutter config --no-analytics && \
    ./bin/flutter doctor || true && \
    ./bin/flutter --version || true

# Install FVM for version management (if needed)
RUN /opt/flutter/bin/flutter pub global activate fvm || true

# Update PATH to include pub cache for FVM
ENV PATH="/home/flutter/.pub-cache/bin:${PATH}"

# Set working directory to the new workspace
WORKDIR /workspace

# Set default command
CMD ["/bin/bash"]