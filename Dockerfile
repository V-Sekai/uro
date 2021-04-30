FROM docker.io/groupsinfra/elixir-uro-base:v1.1.1

ENV PORT 4000

WORKDIR /app

COPY . ./

RUN cd assets/ && yarn install && npm install && npm run deploy ; cd -

RUN MIX_ENV=prod COMPILE_PHASE=1 mix deps.get

RUN MIX_ENV=prod COMPILE_PHASE=1 mix do compile, phx.digest

CMD MIX_ENV=prod mix ecto.migrate && MIX_ENV=prod mix phx.server

