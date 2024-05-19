ARG ELIXIR_VERSION=1.16

FROM elixir:${ELIXIR_VERSION}-alpine

ARG PORT=4000
ARG MIX_ENV=prod

ENV MIX_ENV=${MIX_ENV} \
	COMPILE_PHASE=1 \
	PORT=${PORT}

WORKDIR /app

RUN apk add --no-cache \
	nodejs \
	npm \
	inotify-tools \
	git \
	bash \
	make \
	gcc \
	libc-dev

RUN mix local.hex --force && \
	mix local.rebar --force

COPY mix.exs mix.lock ./
RUN mix do deps.get, deps.compile

WORKDIR /app/assets
COPY assets/package.json assets/package-lock.json ./
RUN npm install

COPY assets/ ./
RUN npm run deploy

WORKDIR /app
COPY config ./config
COPY priv ./priv
COPY lib ./lib

RUN mix do compile, phx.digest

EXPOSE ${PORT}

ENV COMPILE_PHASE=
ENTRYPOINT mix do ecto.migrate, phx.server
