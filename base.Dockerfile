FROM elixir:1.11-alpine

ENV PORT 4000

WORKDIR /app

# make,gcc,libc-dev required for bcrypt

RUN apk add --update postgresql-client nodejs nodejs-npm inotify-tools git bash make gcc libc-dev

RUN mix do local.hex --force, local.rebar --force
COPY mix.exs mix.lock ./
RUN MIX_ENV=prod mix do deps.get, deps.compile && mkdir assets

COPY assets/package.json assets/package-lock.json ./assets/
RUN cd assets && npm install; cd -

RUN apk del make binutils gmp isl libgomp libatomic mpfr4 mpc1 gcc musl-dev libc-dev
