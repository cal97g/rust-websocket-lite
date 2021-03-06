FROM ubuntu:bionic-20191010 as deps

RUN apt-get -y update

RUN apt-get -y install \
    clang \
    curl \
    libssl-dev \
    pkg-config

WORKDIR /build
COPY rust-toolchain .
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y --profile minimal --default-toolchain $(cat rust-toolchain)
ENV PATH=$PATH:/root/.cargo/bin
RUN rustup component add clippy

FROM deps as build

COPY Cargo.toml Cargo.lock ./
COPY websocket-codec/Cargo.toml websocket-codec/
COPY websocket-lite/Cargo.toml websocket-lite/
RUN cargo fetch

COPY . .
RUN cargo test --release
RUN cargo build --release
RUN cargo clippy --release

FROM ubuntu:bionic-20191010 as app

RUN apt-get -y update

RUN apt-get -y install \
    ca-certificates \
    netcat \
    openssl

WORKDIR /app

COPY --from=build \
    /build/target/release/examples/async-autobahn-client \
    /build/target/release/examples/autobahn-client \
    /build/target/release/examples/hello-world-client \
    /build/target/release/examples/wsdump \
    ./
