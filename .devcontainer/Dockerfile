# Start from an official lightweight Python base
## Issues seen with python:3.12-slim related to moby-cli & moby-buildx packages not available on OS debian trixie based conatiners
FROM python:3.12-slim
## alternative python 3.12 base image to consider - ubuntu flavor instead of debian trixie
# FROM python:3.12-ubuntu24.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV VENV_PATH=/workspace/.venv

# Install dev system dependencies and dev tools; only essential dev tools for building Python env + linting
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

# Install Terraform CLI via apt repository
RUN apt-get update && apt-get install -y gnupg lsb-release curl && \
    curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
    > /etc/apt/sources.list.d/hashicorp.list && \
    apt-get update && apt-get install -y terraform && \
    rm -rf /var/lib/apt/lists/*

# Install tflint via static binary
RUN curl -L -o /tmp/tflint.zip https://github.com/terraform-linters/tflint/releases/download/v0.55.0/tflint_linux_amd64.zip && \
    unzip /tmp/tflint.zip -d /usr/local/bin && \
    chmod +x /usr/local/bin/tflint && \
    rm /tmp/tflint.zip

# Install hadolint via static binary
RUN wget -O /usr/local/bin/hadolint https://github.com/hadolint/hadolint/releases/download/v2.12.0/hadolint-Linux-x86_64 && \
    chmod +x /usr/local/bin/hadolint

# Install yamllint via apt (simple python tool, safe from repo)
RUN apt-get update && apt-get install -y yamllint && rm -rf /var/lib/apt/lists/*

# Optional: install Terraform & lint tools if they’re part of your Makefile hooks
# RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg && \
#     echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
#     > /etc/apt/sources.list.d/hashicorp.list && \
#     apt-get update && apt-get install -y terraform tflint yamllint hadolint && \
#     rm -rf /var/lib/apt/lists/*

# Create a non-root user (best practice for devcontainers)
ARG USERNAME=dev
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && chown -R $USERNAME:$USERNAME /home/$USERNAME


# Accept host Docker GID
ARG DOCKER_GID=1001
# Create a group matching host Docker GID
RUN groupadd -g $DOCKER_GID docker || true
# Add dev user to the group
RUN usermod -aG docker dev

# Auto-active venv if present
RUN echo 'if [ -d "/workspace/monitoring-stack/.venv" ]; then \
    . /workspace/monitoring-stack/.venv/Scripts/activate; \
fi' >> /home/$USERNAME/.bashrc

USER $USERNAME
WORKDIR /workspace
