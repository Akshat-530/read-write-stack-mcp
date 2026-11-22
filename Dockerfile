# syntax=docker/dockerfile:1
# Read-Write-Stack — ONE container: filesystem + shell + python-interpreter +
# genoffice, all with ROOT access, aggregated behind a single MCP endpoint.
FROM python:3.12-slim
ENV DEBIAN_FRONTEND=noninteractive PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y --no-install-recommends \
      curl git ca-certificates wget unzip build-essential pkg-config libssl-dev \
    && curl -fsSL https://deb.nodesource.com/setup_24.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/*

# Node MCP: official filesystem server
RUN npm install -g @modelcontextprotocol/server-filesystem@2.4.0

# genoffice MCP wrapper (not published to npm) - install from source
RUN git clone --depth 1 https://github.com/criptogus/mcp-genoffice.git /opt/mcp-genoffice \
 && cd /opt/mcp-genoffice && npm install --no-audit --no-fund

# Process supervisor
RUN pip install --no-cache-dir supervisor

# Python MCPs — isolated venvs (both need the MCP Python SDK 1.x API)
RUN python -m venv /opt/shellvenv && /opt/shellvenv/bin/pip install --no-cache-dir "mcp<2" shell-mcp-server
RUN python -m venv /opt/pyvenv    && /opt/pyvenv/bin/pip install --no-cache-dir "mcp<2" mcp-python-interpreter

# GenOffice engine source (loaded by mcp-genoffice)
RUN git clone --depth 1 https://github.com/genspark-ai/genoffice.git /opt/genoffice-src \
 && (cd /opt/genoffice-src && (npm install --no-audit --no-fund || true))
ENV GENOFFICE_SRC=/opt/genoffice-src
ENV WEBSTACK_CONFIG=/data/config/config.json
ENV MCP_ALLOW_SYSTEM_ACCESS=1

COPY app/ /app/
COPY wait_stack.py /opt/wait_stack.py
COPY shell_launcher.py /opt/shell_launcher.py
COPY supervisord.conf /etc/supervisor/supervisord.conf
COPY config/config.example.json /data/config/config.json

EXPOSE 4034
CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]
