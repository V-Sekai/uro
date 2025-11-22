ARG ELIXIR_VERSION=1.16

# Elixir build environment.
FROM elixir:${ELIXIR_VERSION}-alpine AS elixir-base

ARG MIX_ENV=prod

ENV MIX_ENV=${MIX_ENV} \
	COMPILE_PHASE=true

WORKDIR /app

RUN apk add --no-cache \
	nodejs \
	npm \
	inotify-tools \
	git \
	bash \
	make \
	gcc \
	curl \
	libc-dev \
	openssl \
	ca-certificates

RUN update-ca-certificates || true && rm -rf /root/.mix/archives/* && \
	mix local.hex --force && \
	mix local.rebar --force

COPY mix.exs mix.lock ./
# Ensure no cached hex artifacts are present (avoids architecture mismatch when restoring cache)
RUN rm -rf /root/.mix/archives/* || true
RUN mix do deps.get, patch.exmarcel, deps.compile

COPY config ./config
COPY priv ./priv
COPY lib ./lib

RUN mix do compile, phx.digest
RUN mix uro.apigen

EXPOSE ${PORT}

ENV COMPILE_PHASE=false
ENTRYPOINT ["sh", "-c", "iex -S mix do ecto.migrate, phx.server"]
