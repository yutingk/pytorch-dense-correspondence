#!/bin/bash

set -euxo pipefail

apt-get update
apt install --no-install-recommends \
  terminator \
  tmux \
  vim \
  gedit \
  git \
  openssh-client \
  unzip \
  htop \
  libopenni-dev \
  apt-utils \
  usbutils \
  dialog \
  python-pip \
  python-dev \
  ffmpeg \
  nvidia-settings \
  cmake-curses-gui \
  libyaml-dev

# pip install --upgrade pip==9.0.3
pip install --upgrade pip
pip install -U setuptools

# apt-get -y install ipython ipython-notebook
pip install \
  plyfile==0.7 \
  pandas==0.24.2 \
  tensorflow \
  future==0.17.1 \
  typing==3.7.4

pip install \
    opencv-python==4.1.0.25 \
    jupyter 