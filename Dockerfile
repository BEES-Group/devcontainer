FROM mcr.microsoft.com/devcontainers/base:debian

# Install system packages: Python & Doppler
RUN  true \
  && apt-get update -q \
  && apt-get install -y apt-transport-https ca-certificates curl gnupg python3 \
  && curl -sLf --retry 3 --tlsv1.2 --proto "=https" 'https://packages.doppler.com/public/cli/gpg.DE2A7741A397C129.key' | sudo gpg --dearmor -o /usr/share/keyrings/doppler-archive-keyring.gpg \
  && echo "deb [signed-by=/usr/share/keyrings/doppler-archive-keyring.gpg] https://packages.doppler.com/public/cli/deb/debian any-version main" | sudo tee /etc/apt/sources.list.d/doppler-cli.list \
  && apt-get update -q && apt-get install doppler

# Switch to vscode user
USER vscode

# Install FNM
RUN curl -fsSL https://fnm.vercel.app/install | bash
RUN echo 'eval "`fnm env --use-on-cd --resolve-engines --corepack-enabled`"' >> /home/vscode/.bashrc
ENV PATH="${PATH}:/home/vscode/.local/share/fnm"

# Install Node LTS, make it default and enable CorePack
RUN ["/bin/bash", "-c", "true \
  && fnm install lts/latest \
  && fnm default lts/latest \
  && fnm exec --using=default corepack enable \
  "]

# Set PNPM's store location
RUN mkdir /home/vscode/.pnpm-store
VOLUME /home/vscode/.pnpm-store
RUN fnm exec --using=default pnpm config set store-dir /home/vscode/.pnpm-store

# Install global NPM packages
RUN fnm exec --using=default npm install -g node-gyp eslint prettier @go-task/cli