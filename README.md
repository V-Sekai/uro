# Uro

## Contributing

### Setup

To run the entire stack locally with Docker, use the command:
```
docker compose -f docker-compose.development.yml up
```

By default, the stack uses [Caddy](https://caddyserver.com/) as a reverse proxy and is accessible at http://vsekai.local. You can adjust the values by setting the `ROOT_ORIGIN`, `URL`, and `FRONTEND_URL` environment variables. Once configured, access the application at:
- http://vsekai.local/
- http://vsekai.local/api/v1/

### OpenAPI Specification

When making changes to Uro, update the OpenAPI specification by running:
```
mix openapi.spec.json --spec Uro.OpenAPI.Specification --pretty --vendor-extensions=false ./frontend/src/__generated/openapi.json
```
This command generates the OpenAPI specification in `frontend/src/__generated/openapi.json`. The Uro API serves this specification at http://vsekai.local/api/v1/openapi, with documentation available at http://vsekai.local/api/v1/docs.

Once you have updated the OpenAPI specification, to regenerate the client in the frontend (and your editor), run:
```
docker compose -f docker-compose.development.yml up nextjs --build
```