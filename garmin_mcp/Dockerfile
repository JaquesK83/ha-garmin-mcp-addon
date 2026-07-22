FROM python:3.12-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    git curl jq \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir uv

WORKDIR /app
RUN git clone --depth 1 https://github.com/k8sautom8/garmin_mcp.git .
RUN uv sync --no-dev

COPY run.sh /run.sh
RUN chmod a+x /run.sh

EXPOSE 8000

CMD ["/run.sh"]
