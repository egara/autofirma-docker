FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive
ARG USER_ID=1000
ARG GROUP_ID=1000
ARG USER_NAME=egarcia

# Install dependencies
RUN apt-get update && apt-get install -y \
    software-properties-common \
    gpg \
    wget \
    unzip \
    sudo \
    curl \
    --no-install-recommends

# Setup Mozilla Team PPA for native Firefox (non-snap)
RUN add-apt-repository ppa:mozillateam/ppa -y && \
    echo 'Package: *\nPin: release o=LP-PPA-mozillateam\nPin-Priority: 1001\n' | tee /etc/apt/preferences.d/mozilla-firefox && \
    apt-get update && \
    apt-get install -y \
    firefox \
    default-jre \
    libnss3-tools \
    libnss3 \
    libatk-bridge2.0-0 \
    libgtk-3-0 \
    libx11-xcb1 \
    libxcb1 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxi6 \
    libxtst6 \
    libcups2t64 \
    libxss1 \
    libxrandr2 \
    libasound2t64 \
    libpangocairo-1.0-0 \
    libgdk-pixbuf2.0-0 \
    ca-certificates \
    xdg-utils \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# Create user
RUN if getent passwd ubuntu >/dev/null; then userdel -r ubuntu; fi && \
    if getent group ubuntu >/dev/null; then groupdel ubuntu; fi && \
    groupadd -g ${GROUP_ID} ${USER_NAME} && \
    useradd -m -u ${USER_ID} -g ${USER_NAME} -s /bin/bash ${USER_NAME} && \
    echo "${USER_NAME} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Download and install Autofirma
WORKDIR /tmp
RUN wget -O Autofirma.zip https://firmaelectronica.gob.es/content/dam/firmaelectronica/descargas-software/autofirma19/Autofirma_Linux_Debian.zip && \
    unzip Autofirma.zip && \
    ls -l && \
    # The deb file name might vary, so we use a wildcard or find
    apt-get update && \
    apt-get install -y ./autofirma_*.deb && \
    rm Autofirma.zip autofirma_*.deb

# Set up Firefox policy to trust system certificates (Autofirma adds its CA to system store usually)
# However, Autofirma script might try to add to user's nssdb.
# We will handle the trust in the entrypoint or ensure it works.

USER ${USER_NAME}
WORKDIR /home/${USER_NAME}

# Entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
USER root
RUN chmod +x /usr/local/bin/entrypoint.sh
USER ${USER_NAME}

CMD ["/usr/local/bin/entrypoint.sh"]
