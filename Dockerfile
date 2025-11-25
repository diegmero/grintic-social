# Build stage
FROM hexpm/elixir:1.18.1-erlang-27.2-debian-bookworm-20250113-slim AS builder

# Install build dependencies
RUN apt-get update -y && apt-get install -y \
    build-essential \
    git \
    curl \
    && apt-get clean && rm -f /var/lib/apt/lists/*_*

# Set working directory
WORKDIR /app

# Install hex and rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Set build ENV
ENV MIX_ENV=prod

# Copy mix files
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV

# Copy compile config
COPY config/config.exs config/prod.exs config/runtime.exs config/
RUN mix deps.compile

# Copy application code (needed for colocated components)
COPY lib lib

# Compile the project
RUN mix compile

# Copy assets
COPY assets assets
COPY priv priv

# Compile assets
RUN mix assets.deploy

# Build release
RUN mix release

# Runtime stage
FROM debian:bookworm-20250113-slim AS runner

# Install runtime dependencies
RUN apt-get update -y && \
    apt-get install -y \
    libstdc++6 \
    openssl \
    libncurses5 \
    locales \
    ca-certificates \
    && apt-get clean && rm -f /var/lib/apt/lists/*_*

# Set locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Create app user
RUN useradd -m -u 1000 -s /bin/bash app

WORKDIR /app

# Set production environment
ENV MIX_ENV=prod

# Copy built application from builder
COPY --from=builder --chown=app:app /app/_build/prod/rel/grintic ./

# Switch to app user
USER app

# Expose port
EXPOSE 4000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
    CMD /app/bin/grintic rpc "Enum.member?(Application.started_applications(), {:grintic, ~c\"grintic\", ~c\"1.0.0\"})"

# Start the application
CMD ["/app/bin/grintic", "start"]
