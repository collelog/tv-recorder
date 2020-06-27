# base
FROM amd64/alpine:3.12 AS base

RUN set -eux
RUN apk upgrade --update
RUN apk add --no-cache --update \
	libgcc \
	libstdc++ \
	ca-certificates \
	libcrypto1.1 \
	libssl1.1 \
	libgomp \
	expat \
	libzmq \
	util-linux \
	libva \
	libva-intel-driver


# FFmpeg
FROM base AS ffmpeg-build
WORKDIR /tmp/workdir

ENV FFMPEG_VERSION=4.3 \
	AOM_VERSION=v2.0.0 \
	FDKAAC_VERSION=2.0.1 \
	FONTCONFIG_VERSION=2.13.1 \
	FREETYPE_VERSION=2.10.2 \
	FRIBIDI_VERSION=1.0.9 \
	KVAZAAR_VERSION=2.0.0 \
	LAME_VERSION=3.100 \
	LIBASS_VERSION=0.14.0 \
	LIBPTHREAD_STUBS_VERSION=0.4 \
	LIBVIDSTAB_VERSION=1.1.0 \
	LIBXCB_VERSION=1.14 \
	XCBPROTO_VERSION=1.14 \
	OGG_VERSION=1.3.4 \
	OPENCOREAMR_VERSION=0.1.5 \
	OPUS_VERSION=1.3.1 \
	OPENJPEG_VERSION=2.3.1 \
	THEORA_VERSION=1.1.1 \
	VORBIS_VERSION=1.3.6 \
	VPX_VERSION=1.8.2 \
	WEBP_VERSION=1.1.0 \
	X265_VERSION=3.2.1 \
	XAU_VERSION=1.0.9 \
	XORG_MACROS_VERSION=1.19.2 \
	XPROTO_VERSION=7.0.31 \
	XVID_VERSION=1.3.5 \
	LIBXML2_VERSION=2.9.10 \
	LIBBLURAY_VERSION=1.2.0 \
#	LIBZMQ_VERSION=4.3.2 \
	LIBSRT_VERSION=1.4.1 \
	LIBPNG_VERSION=1.6.37

ENV LD_LIBRARY_PATH=/opt/ffmpeg/lib:/opt/ffmpeg/lib64:/usr/lib:/usr/local/lib:/lib
ENV PKG_CONFIG_PATH=/opt/ffmpeg/share/pkgconfig:/opt/ffmpeg/lib/pkgconfig:/opt/ffmpeg/lib64/pkgconfig:/usr/local/lib/pkgconfig
ENV SRC=/usr/local
ENV PREFIX=/opt/ffmpeg

#ENV MAKEFLAGS=-j14

RUN set -eux
RUN apk add --no-cache \
	autoconf \
	automake \
	bash \
	binutils \
	bzip2 \
	cmake \
	curl \
	coreutils \
	diffutils \
	file \
	g++ \
	gcc \
	git \
	gperf \
	libtool \
	make \
	python3 \
	openssl-dev \
	tar \
	util-linux-dev \
	yasm \
	nasm \
	zlib-dev \
	expat-dev \
	zeromq-dev \
	libva-dev

## opencore-amr https://sourceforge.net/projects/opencore-amr/
RUN \
	DIR=/tmp/opencore-amr && \
	mkdir -p ${DIR} && \
	cd ${DIR} && \
	curl -fsSL https://versaweb.dl.sourceforge.net/project/opencore-amr/opencore-amr/opencore-amr-${OPENCOREAMR_VERSION}.tar.gz | \
		tar -zx --strip-components=1 && \
	./configure --prefix="${PREFIX}" --enable-shared  && \
	make && \
	make install && \
	rm -rf ${DIR}

## x264 http://www.videolan.org/developers/x264.html
RUN \
	DIR=/tmp/x264 && \
	mkdir -p ${DIR} && \
	cd ${DIR} && \
	curl -fsSL https://code.videolan.org/videolan/x264/-/archive/stable/x264-stable.tar.gz | \
		tar -xz --strip-components=1 && \
	./configure --prefix="${PREFIX}" --enable-shared --enable-pic --disable-cli && \
	make && \
	make install && \
	rm -rf ${DIR}

