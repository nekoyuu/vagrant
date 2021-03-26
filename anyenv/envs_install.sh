#!/usr/bin/env bash

# rbenv のインストール
if ! [ -d /home/vagrant/.anyenv/envs/rbenv ]; then
  echo "Installing rbenv..."
  anyenv install rbenv
fi

# nodenv のインストール
if ! [ -d /home/vagrant/.anyenv/envs/nodenv ]; then
  echo "Installing nodenv..."
  anyenv install nodenv
fi

exec $SHELL -l
