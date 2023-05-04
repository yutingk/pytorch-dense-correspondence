# !/usr/bin/env bash

ARGS=("$@")

CONTAINER_NAME="pytorch-dense-correspondence"
REPOSITORY="yutingk/pytorch-dense-correspondence"
home_directory="/home/$USER"
source_dir="/home/$USER/pytorch-dense-correspondence"

TAG="latest"
IMG="${REPOSITORY}:${TAG}"

CONTAINER_ID=$(docker ps -aqf "ancestor=${IMG}")
if [ $CONTAINER_ID ]; then
  echo "Attach to docker container $CONTAINER_ID"
  xhost +
  docker exec --privileged -e DISPLAY=${DISPLAY} -e LINES="$(tput lines)" -it ${CONTAINER_ID} bash
  xhost -
  return
fi

# Make sure processes in the container can connect to the x server
# Necessary so gazebo can create a context for OpenGL rendering (even headless)
XAUTH=/tmp/.docker.xauth
if [ ! -f $XAUTH ]; then
    xauth_list=$(xauth nlist $DISPLAY)
    xauth_list=$(sed -e 's/^..../ffff/' <<<"$xauth_list")
    if [ ! -z "$xauth_list" ]; then
        echo "$xauth_list" | xauth -f $XAUTH nmerge -
    else
        touch $XAUTH
    fi
    chmod a+r $XAUTH
fi

# Prevent executing "docker run" when xauth failed.
if [ ! -f $XAUTH ]; then
  echo "[$XAUTH] was not properly created. Exiting..."
  exit 1
fi

DOCKER_OPTS=

# Get the current version of docker-ce
# Strip leading stuff before the version number so it can be compared
DOCKER_VER=$(dpkg-query -f='${Version}' --show docker-ce | sed 's/[0-9]://')
if dpkg --compare-versions 19.03 gt "$DOCKER_VER"; then
  echo "Docker version is less than 19.03, using nvidia-docker2 runtime"
  if ! dpkg --list | grep nvidia-docker2; then
    echo "Please either update docker-ce to a version greater than 19.03 or install nvidia-docker2"
    exit 1
  fi
  DOCKER_OPTS="$DOCKER_OPTS --runtime=nvidia"
else
  echo "nvidia container toolkit"
  DOCKER_OPTS="$DOCKER_OPTS --gpus all"
fi

docker run \
    -it \
    --rm \
    -e DISPLAY -e QT_X11_NO_MITSHM=1 \
    -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
    -v "$XAUTH:$XAUTH" \
    -v "${source_dir}:${home_directory}/code" \
    -v ~/.ssh:${home_directory}/.ssh \
    -v /media:/media \
    -v ~/.torch:${home_directory}/.torch \
    -v "/home/$USER/pytorch-dense-correspondence/docker:${home_directory}/data" \
    -v "/etc/localtime:/etc/localtime:ro" \
    -v "/dev:/dev" \
    -v "/var/run/docker.sock:/var/run/docker.sock" \
    -p 8888:8888 \
    --ipc=host \
    --user "$USER:root" \
    --workdir "/home/$USER/code" \
    --name "${CONTAINER_NAME}" \
    --network host \
    --privileged \
    -v /dev/bus/usb:/dev/bus/usb \
    --security-opt seccomp=unconfined \
    $DOCKER_OPTS \
    "${IMG}" \
    bash
