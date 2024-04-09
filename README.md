# Uro

## Local Dev
 
It's possible to run the entire stack locally with docker-compose by running `docker-compose up` 

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix

## How to create a test environment?

```bash
cockroach start-single-node --insecure --background
export MIX_ENV=dev 
mix deps.get
mix ecto.drop
mix ecto.setup
mix run priv/repo/test_seeds.exs
iex -S mix phx.server
```
Note that `bcrypt_elixir` will require a working compiler in the PATH. On a Windows system with Visual Studio, you will want to run `mix deps.compile --force` from within a "x64 Native Tools Command Prompt" or cmd with vcvarsall.bat (may fail to build the rest of uro) then return to a bash shell for the rest of the build.


## Log into Cockroachdb sql shell

`./cockroach sql --database="uro_dev" --insecure`
