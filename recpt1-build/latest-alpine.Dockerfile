# libarib25, recpt1
FROM alpine:3.12 AS recpt1-build

RUN set -eux
RUN apk upgrade --update
RUN apk add --no-cache ca-certificates curl git gcc g++ make cmake autoconf automake pcsc-lite-dev

RUN mkdir -p /build/libarib25
WORKDIR /build/libarib25
RUN curl -fsSL https://github.com/stz2012/libarib25/tarball/master \
	| tar -xz --strip-components=1
RUN cmake .
RUN make install

WORKDIR /build
RUN curl -fsSL https://github.com/stz2012/recpt1/tarball/master \
	| tar -xz --strip-components=1
WORKDIR /build/recpt1
RUN ./autogen.sh
RUN ./configure --prefix=/usr/local --enable-b25
RUN make -j $(nproc)
RUN make install
RUN rm -rf /tmp/* /var/cache/apk/*



# final image
FROM alpine:3.12
LABEL maintainer "collelog <collelog.cavamin@gmail.com>"

# libarib25
COPY --from=recpt1-build /usr/local/include/arib25 /usr/local/include/arib25
COPY --from=recpt1-build /usr/local/bin/b25 /usr/local/bin/b25
COPY --from=recpt1-build /usr/local/lib64/libarib25.a /usr/local/lib64/libarib25.a
COPY --from=recpt1-build /usr/local/lib64/libarib25.so.0.2.5 /usr/local/lib64/libarib25.so.0.2.5
COPY --from=recpt1-build /usr/local/lib64/pkgconfig/libarib25.pc /usr/local/lib64/pkgconfig/libarib25.pc

# recpt1
COPY --from=recpt1-build /usr/local/bin/recpt1 /usr/local/bin/recpt1
