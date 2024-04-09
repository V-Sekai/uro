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

You may approve all pending email verifications using:

```
update users set email_confirmation_token=null, email_confirmed_at=NOW() where true;
```

And you can grant upload privileges for all users using
```
update user_privilege_rulesets set can_upload_avatars=true, can_upload_maps=true, can_upload_props=true where true;
```

Finally, to enable admin access for a specific user id:
```
update user_privilege_rulesets set is_admin=true where user_id = '12345678-abcd-...';
```

## Host local CDN for testing

By default, the `dev` environment will store assets in `priv/waffle/private` directory, and the client expects this to be available on port 80. To serve the CDN content on port 80:

```
cd priv/waffle/private
python -m http.server 80
```

Windows allows any user to serve port 80 by default, but on other operating systems the above should be run with sudo.
