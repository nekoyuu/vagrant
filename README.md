# ローカル環境構築手順

## vagrant-vbguest プラグインをインストール
```shell
$ vagrant plugin install vagrant-vbguest
```
※ VirtualBox の Guest addtion のバージョンを自動で合わせてくれる

## プロビジョン・ゲストの起動
以下、ホスト側で実行
```shell
$ git clone kakeo@shape-design.info:/var/git/vagrant.git {project_name}
$ cd {project_name}
$ cp settings.yaml.example settings.yaml
$ vi settings.yaml
# hostname, ip などプロビジョニングの設定を編集
# ip は同時に立ち上げている環境と被っていると正常に動作しないので注意

$ vagrant up
```

## 開発準備
ゲストに SSH 接続
```shell
$ vagrant ssh
```

以下、ゲスト側で実行
```shell
$ cd /vagrant/www
$ git init
$ git remote add origin kakeo@shape-design.info:/var/git/{type}/{project_name}.git

# リモートのブランチを取得する
$ git fetch
$ git checkout -b master --track origin/master
$ git checkout -b develop --track origin/develop

$ git flow init -d

# 開発開始
$ git checkout develop
$ git flow feature start {task_name}

# composer で管理しているものがあれば実行
$ composer install

# npm で管理しているものがあれば実行
$ npm install

# bower で管理しているものがあれば実行
$ bower install

# gulp を利用しているのであれば実行
$ gulp
```

### 補足
現在ゲストに秘密鍵を設置していないので、ホスト側でしか pull できない…。  
ホスト側の秘密鍵をゲスト側に scp で設置するか下記が必要がある。  
対処: ```ssh-add``` を利用してホスト側の秘密鍵を使用する。
```shell
# ホスト側で ssh-agent に秘密鍵を追加
# -K でキーチェーンに登録しないと再起動で解除される
$ ssh-add -K ~/.ssh/id_rsa
```
Vagrantfile に ```config.ssh.forward_agent = true``` を追加（記述済）

## スペック
バージョンの明記のないものは最新バージョン

* Postfix
* Apache
* PHP: 5.6
* MySQL: 5.6
* phpMyAdmin
* git
* gitflow
* Ruby: settings.yaml に記載のバージョン
* Nodejs
* npm
* Composer
* Sass
* Compass
* Modular Scale
* Susy
* Bower
* Gulp

## その他
gulp-notify で通知が送られた際にホストへ渡せない…。  
[vagrant-notify - ゲストの通知をホストへ渡す Vagrant プラグイン](https://github.com/fgrehm/vagrant-notify)  
※ インストールしてみたがエラーが出てゲストが立ち上がらない（恐らく Vagrant 1.7 未満なら動くと思われ…）  
```shell
$ vagrant plugin install vagrant-notify
```
