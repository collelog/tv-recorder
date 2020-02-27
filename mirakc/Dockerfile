#Dockerfile for release

# Prepare a base image for each build stage in order to improve the build time.
#
# Executables will be linked against musl dynamically.
FROM rust:slim-buster AS buildenv

ENV DEBIAN_FRONTEND=noninteractive

# Use an old cross-compiler which is based on the same version of musl as
# alpine:3.11.
#
# The latest one is based on #241263 (2019-12-20) for time64 support.  On the
# other hand, alpine:3.11 supports musl/1.1.24 which doesn't support time64.
#
# * https://musl.cc/
# * https://pkgs.alpinelinux.org/packages?name=musl&branch=v3.11
#
#ARG MUSLCC_BASE_URL=https://more.musl.cc/9.2.1-20191012/x86_64-linux-musl

RUN apt-get update -qq
RUN apt-get install -y -qq --no-install-recommends autoconf automake ca-certificates cmake curl dos2unix git libtool make pkg-config

RUN apt-get install -y -qq --no-install-recommends ca-certificates curl rsync
RUN curl -fsSL https://more.musl.cc/9.2.1-20191012/x86_64-linux-musl/x86_64-linux-musl-cross.tgz \
    | tar -xz -C /tmp
RUN rm -f $(find /tmp/x86_64-linux-musl-cross -name "ld-musl-*.so.1")
RUN rm /tmp/x86_64-linux-musl-cross/usr
RUN rsync --ignore-errors -rLaq /tmp/x86_64-linux-musl-cross/* / || true
RUN rm -rf /tmp/x86_64-linux-musl-cross

RUN rustup target add x86_64-unknown-linux-musl

RUN mkdir -p /build
WORKDIR /build



# recpt1
FROM alpine:3.11 AS recpt1-build

RUN apk upgrade --update
RUN apk add --no-cache ca-certificates curl git gcc g++ make cmake autoconf automake pcsc-lite-dev

RUN mkdir -p /build
WORKDIR /build

RUN git clone https://github.com/stz2012/libarib25.git
WORKDIR /build/libarib25
RUN cmake .
RUN make install

WORKDIR /build
RUN curl -fsSL https://github.com/stz2012/recpt1/tarball/master \
    | tar -xz --strip-components=1
WORKDIR /build/recpt1

RUN sed -i -e '/"\/dev\/px4video5"/a ,"\/dev\/px4video8","\/dev\/px4video9","\/dev\/px4video12","\/dev\/px4video13"' pt1_dev.h
RUN sed -i -e '/"\/dev\/px4video7"/a ,"\/dev\/px4video10","\/dev\/px4video11","\/dev\/px4video14","\/dev\/px4video15"' pt1_dev.h

RUN ./autogen.sh
RUN ./configure --prefix=/usr/local --enable-b25
RUN make -j $(nproc)
RUN make install



# mirakc-arib
FROM buildenv AS mirakc-arib-build

RUN curl -fsSL https://github.com/masnagam/mirakc-arib/tarball/master \
    | tar -xz --strip-components=1
RUN echo 'set(CMAKE_SYSTEM_NAME Linux)' >toolchain.cmake
RUN echo 'set(CMAKE_SYSTEM_PROCESSOR arm)' >>toolchain.cmake
RUN echo 'set(MIRAKC_ARIB_HOST_TRIPLE x86_64-linux-musl)' >>toolchain.cmake
RUN echo 'set(CMAKE_C_COMPILER x86_64-linux-musl-gcc)' >>toolchain.cmake
RUN echo 'set(CMAKE_C_COMPILER_TARGET x86_64-linux-musl)' >>toolchain.cmake
RUN echo 'set(CMAKE_CXX_COMPILER x86_64-linux-musl-g++)' >>toolchain.cmake
RUN echo 'set(CMAKE_CXX_COMPILER_TARGET x86_64-linux-musl)' >>toolchain.cmake
RUN cmake -D CMAKE_BUILD_TYPE=Release -D CMAKE_TOOLCHAIN_FILE=toolchain.cmake
# See https://gist.github.com/uru2/cb3f7b553c2c58570ca9bf18e47cebb3
RUN CPPFLAGS='-Wno-error=zero-as-null-pointer-constant' make -j $(nproc) vendor
RUN make -j $(nproc)


# mirakc
FROM buildenv AS mirakc-build

# Enforce to use a specific compiler in the cc crate.
ENV CC='x86_64-linux-musl-gcc'

# Used for a workaround to fix the following issue:
# https://github.com/rust-lang/backtrace-rs/issues/249
ENV CFLAGS=''

# Use environment variables instead of creating .cargo/config:
# https://doc.rust-lang.org/cargo/reference/config.html
# https://github.com/japaric/rust-cross#cross-compiling-with-cargo
ENV CARGO_TARGET_X86_64_UNKNOWN_LINUX_MUSL_LINKER='x86_64-linux-musl-gcc'

# Used for a workaround to fix the following issue:
# https://github.com/rust-lang/compiler-builtins/issues/201
ENV CARGO_TARGET_X86_64_UNKNOWN_LINUX_MUSL_RUSTFLAGS=""

RUN curl -fsSL https://github.com/masnagam/mirakc/tarball/master \
	| tar -zx --strip-components=1

RUN cargo build -v --release --target x86_64-unknown-linux-musl
RUN cp /build/target/x86_64-unknown-linux-musl/release/mirakc /usr/local/bin/


# final image
FROM amd64/alpine:3.11
LABEL maintainer "collelog <collelog.cavamin@gmail.com>"

EXPOSE 40772
ENV LD_LIBRARY_PATH=/usr/local/lib64
ENV MIRAKC_CONFIG=/etc/mirakc/config.yml

# libarib25
COPY --from=recpt1-build /usr/local/include/arib25 /usr/local/include/arib25
COPY --from=recpt1-build /usr/local/bin/b25 /usr/local/bin/b25
COPY --from=recpt1-build /usr/local/lib64/libarib25.a /usr/local/lib64/libarib25.a
COPY --from=recpt1-build /usr/local/lib64/libarib25.so.0.2.5 /usr/local/lib64/libarib25.so.0.2.5
COPY --from=recpt1-build /usr/local/lib64/pkgconfig/libarib25.pc /usr/local/lib64/pkgconfig/libarib25.pc

# recpt1
COPY --from=recpt1-build /usr/local/bin/recpt1 /usr/local/bin/

# mirakc
COPY --from=mirakc-arib-build /build/bin/mirakc-arib /usr/local/bin/
COPY --from=mirakc-build /usr/local/bin/mirakc /usr/local/bin/
COPY ./mirakurun.openapi.json /etc/mirakurun.openapi.json

RUN set -eux && \
	apk upgrade --update && \
	apk add --no-cache ca-certificates curl ccid libstdc++ pcsc-lite pcsc-lite-libs tzdata && \
	\
	# timezone
	cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && \
	echo "Asia/Tokyo" > /etc/timezone && \
	apk del tzdata && \
	\
	# libarib25
	chmod -R 644 /usr/local/include/arib25 && \
	chmod -R 755 /usr/local/bin/b25 && \
	chmod -R 755 /usr/local/lib64/libarib25.a && \
	chmod -R 755 /usr/local/lib64/libarib25.so.0.2.5 && \
	chmod -R 755 /usr/local/lib64/pkgconfig/libarib25.pc && \
	ln -sf /usr/local/lib64/libarib25.so.0.2.5 /usr/local/lib64/libarib25.so.0 && \
	ln -sf /usr/local/lib64/libarib25.so.0 /usr/local/lib64/libarib25.so && \
	\
	# cleaning
	rm -rf /tmp/* /var/cache/apk/*

COPY services.sh /usr/local/bin

VOLUME /var/lib/mirakc/epg

ENTRYPOINT /usr/local/bin/services.sh
