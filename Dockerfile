FROM node:20-slim AS base
WORKDIR /snailycad

# Install SSL certificates & OpenSSL
RUN apt-get update -y && apt-get install -y ca-certificates openssl

# Install pnpm globally
RUN npm install -g pnpm@9 && pnpm config set httpTimeout 1200000

# Copy source code
COPY . .

# Install dependencies
RUN pnpm install --no-frozen-lockfile

# Pass Build Arguments for Next.js Frontend
ARG NEXT_PUBLIC_CLIENT_URL
ARG NEXT_PUBLIC_PROD_ORIGIN
ENV NEXT_PUBLIC_CLIENT_URL=$NEXT_PUBLIC_CLIENT_URL
ENV NEXT_PUBLIC_PROD_ORIGIN=$NEXT_PUBLIC_PROD_ORIGIN
ENV NODE_ENV="production"
ENV PORT="10000"
ENV PORT_API="8080"

# Build all packages and apps (API & Client)
RUN pnpm turbo run build

# Force HOSTNAME=0.0.0.0 at runtime so Next.js binds externally
CMD ["sh", "-c", "HOSTNAME=0.0.0.0 pnpm run start"]
