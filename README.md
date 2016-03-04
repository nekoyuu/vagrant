# ローカル環境構築

## vagrant-vbguest プラグインをインストール
```
$ vagrant plugin install vagrant-vbguest
```
※ VirtualBox の Guest addtion のバージョンを自動で合わせてくれる

## プロビジョン
1. settings.yaml を開いて、プロジェクトに合わせて設定を編集

2. Vagrantfile のディレクトリでコマンドを実行
```
$ vagrant up
```

## 以降、考え中ｗ

## スペック
* Apache 2.4 +