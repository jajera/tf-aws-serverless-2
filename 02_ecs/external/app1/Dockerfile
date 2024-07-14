# Stage 1: Build the application
FROM rust:latest AS builder

RUN rustup target add x86_64-unknown-linux-musl
RUN apt-get update && apt-get install -y \
    musl-tools \
    musl-dev

WORKDIR /app

COPY . .

RUN cargo build --target x86_64-unknown-linux-musl --release

# Stage 2: Create a minimal runtime image
FROM alpine:latest

RUN apk add --no-cache curl

WORKDIR /app

COPY --from=builder /app/target/x86_64-unknown-linux-musl/release/rust-actix-web ./

HEALTHCHECK --interval=30s --timeout=5s --retries=3 CMD curl -f http://localhost:8080 || exit 1

RUN adduser -D appuser

USER appuser

EXPOSE 8080

ENTRYPOINT [ "/app/rust-actix-web" ]