### x265 http://x265.org/
RUN \
	DIR=/tmp/x265 && \
	mkdir -p ${DIR} && \
	cd ${DIR} && \
	curl -fsSL https://download.videolan.org/pub/videolan/x265/x265_${X265_VERSION}.tar.gz | \
		tar -zx && \
	cd x265_${X265_VERSION}/build/linux && \
	sed -i "/-DEXTRA_LIB/ s/$/ -DCMAKE_INSTALL_PREFIX=\${PREFIX}/" multilib.sh && \
	sed -i "/^cmake/ s/$/ -DENABLE_CLI=OFF/" multilib.sh && \
	./multilib.sh && \
	make -C 8bit install && \
	rm -rf ${DIR}

### libogg https://www.xiph.org/ogg/
RUN \
	DIR=/tmp/ogg && \
	mkdir -p ${DIR} && \
	cd ${DIR} && \
	curl -fsSL http://downloads.xiph.org/releases/ogg/libogg-${OGG_VERSION}.tar.gz | \
		tar -zx --strip-components=1 && \
	./configure --prefix="${PREFIX}" --enable-shared  && \
	make && \
	make install && \
	rm -rf ${DIR}

### libopus https://www.opus-codec.org/
RUN \
	DIR=/tmp/opus && \
	mkdir -p ${DIR} && \
	cd ${DIR} && \
	curl -fsSL https://archive.mozilla.org/pub/opus/opus-${OPUS_VERSION}.tar.gz | \
		tar -zx --strip-components=1 && \
	autoreconf -fiv && \
	./configure --prefix="${PREFIX}" --enable-shared && \
	make && \
	make install && \
	rm -rf ${DIR}

### libvorbis https://xiph.org/vorbis/
RUN \
	DIR=/tmp/vorbis && \
	mkdir -p ${DIR} && \
	cd ${DIR} && \
	curl -fsSL http://downloads.xiph.org/releases/vorbis/libvorbis-${VORBIS_VERSION}.tar.gz | \
		tar -zx --strip-components=1 && \
	./configure --prefix="${PREFIX}" --with-ogg="${PREFIX}" --enable-shared && \
	make && \
	make install && \
	rm -rf ${DIR}

### libtheora http://www.theora.org/
RUN \
	DIR=/tmp/theora && \
	mkdir -p ${DIR} && \
	cd ${DIR} && \
	curl -fsSL http://downloads.xiph.org/releases/theora/libtheora-${THEORA_VERSION}.tar.gz | \
		tar -zx --strip-components=1 && \
	./configure --prefix="${PREFIX}" --with-ogg="${PREFIX}" --enable-shared && \
	make && \
	make install && \
	rm -rf ${DIR}

### libvpx https://www.webmproject.org/code/
RUN \
	DIR=/tmp/vpx && \
	mkdir -p ${DIR} && \
	cd ${DIR} && \
	curl -fsSL https://codeload.github.com/webmproject/libvpx/tar.gz/v${VPX_VERSION} | \
		tar -zx --strip-components=1 && \
	./configure --prefix="${PREFIX}" --enable-vp8 --enable-vp9 --enable-vp9-highbitdepth --enable-pic --enable-shared \
	--disable-debug --disable-examples --disable-docs --disable-install-bins  && \
	make && \
	make install && \
	rm -rf ${DIR}

### libwebp https://developers.google.com/speed/webp/
RUN \
	DIR=/tmp/vebp && \
	mkdir -p ${DIR} && \
	cd ${DIR} && \
	curl -fsSL https://storage.googleapis.com/downloads.webmproject.org/releases/webp/libwebp-${WEBP_VERSION}.tar.gz | \
		tar -zx --strip-components=1 && \
	./configure --prefix="${PREFIX}" --enable-shared  && \
	make && \
	make install && \
	rm -rf ${DIR}

