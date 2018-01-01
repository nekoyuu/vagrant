# ローカル環境構築手順

## Vagrant プラグインをインストール
### vagrant-vbguest
VirtualBox の Guest addtion のバージョンを自動で合わせてくれる
```shell
$ vagrant plugin install vagrant-vbguest
```

### vagrant-notify
ホストに通知を送信できるようになる
```shell
# vagrant-notify をインストール
$ vagrant plugin install vagrant-notify

# terminal-notifier をインストール（ターミナルから通知を送信できる）
$ brew install terminal-notifier

# terminal-notifier, notify-send のラッパースクリプトを作成（実行権限を与える）
$ vi /usr/local/bin/notify-send  # 下記「notify-send スクリプト」参照
$ sudo chmod u+x /usr/local/bin/notify-send

# ゲストを起動して SSH 接続
$ vagrant up
$ vagrant ssh

# ゲストに notify-send がなければインストール
$ which notify-send
$ sudo yum install libnotify  # CentOS

# 通知が送信されるか確認
$ notify-send "タイトル" "ゲストマシンからの送信です"
```
#### notify-send スクリプト
参考: <https://github.com/fgrehm/vagrant-notify/blob/master/examples/osx/terminal-notifier/notify-send.rb>
```ruby
#!/usr/bin/env ruby
# -*- mode: ruby -*-
# vi: set ft=ruby :

# Example OS X terminal-notifier notify-send wrapper script.

require 'optparse'


options = {}
OptionParser.new do |opts|
  opts.on('-u', '--urgency LEVEL')           { |v| options[:u] = v } # Option gets removed
  opts.on('-t', '--expire-time TIME')        { |v| options[:t] = v } # Option gets removed
  opts.on('-a', '--app-name APP_NAME')       { |v| options[:a] = v } # TO DO: Set to -title
  opts.on('-i', '--icon ICON[,ICON...]')     { |v| options[:i] = v } # Option gets removed
  opts.on('-c', '--category TYPE[,TYPE...]') { |v| options[:c] = v } # Option gets removed
  opts.on('-h', '--hint TYPE:NAME:VALUE')    { |v| options[:h] = v } # Option gets removed
  opts.on('-v', '--version')                 { |v| options[:v] = v } # Option gets removed
end.parse!


if ARGV.length == 0
  puts "No summary specified"
  exit 1
elsif ARGV.length == 1
  message = "-message '\\#{ARGV[0]}'"
elsif ARGV.length == 2
  message = "-title '\\#{ARGV[0]}' -message '\\#{ARGV[1]}'"
else
  puts "Invalid number of options."
  exit 1
end

system("terminal-notifier -sound default #{message}")
```

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
# カレントディレクトリの composer.json が実行される
$ composer install

# npm で管理しているものがあれば実行
# カレントディレクトリの package.json が実行される
$ npm install

# bower で管理しているものがあれば実行
# カレントディレクトリの bower.json が実行される
$ bower install

# gulp を利用しているのであれば実行
# カレントディレクトリの gulpfile.js が実行される
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

## パッケージのインストール・アンインストール方法
特別な理由がない限り、下記コマンドにて行う（直接 json ファイルを操作しない）。
### Composer
```shell
$ composer init # 初期設定（composer.json を生成）
$ composer [require|remove] phpunit/phpunit:3.7.*       # require を対象に追加/削除
$ composer [require|remove] phpunit/phpunit:3.7.* --dev # require-dev を対象に追加/削除
```

### node.js (npm)
```shell
$ npm init # 初期設定（package.json を生成）
$ npm [i|r] -S package # dependencies を対象に追加/削除
$ npm [i|r] -D package # devDependencies を対象に追加/削除
```

### Bower
```shell
$ bower init # 初期設定（bower.json を生成）
$ bower [i|r] -S package # dependencies を対象に追加/削除
$ bower [i|r] -D package # devDependencies を対象に追加/削除
```

### Bourbon
```shell
# カレントディレクトリ配下に mixin が格納された bourbon/ が生成される
$ bourbon install
$ rm -rf bourbon # bourbon ディレクトリを削除
```

## スペック
バージョンの明記のないものは最新バージョン

* Postfix + SASL
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
* Bourbon
* Modular Scale
* Susy
* Bower
* Gulp
