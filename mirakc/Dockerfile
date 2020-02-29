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


# final image
FROM masnagam/mirakc:master-alpine-amd64
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

RUN set -eux && \
	apk upgrade --update && \
	apk add --no-cache ccid pcsc-lite pcsc-lite-libs && \
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
	rm /usr/local/bin/recdvb && \
	rm -rf /tmp/* /var/cache/apk/*

COPY ./services.sh /usr/local/bin

VOLUME /var/lib/mirakc/epg

ENTRYPOINT /usr/local/bin/services.sh