### libmp3lame http://lame.sourceforge.net/
RUN \
	DIR=/tmp/lame && \
	mkdir -p ${DIR} && \
	cd ${DIR} && \
	curl -fsSL https://versaweb.dl.sourceforge.net/project/lame/lame/$(echo ${LAME_VERSION} | sed -e 's/[^0-9]*\([0-9]*\)[.]\([0-9]*\)[.]\([0-9]*\)\([0-9A-Za-z-]*\)/\1.\2/')/lame-${LAME_VERSION}.tar.gz | \
		tar -zx --strip-components=1 && \
	./configure --prefix="${PREFIX}" --bindir="${PREFIX}/bin" --enable-shared --enable-nasm --disable-frontend && \
	make && \
	make install && \
	rm -rf ${DIR}

### xvid https://www.xvid.com/
RUN \
	DIR=/tmp/xvid && \
	mkdir -p ${DIR} && \
	cd ${DIR} && \
	curl -fsSL http://downloads.xvid.org/downloads/xvidcore-${XVID_VERSION}.tar.gz | \
		tar -zx && \
	cd xvidcore/build/generic && \
	./configure --prefix="${PREFIX}" --bindir="${PREFIX}/bin" && \
	make && \
	make install && \
	rm -rf ${DIR}

### fdk-aac https://github.com/mstorsjo/fdk-aac
RUN \
	DIR=/tmp/fdk-aac && \
	mkdir -p ${DIR} && \
	cd ${DIR} && \
	curl -fsSL https://github.com/mstorsjo/fdk-aac/archive/v${FDKAAC_VERSION}.tar.gz | \
		tar -zx --strip-components=1 && \
	autoreconf -fiv && \
	./configure --prefix="${PREFIX}" --enable-shared --datadir="${DIR}" && \
	make && \
	make install && \
	rm -rf ${DIR}

## libpng https://github.com/glennrp/libpng
RUN \
	DIR=/tmp/libpng && \
	mkdir -p ${DIR} && \
	cd ${DIR} && \
	curl -fsSL https://github.com/glennrp/libpng/archive/v${LIBPNG_VERSION}.tar.gz | \
		tar -xz --strip-components=1 && \
	./configure --prefix="${PREFIX}" && \
	make && \
	make install && \
	rm -rf ${DIR}

## openjpeg https://github.com/uclouvain/openjpeg
RUN \
	DIR=/tmp/openjpeg && \
	mkdir -p ${DIR} && \
	cd ${DIR} && \
	curl -fsSL https://github.com/uclouvain/openjpeg/archive/v${OPENJPEG_VERSION}.tar.gz | \
		tar -zx --strip-components=1 && \
	cmake -DBUILD_THIRDPARTY:BOOL=ON -DCMAKE_INSTALL_PREFIX="${PREFIX}" . && \
	make && \
	make install && \
	rm -rf ${DIR}

## freetype https://www.freetype.org/
RUN  \
	DIR=/tmp/freetype && \
	mkdir -p ${DIR} && \
	cd ${DIR} && \
	curl -fsSL https://download.savannah.gnu.org/releases/freetype/freetype-${FREETYPE_VERSION}.tar.gz | \
		tar -zx --strip-components=1 && \
	./configure --prefix="${PREFIX}" --disable-static --enable-shared && \
	make && \
	make install && \
	rm -rf ${DIR}

## libvstab https://github.com/georgmartius/vid.stab
RUN  \
	DIR=/tmp/vid.stab && \
	mkdir -p ${DIR} && \
	cd ${DIR} && \
	curl -fsSL https://github.com/georgmartius/vid.stab/archive/v${LIBVIDSTAB_VERSION}.tar.gz | \
		tar -zx --strip-components=1 && \
	cmake -DCMAKE_INSTALL_PREFIX="${PREFIX}" . && \
	make && \
	make install && \
	rm -rf ${DIR}

