FROM python:3.10-slim-buster

WORKDIR /app

# Install system dependencies including Tailscale tools
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    curl \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Install Tailscale
RUN curl -fsSL https://tailscale.com/install.sh | sh
RUN mkdir -p /var/run/tailscale /var/cache/tailscale /var/lib/tailscale

# Install uv package manager
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.cargo/bin:${PATH}"

# Install Python dependencies
COPY pyproject.toml uv.lock ./
RUN uv sync --frozen

# Copy the rest of the application
COPY . .

# Ensure start script is executable
RUN chmod +x start.sh

CMD ["./start.sh"]
