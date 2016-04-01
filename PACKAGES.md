# よく使うパッケージ/プラグイン

## ユーティリティ
### asset-builder
アセット結合を定義ファイルとして一元化する。  
[https://www.npmjs.com/package/asset-builder](https://www.npmjs.com/package/asset-builder)

### del
対象ファイル/ディレクトリを削除する。  
[https://www.npmjs.com/package/del](https://www.npmjs.com/package/del)

### gulp-batch
gulp-watch にコールバックハンドラを提供する。  
[https://www.npmjs.com/package/gulp-batch](https://www.npmjs.com/package/gulp-batch)

### gulp-cached
対象ファイルをメモリにキャッシュする。  
[https://www.npmjs.com/package/gulp-cached](https://www.npmjs.com/package/gulp-cached)

### gulp-changed
変更されたファイルのみを次のストリームへ流す。  
[https://www.npmjs.com/package/gulp-changed](https://www.npmjs.com/package/gulp-changed)

### gulp-concat
対象ファイルを連結する。  
[https://www.npmjs.com/package/gulp-concat](https://www.npmjs.com/package/gulp-concat)

### gulp-convert-encoding
対象ファイルのエンコーディングを変換する。  
[https://www.npmjs.com/package/gulp-convert-encoding](https://www.npmjs.com/package/gulp-convert-encoding)

### gulp-debug
ストリームに流れているファイル名を出力する。  
[https://www.npmjs.com/package/gulp-debug](https://www.npmjs.com/package/gulp-debug)

### gulp-filter
対象ファイルをフィルタリングして次のストリームへ流す。  
[https://www.npmjs.com/package/gulp-filter](https://www.npmjs.com/package/gulp-filter)

### gulp-if
条件付きタスクを実行する。  
[https://www.npmjs.com/package/gulp-if](https://www.npmjs.com/package/gulp-if)

### gulp-modernizr
対象ファイルを検証して、カスタムされた Modernizr をビルドする。  
[https://www.npmjs.com/package/gulp-modernizr](https://www.npmjs.com/package/gulp-modernizr)

### gulp-newer
流れてきた対象ファイルにひとつでも変更ファイルがあれば、全てのファイルを次のストリームへ流す。  
gulp-sass や gulp-concat と併用してファイルを連結したりする場合は gulp-changed よりおすすめ。  
[https://www.npmjs.com/package/gulp-newer](https://www.npmjs.com/package/gulp-newer)

### gulp-notify
デスクトップ通知を出す。  
※ Vagrant 環境で動かない場合があるので注意（README.md 参照）。  
[https://www.npmjs.com/package/gulp-notify](https://www.npmjs.com/package/gulp-notify)

### gulp-plumber
Gulp 実行時のエラーによる停止を抑止する。  
[https://www.npmjs.com/package/gulp-plumber](https://www.npmjs.com/package/gulp-plumber)

### gulp-rename
対象ファイル名をリネームする。  
[https://www.npmjs.com/package/gulp-rename](https://www.npmjs.com/package/gulp-rename)

### gulp-sourcemaps
開発者ツールでコンパイル前のソースを表示する。  
[https://www.npmjs.com/package/gulp-sourcemaps](https://www.npmjs.com/package/gulp-sourcemaps)

### gulp-watch
対象ファイルの変更を監視する。gulp.watch の強化版みたいなもの。  
[https://www.npmjs.com/package/gulp-watch](https://www.npmjs.com/package/gulp-watch)

### lazypipe
複数のタスクをグループ化（クロージャ化）する。  
[https://www.npmjs.com/package/lazypipe](https://www.npmjs.com/package/lazypipe)

### merge-stream
タスク内の複数のストリームをマージする。  
[https://www.npmjs.com/package/merge-stream](https://www.npmjs.com/package/merge-stream)

### run-sequence
通常は並列実行されるタスクの実行順序を指定する。  
[https://www.npmjs.com/package/run-sequence](https://www.npmjs.com/package/run-sequence)


## Bower
### gulp-bower
bower.json で指定されているパッケージをインストールする。  
コンポーネントディレクトリがない場合はエラーになる（別途 ```$ bower install``` などが必要）。  
[https://www.npmjs.com/package/gulp-bower](https://www.npmjs.com/package/gulp-bower)

### main-bower-files
パッケージのメインファイルを取得する。  
[https://www.npmjs.com/package/main-bower-files](https://www.npmjs.com/package/main-bower-files)


## CSS/Sass
### gulp-autoprefixer
指定したブラウザとバージョンでベンダープレフィックスを付加する。  
[https://www.npmjs.com/package/gulp-autoprefixer](https://www.npmjs.com/package/gulp-autoprefixer)

### gulp-clean-css（gulp-minify-css が deprecated になったため）
clean-css を使用してミニファイする。  
[https://www.npmjs.com/package/gulp-clean-css](https://www.npmjs.com/package/gulp-clean-css)

### gulp-compass
Compass を使用してコンパイルする。  
[https://www.npmjs.com/package/gulp-compass](https://www.npmjs.com/package/gulp-compass)

### gulp-csscomb
CSS のコーディングスタイルをフォーマットに合わせて修正する。  
[https://www.npmjs.com/package/gulp-csscomb](https://www.npmjs.com/package/gulp-csscomb)

[ここ](http://csscomb.com/config)で設定ファイル（.csscomb.json）のテンプレートが生成できる。

gulp-sourcemaps が未対応なので、同時に使用するとマッピングが崩れる（2016/03/18 現在）。  
[https://github.com/csscomb/csscomb.js/issues/449#issue-130486319](https://github.com/csscomb/csscomb.js/issues/449#issue-130486319)

### gulp-sass
Sass ファイルをコンパイルする。  
[https://www.npmjs.com/package/gulp-sass](https://www.npmjs.com/package/gulp-sass)

### node-bourbon
gulp-sass で Bourbon ライブラリを使用する。  
[https://www.npmjs.com/package/node-bourbon](https://www.npmjs.com/package/node-bourbon)

### sass-convert
CSS, SCSS, SASS を SCSS, SASS に変換する。  
[https://www.npmjs.com/package/sass-convert](https://www.npmjs.com/package/sass-convert)


## Javascript
### gulp-uglify
UglifyJS を使用して Javascript ファイルをミニファイする。  
[https://www.npmjs.com/package/gulp-uglify](https://www.npmjs.com/package/gulp-uglify)


## Image
### gulp-imagemin
PNG, JPEG, GIF, SVG 画像をミニファイする。  
[https://www.npmjs.com/package/gulp-imagemin](https://www.npmjs.com/package/gulp-imagemin)

### imagemin-pngquant
PNG 画像ミニファイ用の imagemin プラグイン。  
[https://www.npmjs.com/package/imagemin-pngquant](https://www.npmjs.com/package/imagemin-pngquant)
