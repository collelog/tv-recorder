# TV Recorder on Docker

> EPGStation 1.7.1, MariaDB 10.4.13-r0, mirakc 0.12.0 (or Mirakurun 2.15.3) のDockerコンテナ

Synology NAS(Intel CPUを採用した[Dockerパッケージ適用機種](https://www.synology.com/ja-jp/dsm/packages/Docker))を想定し作成しましたが、x86-64プラットフォームのLinuxであれば動作します。  
Docker Composeで展開されるDockerコンテナは[Docker Hub](https://hub.docker.com/u/collelog)からコンテナイメージがダウンロードされますので環境構築が容易です。


## 現在の状況
DockerコンテナのDockerfileは [collelog/tv-recorder-dockerfile](https://github.com/collelog/tv-recorder-dockerfile) にて管理するようにしました。  
Dockerコンテナをマルチプラットフォーム化（amd64(x86-64),arm64v8,arm32v7に対応）し、Docker Hubにてコンテナイメージを公開しています。  
ただし、現時点で公開しているDocker Composeファイルはamd64(x86-64)向けのものになり、他プラットフォーム向けのDocker Composeファイルは今後対応予定となります。  
前述の作業を優先しているため、Mirakurunは2.15.3までの対応で現在停止しており、最新バージョンの3.xに未対応です。


## Docker Composeファイル
### EPGStation + MariaDB + mirakc の組み合わせ
- [docker-compose-epgstation1-mirakc.yml](https://github.com/collelog/tv-recorder/blob/master/docker-compose-epgstation1-mirakc.yml)

###  EPGStation + MariaDB + Mirakurun の組み合わせ
- [docker-compose-epgstation1-mirakurun.yml](https://github.com/collelog/tv-recorder/blob/master/docker-compose-epgstation1-mirakurun.yml)

## Dockerコンテナ構成

### EPGStation ([collelog/epgstation:1.7.1-alpine-amd64](https://hub.docker.com/r/collelog/epgstation))
- [Alpine Linux 3.12](https://alpinelinux.org/)
- [Node.js 12.18.2](https://nodejs.org/)([node:12-alpine3.12](https://hub.docker.com/_/node/))
- [EPGStation](https://github.com/l3tnun/EPGStation)
  - version: 1.7.1 (commit b2e9d5d365bf0b68364cf801a3648273d0ef6b05)
- [FFmpeg 4.3.1](https://www.ffmpeg.org/)

### MariaDB ([collelog/mariadb:10.4.13-alpine](https://hub.docker.com/r/collelog/mariadb))
- [Alpine Linux 3.12](https://alpinelinux.org/)([alpine:3.12](https://hub.docker.com/_/alpine))
- [MariaDB 10.4.13-r0](https://mariadb.org/)

### mirakc ([collelog/mirakc:0.12.0-alpine](https://hub.docker.com/r/collelog/mirakc))
※[docker-compose-epgstation1-mirakc.yml](https://github.com/collelog/tv-recorder/blob/master/docker-compose-epgstation1-mirakc.yml) にのみ含まれます
- [Alpine Linux 3.11.6](https://alpinelinux.org/)([alpine:3.11](https://hub.docker.com/_/alpine))
- [mirakc](https://github.com/masnagam/mirakc)
  - version: 0.12.0

### Mirakurun ([collelog/mirakurun:2.15.3-alpine](https://hub.docker.com/r/collelog/mirakurun))
※[docker-compose-epgstation1-mirakurun.yml](https://github.com/collelog/tv-recorder/blob/master/docker-compose-epgstation1-mirakurun.yml) にのみ含まれます
- [Alpine Linux 3.12](https://alpinelinux.org/)
- [Node.js 12.18.2](https://nodejs.org/)([node:12-alpine3.12](https://hub.docker.com/_/node/))
- [Mirakurun](https://github.com/Chinachu/Mirakurun)
  - version: 2.15.3

## 実行条件
- Linux x86-64プラットフォーム
- docker-compose.yml version 3.7 対応 Docker バージョンのインストール
  - Docker Engine version 18.06.0 and higher
  - docker-compose version 1.22.0 and higher
- pcscd の無効化
- [nns779/px4_drv](https://github.com/nns779/px4_drv) のインストール
- PLEX社製TVチューナー PX-W3U4/Q3U4/W3PE4/Q3PE4 のUSB接続
- B-CASカード/スマートカードリーダーのUSB接続


### 主な機能
- **EPGStation Docker image**
  - Alpine Linux ベース
  - [Node.js v12.18.2](https://nodejs.org/)
  - [FFmpeg 4.3.1](https://www.ffmpeg.org/) ビルドオプションは後述「FFmpeg Build」参照
  - MariaDB 連携：UNIXドメインソケット
  - MariaDB 文字コード：UTF8MB4、Collation：UTF8MB4_BIN
  - mirakc 連携：UNIXドメインソケット
  - Mirakurun 連携：UNIXドメインソケット

- **MariaDB Docker image**
  - Alpine Linux ベース
  - サーバー 文字コード：UTF8MB4、Collation：UTF8MB4_BIN
  - EPGStation 向けDB作成（文字コード：UTF8MB4、Collation：UTF8MB4_BIN）
  - EPGStation 向けユーザー作成
  - [Grafana](https://grafana.com/) 向け読み取り専用ユーザー作成

- **mirakc Docker image**
  - Alpine Linux ベース
  - [arib-b25-stream-test](https://www.npmjs.com/package/arib-b25-stream-test)
  - [stz2012 recpt1](https://github.com/stz2012/recpt1/) --enable-b25
  - スマートカードリーダーの使用

- **Mirakurun Docker image**
  - Alpine Linux ベース
  - [Node.js v12.18.2](https://nodejs.org/)
  - [stz2012 recpt1](https://github.com/stz2012/recpt1/) --enable-b25
  - スマートカードリーダーの使用
  - 開発環境(Synology NAS)での実績値として、max_old_space_sizeを512から1024に変更（環境依存値のため、実際の動作環境に合わせて見直してください）

- **[tv-recorder-monitoring](https://github.com/collelog/tv-recorder-monitoring) との連携**


## インストール
### 1. Gitリポジトリの取得
```
sudo git clone https://github.com/collelog/tv-recorder.git
```
### 2．資材のカスタマイズ
### 3．Docker Compose によるコンテナ構築/起動
EPGStation + MariaDB + mirakc の場合：
```
sudo docker-compose -f docker-compose-epgstation1-mirakc.yml up --build -d
```

## カスタマイズ箇所
### Docker Composeファイル ([Docker-docs-ja > Compose ファイル・リファレンス](http://docs.docker.jp/compose/compose-file.html))
使用するDocker Composeファイル(docker-compose-xxxxxxx.yml)を事前に編集する必要があります。  
#### mirakc > devices (mirakc使用時)
TVチューナーデバイスとスマートカードリーダーデバイスの指定を実行環境に合わせてください。  
リポジトリ取得直後のファイルにはPLEX PX-Q3PE4(PX-Q3U4)のTVチューナーデバイスが指定されています。
#### mirakurun > devices (Mirakurun使用時) 
TVチューナーデバイスとスマートカードリーダーデバイスの指定を実行環境に合わせてください。  
リポジトリ取得直後のファイルにはPLEX PX-Q3PE4(PX-Q3U4)のTVチューナーデバイスが指定されています。
### EPGStation 設定 ([EPGStation > config.json 詳細マニュアル](https://github.com/l3tnun/EPGStation/blob/master/doc/conf-manual.md))
コンテナにマウントされる設定ファイルは ./epgstation/config/config.json です。コンテナ外から編集可能です。  
初回動作確認時には編集せずとも動作します。  

### mirakc 設定 ([mirakc > Configuration](https://github.com/masnagam/mirakc/blob/master/docs/config.md))
コンテナにマウントされる設定ファイルは ./mirakc/config.yml です。コンテナ外から編集可能です。  
初回動作確認時にはchannels、tunersプロパティを最低限編集する必要があります。  
リポジトリ取得直後のファイルにはchannelsプロパティに地上波 - 東京都 送信塔：スカイツリー、tunersプロパティにPLEX PX-Q3PE4(PX-Q3U4)のTVチューナーデバイスが指定されています。  

### Mirakurun 設定 ([Mirakurun > Configuration](https://github.com/Chinachu/Mirakurun/blob/master/doc/Configuration.md))
コンテナにマウントされる設定ファイルは ./mirakurun/server.yml | channels.yml | tuners.yml です。コンテナ外から編集可能です。  
初回動作確認時にはchannels.yml と tuners.yml を最低限編集する必要があります。  
リポジトリ取得直後のファイルにはchannels.ymlに地上波 - 東京都 送信塔：スカイツリー、tuners.ymlにPLEX PX-Q3PE4(PX-Q3U4)のTVチューナーデバイスが指定されています。  

## 利用ソースコード
当ソースコードは以下のソースコード（docker-compose.yml,Dockerfile,その他動作に必要なファイル一式）を改変または参考に作成しています。

- **EPGStation**
  - [l3tnun/docker-mirakurun-epgstation](https://github.com/l3tnun/docker-mirakurun-epgstation) : docker-mirakurun-epgstation
    - [MIT License](https://github.com/l3tnun/docker-mirakurun-epgstation/blob/master/LICENSE)

- **MariaDB**
  - [yobasystems/alpine-mariadb](https://github.com/yobasystems/alpine-mariadb) : MariaDB Docker image running on Alpine Linux  

- **mirakc**
  - [masnagam/mirakc](https://github.com/masnagam/mirakc) : mirakc (a Mirakurun clone written in Rust) + recdvb + recpt1
    - [Apache License, Version 2.0](https://github.com/masnagam/mirakc/blob/master/LICENSE-APACHE) or [MIT License](https://github.com/masnagam/mirakc/blob/master/LICENSE-MIT)

- **Mirakurun**
  - [Chinachu/docker-mirakurun-chinachu](https://github.com/Chinachu/docker-mirakurun-chinachu) : docker-mirakurun-chinach
    - [MIT License](https://github.com/Chinachu/docker-mirakurun-chinachu/blob/master/LICENSE)

## 開発環境
> Synology NAS
>>DiskStation ds1618+
>>>DiskStation Manager 6.2  
>>>Linux 4.4.59+ #24922 SMP PREEMPT Thu Mar 12 13:02:11 CST 2020 x86_64 GNU/Linux synology_denverton_1618+

>>DiskStation ds1513+
>>>DiskStation Manager 6.2  
>>>Linux 3.10.105 #24922 SMP Wed Jul 3 16:35:48 CST 2019 x86_64 GNU/Linux synology_cedarview_1513+

>Docker (Server)
>> Version: 18.09.6, build 1d8275b

>docker-compose
>> version 1.24.0, build 0aa59064

## License
このソースコードは [MIT License](https://github.com/collelog/tv-recorder/blob/master/LICENSE) のもとでリリースします。  
ただし当Dockerfileで作成されるDockerイメージに内包される各種アプリケーションで使用されるライセンスは異なります。各プロジェクト内のLICENSE, COPYING, COPYRIGHT, READMEファイルまたはソースコード内のアナウンスを参照してください。
