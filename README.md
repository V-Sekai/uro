# Uro Server
## Docker Quick Setup

To run the entire stack locally with Docker, use these commands:

### Windows/Mac

Add these lines to your **hosts** file
```
0.0.0.0 vsekai.local
0.0.0.0 uro.v-sekai.cloud
```
then
```
mv frontend/.env.example frontend/.env
mv .env.example .env
docker compose up
```
### Linux
```
# From repository root
mv frontend/.env.example frontend/.env
mv .env.example .env

# Setup hosts file on Linux
# Server runs on 0.0.0.0 port 80 and 443
# Frontend server
sudo bash -c 'echo "0.0.0.0 vsekai.local" >> /etc/hosts'

# Point V-Sekai game to your local server
sudo bash -c 'echo "0.0.0.0 uro.v-sekai.cloud" >> /etc/hosts'

# Run frontend and backend server
docker compose up
```

Server will be available at **http://vsekai.local**

Auto generated root CA will be in `./caddy/data/caddy/pki/authorities/local/root.crt` after you run `docker compose up`.

When using default `docker compose up`, installing root certificate is **required** to connect V-Sekai game client. 
If you want to test without **TLS**, use `docker-compose.development.yml` and connect client to port 80.

**(Optional) Install root CA on Ubuntu/Debian**
```
sudo mkdir -p /usr/local/share/ca-certificates/vsekai-caddy
sudo cp ./caddy/data/caddy/pki/authorities/local/root.crt /etc/ssl/certs/
sudo bash -c 'echo "vsekai-caddy/root.crt" >> /etc/ca-certificates.conf'
sudo update-ca-certificates
```

**(Optional) Add test admin with all permissions**
```
# username: adminuser
# password: adminpassword
URO_ID=$( docker ps --format "{{.ID}} {{.Image}}" | awk '$2 ~ /^.*-uro/ {print $1}' )
docker exec ${URO_ID} mix run priv/repo/test_seeds.exs
```

## Contributing

### Setup

To run the entire stack locally with Docker in **development** mode, use the command:
```
docker compose -f docker-compose.development.yml up
```
**Development image additional features**
- Extended debug logging for Uro, Nextjs, Caddy
- Local **Mailbox** page to test email signup at http://vsekai.local/api/v1/mailbox
- HTTP server (TLS disabled) on port 80

By default, the stack uses [Caddy](https://caddyserver.com/) as a reverse proxy and is accessible at http://vsekai.local. You can adjust the values by setting `BASE_URL` environment variable in `.env` and `NEXT_BASE_URL` in `frontend/.env`. Also you will need to set it in `Caddyfile`.

If you want to configure **captcha** for registration, you need to set `TURNSTILE_SECRET_KEY` and `NEXT_PUBLIC_TURNSTILE_SITEKEY` ([Cloudflare Turnstile](https://developers.cloudflare.com/turnstile/get-started/))

Once configured, access the application at:
- http://vsekai.local/
- http://vsekai.local/api/v1/

### OpenAPI Specification

When making changes to Uro, update the OpenAPI specification by running:
```
mix uro.apigen
```
This command generates the OpenAPI specification in `frontend/src/__generated/openapi.json`. The Uro API serves this specification at http://vsekai.local/api/v1/openapi, with documentation available at http://vsekai.local/api/v1/docs.

Once you have updated the OpenAPI specification, to regenerate the client in the frontend (and your editor), run:
```
docker compose -f docker-compose.development.yml up nextjs --build
```
