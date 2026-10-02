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

# Build all packages and apps (API & Client)
RUN pnpm turbo run build

# Start both API and Client concurrently from the root directory
CMD ["pnpm", "run", "start"]
