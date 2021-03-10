#syntax = docker/dockerfile:1.2

FROM rust:1.50-slim-buster AS rust-builder
WORKDIR /app
COPY . .
RUN \
  --mount=type=cache,target=/app/target \
  --mount=type=cache,target=/usr/local/cargo/registry \
  cargo build --release \
  && cp -R target/release dist \
  && rm -rf \
  dist/.fingerprint \
  dist/deps \
  dist/build \
  dist/examples \
  dist/incremental \
  dist/*.d

FROM debian:buster-slim AS app
WORKDIR /usr/local/bin
COPY --from=rust-builder /app/dist/* ./
CMD ["mount_type_cache_sandbox"]
