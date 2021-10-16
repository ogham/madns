# This Dockerfile lets you run madns without needing the development tools
# installed on your machine. It downloads and compiles a copy of Hexit, then
# copies the resulting binary into a Ruby container with the server and the
# samples in it.


# ---- the build stage ----

FROM rust:1.55-slim-buster AS build

WORKDIR /hexit
RUN apt-get update && apt-get install -y git \
 && git clone https://github.com/ogham/hexit.git --depth 1 . \
 && git reset --hard 8db393291503445ebf6fa71af856183da9704c3e

RUN cargo build --release
# Once Hexit gets a stable release, we should just be able to download a
# binary into the ruby image rather than compiling a copy afresh


# ---- the running stage ----

FROM ruby:3.0-slim-buster

RUN useradd -ms /bin/bash executor

WORKDIR /madns
COPY --from=build /hexit/target/release/hexit /usr/local/bin/hexit
COPY server server
COPY samples samples

EXPOSE 5301
USER executor

ENTRYPOINT ["./server/madns.rb", "--dir", "./samples", "--bind", "0.0.0.0", "--port", "5301"]
CMD ["--udp"]
