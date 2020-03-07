# arib-b25-stream-test
FROM node:12-alpine3.11 AS arib-b25-stream-test-build

RUN apk upgrade --update
RUN apk add --no-cache gcc g++ make libc-dev pcsc-lite-dev pkgconfig

RUN npm install arib-b25-stream-test -g --unsafe


# final image
FROM masnagam/mirakc:master-alpine-amd64
LABEL maintainer "collelog <collelog.cavamin@gmail.com>"

EXPOSE 40772
ENV MIRAKC_CONFIG=/etc/mirakc/config.yml

# arib-b25-stream-test
COPY --from=arib-b25-stream-test-build /usr/local/lib/node_modules/arib-b25-stream-test /usr/local/arib-b25-stream-test

RUN set -eux && \
	apk upgrade --update && \
	apk add --no-cache ccid pcsc-lite pcsc-lite-libs && \
	\
	# timezone
	cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && \
	echo "Asia/Tokyo" > /etc/timezone && \
	apk del tzdata && \
	\
	# arib-b25-stream-test
	ln -sf /usr/local/arib-b25-stream-test/bin/b25 /usr/local/bin/arib-b25-stream-test && \
	\
	# cleaning
	rm -rf /tmp/* /var/cache/apk/*

COPY ./services.sh /usr/local/bin

VOLUME /var/lib/mirakc/epg

ENTRYPOINT /usr/local/bin/services.sh
