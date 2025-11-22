# Contributing

## Configure Hosts

In order to run this application, add to **hosts** file the following:

```sh
0.0.0.0 vsekai.local
0.0.0.0 uro.v-sekai.cloud
```

And create the env files for both backend and frontend:

```sh
.env
frontend/.env
```

This can be done by running one of these scripts:

```sh
# Run as Administrator
./scripts/initial_setup_windows.sh
sudo ./scripts/initial_setup_linux_or_mac.sh
```

## Docker Quick Setup

Run using docker compose:

```sh
docker compose up
```

Server will be available at **http://vsekai.local**

Auto generated root CA will be in `./caddy/data/caddy/pki/authorities/local/root.crt` after you run `docker compose up`.

## Run locally

### Setup

To run the entire stack locally with Docker in **development** mode, use the command:

```sh
docker compose -f docker-compose.development.yml up
```

By default, the stack uses [Caddy](https://caddyserver.com/) as a reverse proxy and is accessible at http://vsekai.local. You can adjust the values by setting the `ROOT_ORIGIN`, `URL`, and `FRONTEND_URL` environment variables in `.env` and `NEXT_PUBLIC_ORIGIN`, `NEXT_PUBLIC_API_ORIGIN` in `frontend/.env`. Also you will need to set it in `Caddyfile`.

If you want to configure **captcha** for registration, you need to set `TURNSTILE_SECRET_KEY` and `NEXT_PUBLIC_TURNSTILE_SITEKEY` ([Cloudflare Turnstile](https://developers.cloudflare.com/turnstile/get-started/))

Once configured, access the application at:
- http://vsekai.local/
- http://vsekai.local/api/v1/

### OpenAPI Specification

When making changes to Uro, update the OpenAPI specification by running:

```sh
mix uro.apigen
```

This command generates the OpenAPI specification in `frontend/src/__generated/openapi.json`. The Uro API serves this specification at http://vsekai.local/api/v1/openapi, with documentation available at http://vsekai.local/api/v1/docs.

Once you have updated the OpenAPI specification, to regenerate the client in the frontend (and your editor), run:

```sh
docker compose -f docker-compose.development.yml up nextjs --build
```