## fridibi https://www.fribidi.org/
RUN  \
	DIR=/tmp/fribidi && \
	mkdir -p ${DIR} && \
	cd ${DIR} && \
	curl -fsSL https://github.com/fribidi/fribidi/archive/v${FRIBIDI_VERSION}.tar.gz | \
		tar -zx --strip-components=1 && \
	sed -i 's/^SUBDIRS =.*/SUBDIRS=gen.tab lib bin/' Makefile.am && \
	./autogen.sh && \
	./configure --prefix="${PREFIX}" --disable-static --enable-shared && \
	make && \
	make install && \
	rm -rf ${DIR}

## fontconfig https://www.freedesktop.org/wiki/Software/fontconfig/
RUN  \
	DIR=/tmp/fontconfig && \
	mkdir -p ${DIR} && \
	cd ${DIR} && \
	curl -fsSL https://www.freedesktop.org/software/fontconfig/release/fontconfig-${FONTCONFIG_VERSION}.tar.bz2 | \
		tar -jx --strip-components=1 && \
	./configure --prefix="${PREFIX}" --disable-static --enable-shared && \
	make && \
	make install && \
	rm -rf ${DIR}

## libass https://github.com/libass/libass
RUN  \
	DIR=/tmp/libass && \
	mkdir -p ${DIR} && \
	cd ${DIR} && \
	curl -fsSL https://github.com/libass/libass/archive/${LIBASS_VERSION}.tar.gz | \
		tar -zx --strip-components=1 && \
	./autogen.sh && \
	./configure --prefix="${PREFIX}" --disable-static --enable-shared && \
	make && \
	make install && \
	rm -rf ${DIR}

## kvazaar https://github.com/ultravideo/kvazaar
RUN \
	DIR=/tmp/kvazaar && \
	mkdir -p ${DIR} && \
	cd ${DIR} && \
	curl -fsSL https://github.com/ultravideo/kvazaar/archive/v${KVAZAAR_VERSION}.tar.gz | \
		tar -zx --strip-components=1 && \
	./autogen.sh && \
	./configure --prefix="${PREFIX}" --disable-static --enable-shared && \
	make && \
	make install && \
	rm -rf ${DIR}

RUN \
	DIR=/tmp/aom && \
	git clone --branch ${AOM_VERSION} --depth 1 https://aomedia.googlesource.com/aom ${DIR} ; \
	cd ${DIR} ; \
	rm -rf CMakeCache.txt CMakeFiles ; \
	mkdir -p ./aom_build ; \
	cd ./aom_build ; \
	cmake -DCMAKE_INSTALL_PREFIX="${PREFIX}" -DBUILD_SHARED_LIBS=1 ..; \
	make ; \
	make install ; \
	rm -rf ${DIR}

## libxcb (and supporting libraries) for screen capture https://xcb.freedesktop.org/
RUN \
	DIR=/tmp/xorg-macros && \
	mkdir -p ${DIR} && \
	cd ${DIR} && \
	curl -fsSL https://www.x.org/archive//individual/util/util-macros-${XORG_MACROS_VERSION}.tar.gz | \
		tar -zx --strip-components=1 && \
	./configure --srcdir=${DIR} --prefix="${PREFIX}" && \
	make && \
	make install && \
	rm -rf ${DIR}

RUN \
	DIR=/tmp/xproto && \
	mkdir -p ${DIR} && \
	cd ${DIR} && \
	curl -fsSL https://www.x.org/archive/individual/proto/xproto-${XPROTO_VERSION}.tar.gz | \
		tar -zx --strip-components=1 && \
	./configure --srcdir=${DIR} --prefix="${PREFIX}" && \
	make && \
	make install && \
	rm -rf ${DIR}

RUN \
	DIR=/tmp/libXau && \
	mkdir -p ${DIR} && \
	cd ${DIR} && \
	curl -fsSL https://www.x.org/archive/individual/lib/libXau-${XAU_VERSION}.tar.gz | \
		tar -zx --strip-components=1 && \
	./configure --srcdir=${DIR} --prefix="${PREFIX}" && \
	make && \
	make install && \
	rm -rf ${DIR}

