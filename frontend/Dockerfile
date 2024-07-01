ARG NODE_ENV=production

FROM node:22-alpine AS base

FROM base AS dependencies
WORKDIR /app

RUN apk add --no-cache libc6-compat curl

COPY package.json yarn.lock* package-lock.json* pnpm-lock.yaml* ./
RUN \
	if [ -f yarn.lock ]; then yarn --frozen-lockfile; \
	elif [ -f package-lock.json ]; then npm ci; \
	elif [ -f pnpm-lock.yaml ]; then corepack enable pnpm && pnpm i; \
	else echo "Lockfile not found." && exit 1; \
	fi

FROM base AS builder

ARG NODE_ENV
WORKDIR /app

COPY --from=dependencies /app/node_modules ./node_modules
COPY . .

ARG NODE_ENV
COPY .env.$NODE_ENV .env

COPY src/__generated/openapi.json ./src/__generated/openapi.json
RUN ./node_modules/.bin/openapi-ts

ENV NODE_ENV=production
RUN npm run build --no-lint

FROM base AS runner

ARG NODE_ENV
WORKDIR /app

RUN addgroup -g 1001 -S nodejs
RUN adduser -S nextjs -u 1001

COPY --from=builder /app/public ./public

COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs
EXPOSE 3000

CMD node server.js