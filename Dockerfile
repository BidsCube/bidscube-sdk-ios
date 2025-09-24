FROM ubuntu:22.04

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    build-essential \
    libcurl4-openssl-dev \
    pkg-config \
    python3-lldb-13 \
    && rm -rf /var/lib/apt/lists/*

# Install Swift via swiftly
RUN curl -O https://download.swift.org/swiftly/linux/swiftly-$(uname -m).tar.gz && \
    tar zxf swiftly-$(uname -m).tar.gz && \
    ./swiftly init --quiet-shell-followup && \
    bash -c "source ${SWIFTLY_HOME_DIR:-$HOME/.local/share/swiftly}/env.sh && swiftly install 6.0"

# Set up environment
ENV PATH="/root/.local/share/swiftly/bin:${PATH}"

WORKDIR /workspace

# Copy project files
COPY . .

CMD ["/bin/bash"]
