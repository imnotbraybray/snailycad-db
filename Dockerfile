FROM node:20-slim AS base
WORKDIR /snailycad

RUN apt-get update -y && apt-get install -y ca-certificates openssl
RUN npm install -g pnpm@9 && pnpm config set httpTimeout 1200000

COPY . .
FROM base AS deps
RUN pnpm install --no-frozen-lockfile

FROM deps AS build
ENV NODE_ENV="production"
RUN pnpm turbo run build --filter="{packages/*}"

# --- BACKEND API TARGET ---
FROM build AS api
ENV NODE_ENV="production"
WORKDIR /snailycad/apps/api
RUN pnpm run build
CMD ["pnpm", "start"]

# --- FRONTEND CLIENT TARGET ---
FROM build AS client
ENV NODE_ENV="production"
WORKDIR /snailycad/apps/client
RUN rm -rf /snailycad/apps/client/.next
RUN pnpm create-images-domain

ARG NEXT_PUBLIC_CLIENT_URL
ARG NEXT_PUBLIC_PROD_ORIGIN
ENV NEXT_PUBLIC_CLIENT_URL=$NEXT_PUBLIC_CLIENT_URL
ENV NEXT_PUBLIC_PROD_ORIGIN=$NEXT_PUBLIC_PROD_ORIGIN

RUN pnpm run build
CMD ["sh", "-c", "HOSTNAME=0.0.0.0 pnpm start"]
