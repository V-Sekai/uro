FROM elixir:1.16-alpine

ENV PORT 4000

WORKDIR /app

# make,gcc,libc-dev required for bcrypt
RUN apk add --update postgresql-client nodejs yarn npm inotify-tools git bash

RUN mix do local.hex --force, local.rebar --force
COPY mix.exs mix.lock ./
RUN apk add --update make gcc libc-dev && MIX_ENV=prod mix do deps.get, deps.compile && mkdir assets && apk del make binutils gmp libgomp libatomic mpfr4 mpc1 gcc musl-dev libc-dev

COPY assets/package.json assets/package-lock.json ./assets/
RUN cd assets && npm install; cd -
