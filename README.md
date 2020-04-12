# TV Recorder on Docker

> EPGStation version 1.6.x, MariaDB, mirakc (or Mirakurun) のDockerコンテナ  
  
Synology NAS(Intel CPUを採用したDockerパッケージ[適用機種](https://www.synology.com/ja-jp/dsm/packages/Docker))を想定し作成しましたが、x86-64プラットフォームのLinuxであれば動作します。


## Dockerコンテナ構成

### EPGStation ([collelog/uo-epgstation:1.6.7-alpine-amd64](https://hub.docker.com/r/collelog/uo-epgstation))
- [Alpine Linux 3.11](https://alpinelinux.org/)([alpine:3.11](https://hub.docker.com/_/alpine))
- [EPGStation](https://github.com/l3tnun/EPGStation)
  - version: 1.6.7 (commit e9a57bcdbdaee6edd7c276469bdfdd7e5c142f9a)
- [FFmpeg 4.2.2](https://www.ffmpeg.org/)

### MariaDB ([collelog/uo-epgstation-mariadb:10.4.12-alpine-amd64](https://hub.docker.com/r/collelog/uo-epgstation-mariadb))
- [Alpine Linux 3.11](https://alpinelinux.org/)([alpine:3.11](https://hub.docker.com/_/alpine))
- [MariaDB 10.4.12-r0](https://mariadb.org/)

### mirakc ([collelog/uo-mirakc:master-alpine-amd64](https://hub.docker.com/r/collelog/uo-mirakc))
- [Alpine Linux 3.11](https://alpinelinux.org/)([alpine:3.11](https://hub.docker.com/_/alpine))
- [mirakc](https://github.com/masnagam/mirakc)
  - branch: master

### Mirakurun (Optional) ([collelog/uo-mirakurun:2.14.0-alpine-amd64](https://hub.docker.com/r/collelog/uo-mirakurun))
- [Alpine Linux 3.11](https://alpinelinux.org/)([node:12-alpine](https://hub.docker.com/_/node/))
- [Mirakurun](https://github.com/Chinachu/Mirakurun)
  - version: 2.14.0

## 実行条件
- Linux x86-64プラットフォーム
- docker-compose.yml version 3.7 対応 Docker バージョンのインストール
  - Docker Engine version 18.06.0 and higher
  - docker-compose version 1.22.0 and higher
- pcscd の無効化
- [nns779/px4_drv](https://github.com/nns779/px4_drv) のインストール
- PLEX社製TVチューナー PX-W3U4/Q3U4/W3PE4/Q3PE4 のUSB接続
- B-CASカード/スマートカードリーダーのUSB接続


## 利用ソースコード
当ソースコードは以下のソースコード（docker-compose.yml,Dockerfile,その他動作に必要なファイル一式）を改変または参考に作成しています。

- **EPGStation** ([l3tnun/docker-mirakurun-epgstation](https://github.com/l3tnun/docker-mirakurun-epgstation))  
docker-mirakurun-epgstation
  - [MIT License](https://github.com/l3tnun/docker-mirakurun-epgstation/blob/master/LICENSE)

- **FFmpeg** ([alfg/docker-ffmpeg](https://github.com/alfg/docker-ffmpeg))  
docker-ffmpesg
  - [MIT License](https://github.com/alfg/docker-ffmpeg/blob/master/LICENSE)

- **MariaDB** ([yobasystems/alpine-mariadb](https://github.com/yobasystems/alpine-mariadb))  
MariaDB Docker image running on Alpine Linux

- **mirakc** ([masnagam/mirakc](https://github.com/masnagam/mirakc))  
A Mirakurun clone written in Rust
  - [Apache License, Version 2.0](https://github.com/masnagam/mirakc/blob/master/LICENSE-APACHE)  
    or
  - [MIT License](https://github.com/masnagam/mirakc/blob/master/LICENSE-MIT)

- **Mirakurun** ([Chinachu/docker-mirakurun-chinachu](https://github.com/Chinachu/docker-mirakurun-chinachu))  
docker-mirakurun-chinach  
  - [MIT License](https://github.com/Chinachu/docker-mirakurun-chinachu/blob/master/LICENSE)


### 主な機能
- **EPGStation Docker image**
  - Alpine Linux ベース
  - [FFmpeg 4.2.2](https://www.ffmpeg.org/)
  - MariaDB 連携：UNIXドメインソケット
  - MariaDB 文字コード：UTF8MB4、Collation：UTF8MB4_BIN
  - mirakc 連携：UNIXドメインソケット
  - 利用想定で不要なパッケージの整理

- **MariaDB Docker image**
  - サーバー 文字コード：UTF8MB4、Collation：UTF8MB4_BIN
  - EPGStation 向けDB作成（文字コード：UTF8MB4、Collation：UTF8MB4_BIN）
  - EPGStation 向けユーザー作成
  - [Grafana](https://grafana.com/) 向け読み取り専用ユーザー作成

- **mirakc Docker image**
  - [arib-b25-stream-test](https://www.npmjs.com/package/arib-b25-stream-test)
  - スマートカードリーダーの使用

- **Mirakurun Docker image**
  - [Node.js v12](https://nodejs.org/ja/)
  - 利用想定で不要なパッケージの整理

- **[tv-recorder-monitoring](https://github.com/collelog/tv-recorder-monitoring) との連携**

## FFmpeg Build
```
ffmpeg version 4.2.2 Copyright (c) 2000-2019 the FFmpeg developers
built with gcc 9.2.0 (Alpine 9.2.0)
configuration: 
	--enable-version3
	--enable-gpl
	--enable-nonfree
	--enable-small
	--enable-libmp3lame
	--enable-libx264
	--enable-libx265
	--enable-libvpx
	--enable-libtheora
	--enable-libvorbis
	--enable-libopus
	--enable-libfdk-aac
	--enable-libass
	--enable-libwebp
	--enable-librtmp
	--enable-libaribb24
	--enable-postproc
	--enable-avresample
	--enable-libfreetype
	--enable-openssl
	--disable-debug
	--disable-doc
	--disable-ffplay
	--extra-cflags=-I/usr/local/ffmpeg/include
	--extra-ldflags=-L/usr/local/ffmpeg/lib
	--extra-libs='-lpthread -lm'
	--prefix=/usr/local/ffmpeg
libavutil      56. 31.100 / 56. 31.100
libavcodec     58. 54.100 / 58. 54.100
libavformat    58. 29.100 / 58. 29.100
libavdevice    58.  8.100 / 58.  8.100
libavfilter     7. 57.100 /  7. 57.100
libavresample   4.  0.  0 /  4.  0.  0
libswscale      5.  5.100 /  5.  5.100
libswresample   3.  5.100 /  3.  5.100
libpostproc    55.  5.100 / 55.  5.100
```

## 開発環境
> OS
>>Synology NAS DiskStation Manager 6.2
>>>Linux NAS01 4.4.59+ #24922 SMP PREEMPT Mon Aug 19 12:11:11 CST 2019 x86_64 GNU/Linux synology_denverton_1618+

>Docker
>> Version: 18.09.8, build 2c0a67b

>docker-compose
>> version 1.24.0, build 0aa59064

## License
このソースコードは [MIT License](https://github.com/collelog/tv-recorder/blob/master/LICENSE) のもとでリリースします。
