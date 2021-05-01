# TV Recorder on Docker

> EPGStatio, MariaDB, mirakc (or Mirakurun 2.15.3) のDockerコンテナ

録画サーバの構築に必要とする[Dockerコンテナイメージ](https://hub.docker.com/u/collelog)を管理するDocker Composeファイルと各アプリケーションの初期設定ファイルを提供します。

## Dockerコンテナイメージ
[dockerhub](https://hub.docker.com/)にて公開している自作イメージのDockerfileは [collelog/tv-recorder-dockerfile](https://github.com/collelog/tv-recorder-dockerfile) にて管理しています。

## Docker Composeファイル
現在メンテナンスを行っている構成は以下の通りです。  
こちらに記載がないファイルも残しておりますが、メンテ・説明等は行っておりません。  
各Dockerコンテナイメージの説明は、表中のDockerイメージ欄のdockerhubリンク先を参照してください。

### チューナー・フロントエンド
| Docker Composeファイル | プラットフォーム | アプリケーション | Dockerイメージ | 備考 |
| ---- | ---- | ---- | ---- | ---- |
| epgstation2-mirakc-amd64.yml | x86-64 | mirakc | [collelog/mirakc](https://hub.docker.com/r/collelog/mirakc) | チューナーコマンド(※1) |
| | | EPGStation v2 | [collelog/epgstation](https://hub.docker.com/r/collelog/epgstation) | SQLite3 + 正規表現拡張モジュール |
| | | | | FFmpeg 4.4 |
| epgstation2-mirakc-vaapi-amd64.yml | x86-64 | mirakc | [collelog/mirakc](https://hub.docker.com/r/collelog/mirakc) | チューナーコマンド(※1) |
| | | EPGStation v2 | [collelog/epgstation](https://hub.docker.com/r/collelog/epgstation) | SQLite3 + 正規表現拡張モジュール |
| | | | | FFmpeg 4.4(VAAPI対応) |
| epgstation2-mirakc-rpi4-64.yml | Raspberry Pi4(64bit OS) | mirakc | [collelog/mirakc](https://hub.docker.com/r/collelog/mirakc) | チューナーコマンド(※1) |
| | | EPGStation v2 | [collelog/epgstation](https://hub.docker.com/r/collelog/epgstation) | SQLite3 + 正規表現拡張モジュール |
| | | | | FFmpeg 4.4(V4L2対応) |
| epgstation2-mirakc-rpi4-32.yml | Raspberry Pi4(32bit OS) | mirakc | [collelog/mirakc](https://hub.docker.com/r/collelog/mirakc) | チューナーコマンド(※1) |
| | | EPGStation v2 | [collelog/epgstation](https://hub.docker.com/r/collelog/epgstation) | SQLite3 + 正規表現拡張モジュール |
| | | | | FFmpeg 4.4(OpenMAX対応) |
| epgstation2-mirakc-rpi3.yml | Raspberry Pi3(32bit OS) | mirakc | [collelog/mirakc](https://hub.docker.com/r/collelog/mirakc) | チューナーコマンド(※1) |
| | | EPGStation v2 | [collelog/epgstation](https://hub.docker.com/r/collelog/epgstation) | SQLite3 + 正規表現拡張モジュール |
| | | | | FFmpeg 4.4(OpenMAX対応) |

※1 recpt1, recdvb, recfsusb2n, dvbv5-zap

#### mirakc：config.yml
サンプルとして地上波：東京都/BS、PLEX PX-Q3PE4(PX-Q3U4)のTVチューナーデバイスが指定されています。

#### EPGStation：DBMSにMariaDBを使用した場合
SQLite3 + 正規表現拡張モジュールの使用を推奨しますが、MariaDBを使用したい場合は対象Docker Composeファイル中の「#mysql#」を置換し、コメントを解除してください。

#### EPGStation：FFmpeg ハードウェアアクセラレーション
対応するFFmpegとライブラリをイメージに含めておりますがEPGStation側の設定は取り込んでおりません。このため設定をフィードバックして頂ければ幸いです。

#### EPGStation：公開URL
- http://IPアドレス:8888/


### TV番組スキャン
| Docker Composeファイル | プラットフォーム | アプリケーション| Dockerイメージ | 備考 |
| ---- | ---- | ---- | ---- | ---- |
| expansion-tvchannels-scan.yml | x86-64,arm64,arm/v7,arm/v6 | tvchannels-scan | [collelog/tvchannels-scan](https://hub.docker.com/r/collelog/tvchannels-scan) | |


### メディアサーバ
| Docker Composeファイル | プラットフォーム | アプリケーション | Dockerイメージ | 備考 |
| ---- | ---- | ---- | ---- | ---- |
| expansion-jellyfin.yml | x86-64,arm64,arm/v7,arm/v6 | jellyfin | [linuxserver/jellyfin](https://hub.docker.com/r/linuxserver/jellyfin) | |
| | | xteve | [collelog/xteve](https://hub.docker.com/r/collelog/xteve) | |
#### jellyfin：公開URL
- http://IPアドレス:8096/

#### xteve：公開URL
- http://IPアドレス:34400/web/

### ファイル共有,Docker管理
| Docker Composeファイル | プラットフォーム | アプリケーション | Dockerイメージ | 備考 |
| ---- | ---- | ---- | ---- | ---- |
|expansion-management.yml | x86-64,arm64,arm/v7,arm/v6 | samba | [dperson/samba](https://hub.docker.com/r/dperson/samba) | |
| | | portainer | [portainer/portainer-ce](https://hub.docker.com/r/portainer/portainer-ce) | |

#### samba：共有ディレクトリ
ID/PWDは tvrecorder、tvrecorderapass です。
- \\\\IPアドレス\video  
Dockerホスト側ディレクトリ「./recorded」（EPFStation 録画ファイル格納先）を公開
- \\\\IPアドレス\tv-recorder  
Dockerホスト側ディレクトリ「../」（tv-recorder gitチェックアウト先）を公開

#### portainer：公開URL
- http://IPアドレス:9000/

### BCASサーバ
| Docker Composeファイル | プラットフォーム | アプリケーション | Dockerイメージ | 備考 |
| ---- | ---- | ---- | ---- | ---- |
|expansion-b25-server.yml | x86-64,arm64,arm/v7,arm/v6 | b25-server | [collelog/b25-server](https://hub.docker.com/r/collelog/b25-server) | |


## 実行条件
- Linux x86-64、Raspberry Pi4/3 プラットフォーム
- docker-compose.yml version 3.7 対応 Docker バージョンのインストール
  - Docker Engine version 18.06.0 and higher
  - docker-compose version 1.22.0 and higher
- pcscd の無効化
- [nns779/px4_drv](https://github.com/nns779/px4_drv) のインストール
- PLEX社製TVチューナー PX-Q3U4/Q3PE4/Q3PE5, PX-W3U4/W3PE4/W3PE5 のUSB接続  
各種ファイルを修正することでPX-MLT5PE、PLEX PX-MLT8PE等も可
- B-CASカード/スマートカードリーダーのUSB接続

## License
このソースコードは [MIT License](https://github.com/collelog/tv-recorder/blob/master/LICENSE) のもとでリリースします。  
ただし当Dockerfileで作成されるDockerイメージに内包される各種アプリケーションで使用されるライセンスは異なります。各プロジェクト内のLICENSE, COPYING, COPYRIGHT, READMEファイルまたはソースコード内のアナウンスを参照してください。
