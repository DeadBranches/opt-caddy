ARG CADDY_VER=2.10
# STAGE 1 - Build caddy with Porkbun plugin
FROM caddy:${CADDY_VER}-builder-alpine AS builder

ENV GOMAXPROCS=1 GOMEMLIMIT=700MiB
RUN --mount=type=cache,target=/go/pkg/mod,sharing=locked \
    --mount=type=cache,target=/root/.cache/go-build,sharing=locked \
    xcaddy build \
    --with github.com/caddy-dns/porkbun

# STAGE 2 - Runtime image
FROM caddy:${CADDY_VER}-alpine

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
