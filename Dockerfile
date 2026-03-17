FROM ubuntu:24.04

# Prevent interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    ca-certificates \
    && curl -fsSL https://repo.jotta.cloud/public.gpg | gpg --dearmor -o /usr/share/keyrings/jotta.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/jotta.gpg] https://repo.jotta.cloud/debian debian main" > /etc/apt/sources.list.d/jotta-cli.list \
    && apt-get update -y \
    && apt-get install -y jotta-cli \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Entrypoint script to keep daemon running
RUN echo '#!/bin/bash\njottad &\nsleep 2\njotta-cli status\ntail -f /dev/null' > /entrypoint.sh && chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
