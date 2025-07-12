# Use the latest Ubuntu LTS release
FROM ubuntu:latest

# Default timezone
ARG TZ=Etc/UTC

# Install packages
RUN ( echo $TZ > /etc/timezone ) && \
    TZ=$TZ DEBIAN_FRONTEND=noninteractive apt install --update --yes curl just sudo tzdata && \
    rm -rf /var/lib/apt/lists/*

# Add demo user with sudo privileges
RUN usermod --login demo --home /home/demo --move-home ubuntu && \
    groupmod --new-name demo ubuntu && \
    echo "demo ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers

# Set default user and home
USER demo
WORKDIR /home/demo

# Copy setup into the image
COPY --chown=demo:demo . /home/demo/setup

# Run the install script
RUN setup/install.sh --name Demo --email demo@example.com
