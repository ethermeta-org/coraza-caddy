FROM golang:1.20-bullseye as builder

WORKDIR /caddy

COPY . .

RUN go install github.com/caddyserver/xcaddy/cmd/xcaddy@v0.3.5

RUN go run mage.go buildCaddyLinux


FROM debian:bullseye-slim

ARG TARGETPLATFORM

LABEL org.opencontainers.image.source=https://github.com/ethermeta-org/coraza-caddy \
    org.label-schema.arch=${TARGETPLATFORM}


RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        libcap2

RUN set -eux; \
	mkdir -p \
		/config/caddy \
		/data/caddy \
		/etc/caddy \
		/usr/share/caddy


COPY --from=builder /caddy/build/caddy-linux /usr/bin/caddy
COPY --from=builder /caddy/example/Caddyfile /etc/caddy/Caddyfile

ENV XDG_CONFIG_HOME /config
ENV XDG_DATA_HOME /data

CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]