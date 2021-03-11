#syntax = docker/dockerfile:1.2

FROM rust:1.50-slim-buster AS rust-builder
WORKDIR /app
COPY . .
RUN \
  --mount=type=cache,target=/app/target/ \
  --mount=type=cache,target=/usr/local/cargo/registry/index \
  --mount=type=cache,target=/usr/local/cargo/registry/cache \
  cargo build --release --locked \
  && mkdir -p dist \
  && (find target/release -type f -maxdepth 1 | xargs -I{} mv {} dist) \
  && rm -rf dist/*.d \
  && ls -al dist

FROM debian:buster-slim AS app
WORKDIR /usr/local/bin
COPY --from=rust-builder /app/dist/* ./
CMD ["mount_type_cache_sandbox"]
