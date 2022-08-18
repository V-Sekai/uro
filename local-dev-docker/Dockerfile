FROM elixir:1.11-alpine

WORKDIR /app

RUN apk add --update postgresql-client nodejs npm inotify-tools git bash make gcc libc-dev

RUN mix local.hex --force
RUN mix local.rebar --force

ENV PORT 4000

ENTRYPOINT mix ecto.create && mix ecto.migrate && mix phx.server
