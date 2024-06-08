ARG ELIXIR_VERSION=1.16
ARG NODE_VERSION=20

# Node.js build environment.
FROM node:${NODE_VERSION}-slim AS node-base

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable

WORKDIR /app

# Only install production dependencies, used in the final image.
FROM node-base AS node-production-dependencies

COPY ./frontend/package.json ./frontend/pnpm-lock.yaml ./
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --prod --frozen-lockfile

# Build the frontend, using all dependencies, including `devDependencies`
# which might be needed for the build.
FROM node-base AS node-build

COPY ./frontend ./
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --frozen-lockfile
RUN pnpm run build

# Elixir build environment.
FROM elixir:${ELIXIR_VERSION}-alpine as elixir-base

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

# COPY assets/package.json assets/package-lock.json ./
# RUN npm install

# COPY --from=node-production-dependencies /app/node_modules /app/frontend/node_modules
COPY --from=node-build /app/out /app/priv/static

# COPY assets/ ./
# RUN npm run deploy

WORKDIR /app
COPY config ./config
COPY priv ./priv
COPY lib ./lib

RUN mix do compile, phx.digest

EXPOSE ${PORT}

ENV COMPILE_PHASE=
ENTRYPOINT mix do ecto.migrate, phx.server
