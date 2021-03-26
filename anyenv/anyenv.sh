#!/usr/bin/env bash

# anyenv のインストール
if ! [ -d /home/vagrant/.anyenv ]; then
  echo "Installing anyenv..."
  git clone https://github.com/riywo/anyenv ~/.anyenv
  echo 'export PATH="$HOME/.anyenv/bin:$PATH"' >> ~/.bash_profile
  echo 'eval "$(anyenv init -)"' >> ~/.bash_profile
  source ~/.bash_profile

  expect -c "
    spawn anyenv install --init
    expect \"Do you want to checkout ? \[y/N\]:\"
    send \"y\r\"
    expect eof
  "
fi

# anyenv プラグインのインストール
if ! [ -d /home/vagrant/.anyenv/plugins ]; then
  mkdir -p $(anyenv root)/plugins
fi
if ! [ -d /home/vagrant/.anyenv/plugins/anyenv-update ]; then
  git clone https://github.com/znz/anyenv-update.git $(anyenv root)/plugins/anyenv-update
fi

exec $SHELL -l