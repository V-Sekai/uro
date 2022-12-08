FROM uro:build

WORKDIR /app

RUN apk add --update postgresql-client nodejs npm inotify-tools git bash make gcc libc-dev

RUN mix local.hex --force
RUN mix local.rebar --force

ENV PORT 4000

RUN apk del make
ENTRYPOINT mix ecto.create && mix ecto.migrate && mix phx.server