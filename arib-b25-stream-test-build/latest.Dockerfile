# arib-b25-stream-test
FROM node:12-alpine3.11 AS arib-b25-stream-test-build

RUN set -eux
RUN apk upgrade --update
RUN apk add --no-cache gcc g++ make libc-dev pcsc-lite-dev pkgconfig nodejs npm

RUN npm install arib-b25-stream-test -g --unsafe
RUN rm -rf /tmp/* /var/cache/apk/*



# final image
FROM alpine:3.11
LABEL maintainer "collelog <collelog.cavamin@gmail.com>"

COPY --from=arib-b25-stream-test-build /usr/local/lib/node_modules/arib-b25-stream-test /usr/local/arib-b25-stream-test
