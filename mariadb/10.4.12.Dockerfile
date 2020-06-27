FROM alpine:3.11
LABEL maintainer "collelog <collelog.cavamin@gmail.com>"

EXPOSE 3306

ADD ./files/run.sh /scripts/run.sh

RUN set -eux && \
	apk upgrade --update && \
	apk add --no-cache \
		mariadb=10.4.12-r0 \
		mariadb-client=10.4.12-r0 \
		mariadb-server-utils=10.4.12-r0 \
		pwgen \
		tzdata \
	&& \
	\
	# timezone
	cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && \
	echo "Asia/Tokyo" > /etc/timezone && \
	apk del tzdata && \
	\
	# cleaning
	rm -rf /tmp/* /var/cache/apk/* && \
	\
	mkdir /docker-entrypoint-initdb.d && \
	mkdir /scripts/pre-exec.d && \
	mkdir /scripts/pre-init.d && \
	chmod -R 755 /scripts

VOLUME /var/lib/mysql

ENTRYPOINT /scripts/run.sh
