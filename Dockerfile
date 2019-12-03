FROM ubuntu:bionic-20191010

RUN apt-get -y update && \
    apt-get -y install \
    ca-certificates \
    clang \
    curl \
    libssl-dev \
    netcat \
    openssl \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build
COPY rust-toolchain .
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y --profile minimal --default-toolchain $(cat rust-toolchain)
ENV PATH=$PATH:/root/.cargo/bin

COPY Cargo.toml Cargo.lock ./
COPY websocket-codec/Cargo.toml websocket-codec/
COPY websocket-lite/Cargo.toml websocket-lite/
RUN cargo fetch

COPY . .
RUN cargo test --release
RUN cargo build --release

WORKDIR /app

RUN ln -s \
    /build/target/release/examples/async-autobahn-client \
    /build/target/release/examples/autobahn-client \
    /build/target/release/examples/hello-world-client \
    /build/target/release/examples/wsdump \
    ./
