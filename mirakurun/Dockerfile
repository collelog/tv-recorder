# recpt1
FROM alpine:3.11 AS recpt1-build

RUN set -eux
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
FROM node:12-alpine
LABEL maintainer "collelog <collelog.cavamin@gmail.com>"

EXPOSE 40772
ENV LD_LIBRARY_PATH=/usr/local/lib64
ENV DOCKER="YES"

# libarib25
COPY --from=recpt1-build /usr/local/include/arib25 /usr/local/include/arib25
COPY --from=recpt1-build /usr/local/bin/b25 /usr/local/bin/b25
COPY --from=recpt1-build /usr/local/lib64/libarib25.a /usr/local/lib64/libarib25.a
COPY --from=recpt1-build /usr/local/lib64/libarib25.so.0.2.5 /usr/local/lib64/libarib25.so.0.2.5
COPY --from=recpt1-build /usr/local/lib64/pkgconfig/libarib25.pc /usr/local/lib64/pkgconfig/libarib25.pc

# recpt1
COPY --from=recpt1-build /usr/local/bin/recpt1 /usr/local/bin/recpt1
COPY --from=recpt1-build /usr/local/bin/recpt1ctl /usr/local/bin/recpt1ctl
COPY --from=recpt1-build /usr/local/bin/checksignal /usr/local/bin/checksignal

RUN set -eux && \
	apk upgrade --update && \
	apk add --no-cache ccid libstdc++ pcsc-lite pcsc-lite-libs tzdata && \
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
	# pm2
	npm install pm2 -g && \
	\
	# arib-b25-stream-test
	npm install arib-b25-stream-test -g --unsafe && \
	\
	# mirakurun
	npm install mirakurun@latest -g --unsafe --production && \
	sed -i -e 's/--max_old_space_size=512/--max_old_space_size=1024/g' /usr/local/lib/node_modules/mirakurun/package.json && \
	\
	# cleaning
	npm cache verify && \
	rm -rf /tmp/* ~/.npm /var/cache/apk/*

COPY services.sh /usr/local/bin

WORKDIR /usr/local/lib/node_modules/mirakurun

ENTRYPOINT /usr/local/bin/services.sh
