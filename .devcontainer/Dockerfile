# Start from an official lightweight Python base
FROM python:3.12-slim

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV VENV_PATH=/workspace/.venv

# Install dev system dependencies and dev tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    make \
    git \
    curl \
    bash \
    ca-certificates \
    unzip \
    wget \
    lsb-release \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# Optional: install Terraform & lint tools if they’re part of your Makefile hooks
RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
    > /etc/apt/sources.list.d/hashicorp.list && \
    apt-get update && apt-get install -y terraform tflint yamllint hadolint && \
    rm -rf /var/lib/apt/lists/*

# Create a non-root user (best practice for devcontainers)
ARG USERNAME=dev
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && chown -R $USERNAME:$USERNAME /home/$USERNAME

USER $USERNAME
WORKDIR /workspace
