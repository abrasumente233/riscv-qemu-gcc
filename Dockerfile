# syntax = docker/dockerfile:1.4

FROM rust:1.61.0-slim-bullseye AS builder

WORKDIR /app
COPY fatfat .
RUN --mount=type=cache,target=/app/target \
		--mount=type=cache,target=/usr/local/cargo/registry \
		--mount=type=cache,target=/usr/local/cargo/git \
		--mount=type=cache,target=/usr/local/rustup \
		set -eux; \
		rustup install stable; \
	 	cargo build --release; \
		objcopy --compress-debug-sections target/release/fatfat ./fatfat

FROM ubuntu:20.04

RUN apt update
RUN apt install -y gcc-riscv64-unknown-elf
RUN apt install -y qemu-system-misc
RUN apt install -y python3
RUN apt install -y make
RUN apt install -y python3-pip
RUN apt install -y dosfstools
RUN python3 -m pip install pexpect

RUN mkdir /app

WORKDIR /app

COPY --from=builder /app/fatfat ./fatfat
CMD /bin/bash -c 'qemu-system-riscv64 --help'
#CMD make run
#CMD rm -f fs.img && make fs && python3 tester.py
