#!/usr/bin/env bash

RUBY_VERSION=$1
NODE_VERSION=$2

# Ruby のインストール
ruby -v 1>/dev/null 2>/dev/null
if [ $? -ne 0 ] ; then
  echo "Installing rbenv..."
  rbenv install ${RUBY_VERSION}
  rbenv global ${RUBY_VERSION}
fi

# Gem のアップデート, bundler のインストール
which gem > /dev/null 2>&1
if ! [ $? = 0 ]; then
  echo "Installing bundler..."
  gem update --system
  gem install bundler
fi

# Node.js のインストール
node -v 1>/dev/null 2>/dev/null
if [ $? -ne 0 ] ; then
  echo "Installing node.js..."
  nodenv install ${NODE_VERSION}
  nodenv global ${NODE_VERSION}
fi
