FROM elixir:1.16-alpine

ENV PORT 4000

WORKDIR /app

RUN apk add --update postgresql-client nodejs yarn npm inotify-tools git bash make gcc libc-dev

RUN mix local.hex --force
RUN mix local.rebar --force

RUN mix do deps.get, deps.compile

ENTRYPOINT mix ecto.create && mix ecto.migrate && mix phx.server
