# Architecture

## Overview

This is a full-stack web application built with Elixir/Phoenix for the backend and Next.js for the frontend. It follows a layered architecture separating concerns into presentation, application, domain, and infrastructure layers. The app handles user authentication, OAuth integration, file uploads, and API serving.

## Layers

### Presentation Layer
- **Frontend (Next.js)**: Located in [`frontend`](frontend) directory. Handles user interface, client-side routing, and API interactions using React, Tailwind CSS, and libraries like TanStack Query. Accessible at `http://vsekai.local` via Caddy reverse proxy.

### Application Layer
- **Phoenix Controllers**: Handle HTTP requests and responses (e.g., in `lib/uro/controllers/`). Manage routing, parameter parsing, and response rendering.
- **Phoenix Views**: Render JSON/HTML responses (e.g., in `lib/uro/` - views are typically inline or in separate files).
- **Endpoint**: Configured in `lib/uro/endpoint.ex`, uses Bandit adapter for HTTP serving on port 4000 (configurable).

### Domain Layer
- **Contexts**: Business logic modules (e.g., `Uro.Accounts`, `Uro.UserIdentities` in [`lib/uro`](lib/uro)). Encapsulate domain operations like user management and OAuth.
- **Schemas**: Ecto data models (e.g., `Uro.Accounts.User` in [`lib/uro/accounts/user.ex`](lib/uro/accounts/user.ex)). Define database entities and validations.
- **Pow Extensions**: Authentication framework with persistent sessions and email confirmation (configured in [`config/config.exs`](config/config.exs)).

### Infrastructure Layer
- **Database**: PostgreSQL via Ecto.Repo (configured in [`config/config.exs`](config/config.exs)). Handles data persistence with migrations in [`priv/repo/migrations`](priv/repo/migrations).
- **Cache**: Redis via Redix (configured in [`config/config.exs`](config/config.exs)). Used for session storage and caching.
- **File Storage**: Waffle with local storage (configured in [`config/config.exs`](config/config.exs)). Manages uploads.
- **Rate Limiting**: Hammer backend with ETS (configured in [`config/config.exs`](config/config.exs)).
- **Authentication/OAuth**: PowAssent for OAuth providers (dynamically configured via env vars like `OAUTH2_*_CLIENT_ID`).
- **Captcha**: Cloudflare Turnstile (optional, via `TURNSTILE_SECRET_KEY`).
- **CORS**: Handled by `cors_plug` (configured in [`config/config.exs`](config/config.exs)).
- **JWT**: Joken for token signing (configured in [`config/config.exs`](config/config.exs)).
- **Reverse Proxy**: Caddy (external, configured in [`Caddyfile`](Caddyfile) for development/production).

## Additional Components
- **Config Helpers**: Custom helpers in [`config/helpers.exs`](config/helpers.exs) for environment variable handling.
- **Mix Tasks**: Custom tasks like `mix uro.apigen` for OpenAPI generation.
- **Docker Setup**: [`docker-compose.yml`](docker-compose.yml) and [`docker-compose.development.yml`](docker-compose.development.yml) for containerized deployment.
- **Scripts**: Shell scripts in [`scripts`](scripts) for initial setup (hosts, env files).
