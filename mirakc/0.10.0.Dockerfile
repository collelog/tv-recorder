# mirakc-arib, mirakc
FROM masnagam/mirakc:0.10.0-alpine AS mirakc-image


# libarib25, recpt1
FROM collelog/uo-recpt1-build:latest-alpine AS recpt1-image


# arib-b25-stream-test
FROM collelog/uo-arib-b25-stream-test-build:latest-alpine AS arib-b25-stream-test-image


# JST
FROM alpine:3.12.0 as jst-image
RUN apk add tzdata
RUN echo "Asia/Tokyo" > /etc/timezone


# final image
FROM alpine:3.12.0
LABEL maintainer "collelog <collelog.cavamin@gmail.com>"

EXPOSE 40772
ENV LD_LIBRARY_PATH=/usr/local/lib64
ENV MIRAKC_CONFIG=/etc/mirakc/config.yml

# mirakc-arib, mirakc
COPY --from=mirakc-image /usr/local/bin/mirakc /usr/local/bin/
COPY --from=mirakc-image /etc/mirakurun.openapi.json /etc/

# libarib25
COPY --from=recpt1-image /usr/local/include/arib25 /usr/local/include/arib25
COPY --from=recpt1-image /usr/local/bin/b25 /usr/local/bin/b25
COPY --from=recpt1-image /usr/local/lib64/libarib25.a /usr/local/lib64/libarib25.a
COPY --from=recpt1-image /usr/local/lib64/libarib25.so.0.2.5 /usr/local/lib64/libarib25.so.0.2.5
COPY --from=recpt1-image /usr/local/lib64/pkgconfig/libarib25.pc /usr/local/lib64/pkgconfig/libarib25.pc

# recpt1
COPY --from=recpt1-image /usr/local/bin/recpt1 /usr/local/bin/recpt1

# arib-b25-stream-test
COPY --from=arib-b25-stream-test-image /usr/local/arib-b25-stream-test /usr/local/arib-b25-stream-test

# JST
COPY --from=jst-image /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
COPY --from=jst-image /etc/timezone /etc/timezone

COPY ./services.sh /usr/local/bin

RUN set -eux && \
	apk upgrade --update && \
	apk add --no-cache ca-certificates ccid curl libstdc++ pcsc-lite pcsc-lite-libs socat && \
	\
	# libarib25
	ln -sf /usr/local/lib64/libarib25.so.0.2.5 /usr/local/lib64/libarib25.so.0 && \
	ln -sf /usr/local/lib64/libarib25.so.0 /usr/local/lib64/libarib25.so && \
	\
	# arib-b25-stream-test
	ln -sf /usr/local/arib-b25-stream-test/bin/b25 /usr/local/bin/arib-b25-stream-test && \
	\
	# cleaning
	rm -rf /tmp/* /var/cache/apk/* && \
	\
	chmod 755 /usr/local/bin/services.sh

VOLUME /var/lib/mirakc/epg

ENTRYPOINT /usr/local/bin/services.sh