RUN \
	DIR=/tmp/libpthread-stubs && \
	mkdir -p ${DIR} && \
	cd ${DIR} && \
	curl -fsSL https://xcb.freedesktop.org/dist/libpthread-stubs-${LIBPTHREAD_STUBS_VERSION}.tar.gz | \
		tar -zx --strip-components=1 && \
	./configure --prefix="${PREFIX}" && \
	make && \
	make install && \
	rm -rf ${DIR}

RUN \
	DIR=/tmp/libxcb-proto && \
	mkdir -p ${DIR} && \
	cd ${DIR} && \
	curl -fsSL https://xcb.freedesktop.org/dist/xcb-proto-${XCBPROTO_VERSION}.tar.gz | \
		tar -zx --strip-components=1 && \
	ACLOCAL_PATH="${PREFIX}/share/aclocal" ./autogen.sh && \
	./configure --prefix="${PREFIX}" && \
	make && \
	make install && \
	rm -rf ${DIR}

RUN \
	DIR=/tmp/libxcb && \
	mkdir -p ${DIR} && \
	cd ${DIR} && \
	curl -fsSL https://xcb.freedesktop.org/dist/libxcb-${LIBXCB_VERSION}.tar.gz | \
		tar -zx --strip-components=1 && \
	ACLOCAL_PATH="${PREFIX}/share/aclocal" ./autogen.sh && \
	./configure --prefix="${PREFIX}" --disable-static --enable-shared && \
	make && \
	make install && \
	rm -rf ${DIR}

## libxml2 - for libbluray
RUN \
	DIR=/tmp/libxml2 && \
	mkdir -p ${DIR} && \
	cd ${DIR} && \
	curl -fsSL https://gitlab.gnome.org/GNOME/libxml2/-/archive/v${LIBXML2_VERSION}/libxml2-v${LIBXML2_VERSION}.tar.gz | \
		tar -xz --strip-components=1 && \
	./autogen.sh --prefix="${PREFIX}" --with-ftp=no --with-http=no --with-python=no && \
	make && \
	make install && \
	rm -rf ${DIR}

## libbluray - Requires libxml, freetype, and fontconfig
RUN \
	DIR=/tmp/libbluray && \
	mkdir -p ${DIR} && \
	cd ${DIR} && \
	curl -fsSL https://download.videolan.org/pub/videolan/libbluray/${LIBBLURAY_VERSION}/libbluray-${LIBBLURAY_VERSION}.tar.bz2 | \
		tar -jx --strip-components=1 && \
	./configure --prefix="${PREFIX}" --disable-examples --disable-bdjava-jar --disable-static --enable-shared && \
	make && \
	make install && \
	rm -rf ${DIR}

## libzmq https://github.com/zeromq/libzmq/
#	DIR=/tmp/libzmq && \
#	mkdir -p ${DIR} && \
#	cd ${DIR} && \
#	curl -fsSL https://github.com/zeromq/libzmq/archive/v${LIBZMQ_VERSION}.tar.gz | \
##	curl -fsSL https://github.com/zeromq/libzmq/tarball/master | \
#		tar -xz --strip-components=1 && \
#	./autogen.sh && \
#	./configure --prefix="${PREFIX}" && \
#	make && \
#	make check && \
#	make install && \
#	rm -rf ${DIR}

## libsrt https://github.com/Haivision/srt
RUN \
	DIR=/tmp/srt && \
	mkdir -p ${DIR} && \
	cd ${DIR} && \
	curl -fsSL https://github.com/Haivision/srt/archive/v${LIBSRT_VERSION}.tar.gz | \
		tar -xz --strip-components=1 && \
	cmake -DCMAKE_INSTALL_PREFIX="${PREFIX}" . && \
	make && \
	make install && \
	rm -rf ${DIR}

## libaribb24 https://github.com/nkoriyama/aribb24/
RUN \
	DIR=/tmp/aribb24 && \
	mkdir -p ${DIR} && \
	cd ${DIR} && \
	curl -fsSL https://github.com/nkoriyama/aribb24/tarball/master | \
		tar -xz --strip-components=1 && \
	autoreconf -fiv && \
	./configure --prefix="${PREFIX}" && \
	make && \
	make install && \
	rm -rf ${DIR}

