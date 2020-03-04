# TV Recorder on Docker

> EPGStation version 1.x.x, MariaDB, mirakc (or Mirakurun) のDockerコンテナ  
  
Intel CPUを採用したSynology NASでの使用を想定し作成しましたが、Dockerホスト実行条件を満たすx86-64プラットフォームのLinuxであれば動作します。  


## Dockerコンテナ構成

### EPGStation
- [Alpine Linux 3.11](https://alpinelinux.org/)([alpine:3.11](https://hub.docker.com/_/alpine))
- [EPGStation](https://github.com/l3tnun/EPGStation)
  - branch: master

### MariaDB
- [Alpine Linux 3.11](https://alpinelinux.org/)([alpine:3.11](https://hub.docker.com/_/alpine))
- [MariaDB 10.4.12](https://mariadb.org/)

### mirakc
- [Alpine Linux 3.11](https://alpinelinux.org/)([alpine:3.11](https://hub.docker.com/_/alpine))
- [mirakc](https://github.com/masnagam/mirakc)
  - branch: master

### Mirakurun (Optional)
- [Alpine Linux 3.11](https://alpinelinux.org/)([node:12-alpine](https://hub.docker.com/_/node/))
- [Mirakurun](https://github.com/Chinachu/Mirakurun)
  - branch: master

## Dockerホスト実行条件
- Linux x86-64プラットフォーム
- PLEX社製TVチューナー PX-W3U4/Q3U4/W3PE4/Q3PE4 のUSB接続
- B-CASカード/スマートカードリーダーのUSB接続
- [nns779/px4_drv](https://github.com/nns779/px4_drv) のインストール
- pcscd の無効化
- docker-compose.yml version 3.7 対応 Docker バージョンのインストール
  - Docker Engine version 18.06.0 and higher
  - docker-compose version 1.22.0 and higher

## 利用ソースコード
当ソースコードは以下のソースコード（docker-compose.yml,Dockerfile,その他動作に必要なファイル一式）を改変または参考に作成しています。

- **EPGStation** ([l3tnun/docker-mirakurun-epgstation](https://github.com/l3tnun/docker-mirakurun-epgstation))  
docker-mirakurun-epgstation
  - MIT License ([License File](https://github.com/l3tnun/docker-mirakurun-epgstation/blob/master/LICENSE), [Open Source Initiative Site](http://opensource.org/licenses/MIT))

- **FFMpeg** ([alfg/docker-ffmpeg](https://github.com/alfg/docker-ffmpeg))  
docker-ffmpesg
  - MIT License ([License File](https://github.com/alfg/docker-ffmpeg/blob/master/LICENSE), [Open Source Initiative Site](http://opensource.org/licenses/MIT))

- **MariaDB** ([yobasystems/alpine-mariadb](https://github.com/yobasystems/alpine-mariadb))  
MariaDB Docker image running on Alpine Linux

- **mirakc** ([masnagam/mirakc](https://github.com/masnagam/mirakc))  
A Mirakurun clone written in Rust
  - Apache License, Version 2.0 ([License File](https://github.com/masnagam/mirakc/blob/master/LICENSE-APACHE), [The Apache Software Foundation Site](http://www.apache.org/licenses/LICENSE-2.0))
  - MIT License ([License File](https://github.com/masnagam/mirakc/blob/master/LICENSE-MIT), [Open Source Initiative Site](http://opensource.org/licenses/MIT))

- **Mirakurun** ([Chinachu/docker-mirakurun-chinachu](https://github.com/Chinachu/docker-mirakurun-chinachu))  
docker-mirakurun-chinach  
  - MIT License ([License File](https://github.com/Chinachu/docker-mirakurun-chinachu/blob/master/LICENSE), [Open Source Initiative Site](http://opensource.org/licenses/MIT))


### 主な変更点
- **EPGStation Docker image**
  - Alpine Linux ベース
  - [FFMpeg 4.2.2](https://www.ffmpeg.org/)
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
  - [libarib25](https://github.com/stz2012/libarib25)
  - [stz2012版recpt1](https://github.com/stz2012/recpt1/) --enable-b25
  - スマートカードリーダーの設定
  - 利用想定で不要なパッケージ、アプリケーションの整理

- **Mirakurun Docker image**
  - [Node.js v12](https://nodejs.org/ja/)
  - [libarib25](https://github.com/stz2012/libarib25)
  - [stz2012版recpt1](https://github.com/stz2012/recpt1/) --enable-b25
  - 利用想定で不要なパッケージの整理


## 開発環境
> OS
>>Synology NAS DiskStation Manager 6.2
>>>Linux NAS01 4.4.59+ #24922 SMP PREEMPT Mon Aug 19 12:11:11 CST 2019 x86_64 GNU/Linux synology_denverton_1618+

>Docker
>> Version: 18.09.8, build 2c0a67b

>docker-compose
>> version 1.24.0, build 0aa59064


## License
このソースコードは MIT License ([License File](https://github.com/collelog/tv-recorder/blob/master/LICENSE), [Open Source Initiative Site](http://opensource.org/licenses/MIT)) のもとでリリースします。
