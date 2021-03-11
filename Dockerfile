#syntax = docker/dockerfile:1.2

FROM rust:1.50-slim-buster AS rust-base
ENV CARGO_INCREMENTAL=0
ENV RUSTC_WRAPPER=/usr/local/bin/sccache
WORKDIR /tmp/sccache
ADD https://github.com/mozilla/sccache/releases/download/v0.2.15/sccache-v0.2.15-x86_64-unknown-linux-musl.tar.gz .
RUN tar xzf sccache-v0.2.15-x86_64-unknown-linux-musl.tar.gz --strip-components 1 \
  && chmod +x sccache \
  && mv sccache /usr/local/bin

FROM rust-base AS rust-builder
WORKDIR /app
COPY . .
RUN \
  --mount=type=cache,target=/root/.cache/sccache \
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
