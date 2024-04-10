# Uro

## Local Dev

It's possible to run the entire stack locally with docker-compose by running `docker-compose up`

To start your Phoenix server:

- Install dependencies with `mix deps.get`
- Create and migrate your database with `mix ecto.setup`
- Install Node.js dependencies with `cd assets && npm install`
- Start Phoenix endpoint with `mix phx.server`

Now, you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

- Official website: https://www.phoenixframework.org/
- Guides: https://hexdocs.pm/phoenix/overview.html
- Docs: https://hexdocs.pm/phoenix
- Forum: https://elixirforum.com/c/phoenix-forum
- Source: https://github.com/phoenixframework/phoenix

## How do you create a test environment?

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

## How do we create a test environment for the Macos?

```bash
# Start in v-sekai/v-sekai-other-world
cd mvsqlite
cargo build --locked --release -p mvstore --manifest-path Cargo.toml
export RUST_LOG=error
DYLD_FALLBACK_LIBRARY_PATH=/usr/local/lib ./target/release/mvstore --data-plane 127.0.0.1:7000 --admin-api 127.0.0.1:7001 --metadata-prefix mvstore-test --raw-data-prefix m --auto-create-namespace --cluster /usr/local/etc/foundationdb/fdb.cluster &
```

```bash
# create database
sleep 1
curl http://localhost:7001/api/create_namespace -d '{"key":"uro_dev.sqlite3","metadata":""}'
sleep 1
```

```
cd SERVICE_uro_sqlite_fdb
MIX_ENV=test mix ecto.setup
MIX_ENV=test mix run priv/repo/test_seeds.exs
MIX_ENV=test mix test | tee test_output.txt; test ${PIPESTATUS[0]} -eq 0
```

## Log into Cockroachdb sql shell

`./cockroach sql --database="uro_dev" --insecure`

You may approve all pending email verifications using the following:

```sql
update users set email_confirmation_token=null, email_confirmed_at=NOW() where true;
```

You can grant upload privileges to all users using

```sql
update user_privilege_rulesets set can_upload_avatars=true, can_upload_maps=true, can_upload_props=true where true;
```

Finally, to enable admin access for a specific user ID:

```sql
update user_privilege_rulesets set is_admin=true where user_id = '12345678-abcd-...';
```

## Host local CDN for testing

By default, the `dev` environment will store assets in `priv/waffle/private` directory, and the client expects this to be available on port 80. To serve the CDN content on port 80:

```bash
cd priv/waffle/private
python -m http.server 80
```

Windows allows any user to serve port 80 by default, but the above should be run with sudo on other operating systems.

# Mvsqlite

```
UPDATE users SET email_confirmation_token = NULL, email_confirmed_at = datetime('now') WHERE 1;
```
