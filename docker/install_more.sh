#!/bin/bash

set -euxo pipefail

sudo apt-get update
sudo pip install requests
sudo pip install matplotlib
sudo pip install scipy
sudo pip install imageio==2.5.0

sudo pip install scikit-image==0.14.3

sudo pip install tensorboard_logger \
    tensorflow

# seems that we need this version of tensorboard
# maybe because tensorboard_logger is not compatible 
# with newer versions of tensorboard?
sudo pip install tensorboard==1.8.0

sudo pip install sklearn==0.0

sudo DEBIAN_FRONTEND=noninteractive pip install opencv-contrib-python==4.1.0.25


sudo apt install python-tk \
    ffmpeg