## AviSynth+ https://github.com/AviSynth/AviSynthPlus
RUN \
	DIR=/tmp/AviSynthPlus && \
	mkdir -p ${DIR} && \
	cd ${DIR} && \
	curl -fsSL https://github.com/AviSynth/AviSynthPlus/tarball/master | \
		tar -xz --strip-components=1 && \
	mkdir avisynth-build && cd avisynth-build && \
	cmake ../ -DHEADERS_ONLY:bool=on && \
	make install && \
	rm -rf ${DIR}

## ffmpeg https://ffmpeg.org/
RUN  \
	DIR=/tmp/ffmpeg && mkdir -p ${DIR} && cd ${DIR} && \
	curl -fsSL https://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.bz2 | \
		tar -jx --strip-components=1

RUN \
	DIR=/tmp/ffmpeg && cd ${DIR} && \
	./configure \
		--disable-debug \
		--disable-doc \
		--disable-ffplay \
		--enable-shared \
		--enable-avresample \
		--enable-libopencore-amrnb \
		--enable-libopencore-amrwb \
		--enable-gpl \
		--enable-libass \
		--enable-fontconfig \
		--enable-libfreetype \
		--enable-libvidstab \
		--enable-libmp3lame \
		--enable-libopus \
		--enable-libtheora \
		--enable-libvorbis \
		--enable-libvpx \
		--enable-libwebp \
		--enable-libxcb \
		--enable-libx265 \
		--enable-libxvid \
		--enable-libx264 \
		--enable-nonfree \
		--enable-openssl \
		--enable-libfdk_aac \
		--enable-postproc \
		--enable-small \
		--enable-version3 \
		--enable-libbluray \
		--enable-libzmq \
		--extra-libs=-ldl \
		--prefix="${PREFIX}" \
		--enable-libopenjpeg \
		--enable-libkvazaar \
		--enable-libaom \
		--extra-libs=-lpthread \
		--enable-libsrt \
		--enable-libaribb24 \
		--enable-avisynth \
		--enable-vaapi \
		--extra-cflags="-I${PREFIX}/include" \
		--extra-ldflags="-L${PREFIX}/lib" && \
	make && \
	make install && \
	make tools/zmqsend && cp tools/zmqsend ${PREFIX}/bin/ && \
	make distclean && \
	hash -r && \
	cd tools && \
	make qt-faststart && cp qt-faststart ${PREFIX}/bin/

RUN \
	ldd ${PREFIX}/bin/ffmpeg | grep opt/ffmpeg | cut -d ' ' -f 3 | xargs -i cp {} /usr/local/lib/ && \
	for lib in /usr/local/lib/*.so.*; do ln -s "${lib##*/}" "${lib%%.so.*}".so; done && \
	cp ${PREFIX}/bin/* /usr/local/bin/ && \
	cp -r ${PREFIX}/share/ffmpeg /usr/local/share/ && \
	LD_LIBRARY_PATH=/usr/local/lib ffmpeg -buildconf && \
	mkdir -p /usr/local/include && \
	cp -r ${PREFIX}/include/libav* ${PREFIX}/include/libpostproc ${PREFIX}/include/libsw* /usr/local/include && \
	mkdir -p /usr/local/lib/pkgconfig && \
	for pc in ${PREFIX}/lib/pkgconfig/libav*.pc ${PREFIX}/lib/pkgconfig/libpostproc.pc ${PREFIX}/lib/pkgconfig/libsw*.pc; do \
		sed "s:${PREFIX}:/usr/local:g" <"$pc" >/usr/local/lib/pkgconfig/"${pc##*/}"; \
	done

RUN rm -rf /tmp/* /var/cache/apk/*


# final image
FROM base AS release
LABEL maintainer "collelog <collelog.cavamin@gmail.com>"

ENV LD_LIBRARY_PATH=/usr/local/lib:/usr/lib:/lib

CMD  ["--help"]
ENTRYPOINT  ["ffmpeg"]

COPY --from=ffmpeg-build /usr/local /usr/local