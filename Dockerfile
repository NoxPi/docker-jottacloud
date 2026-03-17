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

# Create a robust entrypoint script
RUN echo '#!/bin/bash\n\
jottad &\n\
sleep 5\n\
\n\
# Auto-login if token is provided and not already logged in\n\
if [ -n "$JOTTA_TOKEN" ] && ! jotta-cli status | grep -q "Logged in"; then\n\
    echo "Attempting auto-login..."\n\
    jotta-cli login --token "$JOTTA_TOKEN"\n\
fi\n\
\n\
# Set device name if provided\n\
if [ -n "$JOTTA_DEVICE" ]; then\n\
    jotta-cli config set device "$JOTTA_DEVICE"\n\
fi\n\
\n\
# Set scan interval if provided\n\
if [ -n "$JOTTA_SCANINTERVAL" ]; then\n\
    jotta-cli config set scaninterval "$JOTTA_SCANINTERVAL"\n\
fi\n\
\n\
# Add the backup directory if not already added\n\
jotta-cli add /backup\n\
\n\
jotta-cli status\n\
tail -f /var/log/jottad.log' > /entrypoint.sh && chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
