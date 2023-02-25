## Run KiCad 7 Using Docker

I built a Docker image to run KiCad 7 without disturbing any of my other KiCad installations. Here are the steps to do that in case anyone else needs it.

## Building the KiCad 7 Docker Image

Create a file named `dockerfile` with these contents:
```
# Must use 20.04!
FROM ubuntu:20.04

# These things are needed:
#    sudo: So we have /etc/sudoers.d.
#    keyboard-configuration: Installation stalls without this.
#    software-properties-common: So add-apt-repository exists.
RUN apt-get update && \
    apt-get install -y sudo keyboard-configuration software-properties-common

# Install KiCad 7.0.0.
# (Got the version from https://launchpad.net/~kicad/+archive/ubuntu/kicad-7.0-releases.)
RUN add-apt-repository --yes ppa:kicad/kicad-7.0-releases && \
    apt-get update && \
    apt-get install -y kicad=7.0.0-1-202302220943+da2b9df05c~165~ubuntu20.04.1

# Replace with your login name, user ID, group ID and HOME from your local host machine
# using the --build-arg option.
ARG UID
ARG GID
ARG USER_NAME
ARG HOME

# Create a user account that mirrors the one on your local host so you can share the X11 socket for the KiCad GUI.
# (See http://fabiorehm.com/blog/2014/09/11/running-gui-apps-with-docker/)
RUN mkdir -p ${HOME} && \
    echo "${USER_NAME}:x:${UID}:${GID}:Developer,,,:${HOME}:/bin/bash" >> /etc/passwd && \
    echo "${USER_NAME}:x:${UID}:" >> /etc/group && \
    echo "${USER_NAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${USER_NAME} && \
    chmod 0440 /etc/sudoers.d/${USER_NAME} && \
    chown ${UID}:${GID} -R ${HOME}

USER ${USER_NAME}

# Uncomment one of the entrypoints for whatever app you want to run in the container.
# ENTRYPOINT ["eeschema"]
# ENTRYPOINT ["pcbnew"]
ENTRYPOINT ["kicad"]
```

Build the Docker image and name it `kicad7`:
```shellsession
docker build \
    --build-arg UID=`id -u` \
    --build-arg GID=`id -g` \
    --build-arg USER_NAME=`id -nu` \
    --build-arg HOME=$HOME \
    -t kicad6 .
```

## Running the KiCad5 Docker Container

The Docker container can access the local host's X11 display, KiCad libraries and your home
directory when it's run using the following command:
```shellsession
docker run --rm \
    -e DISPLAY=$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v /usr/share/kicad:/usr/share/kicad \
    -v $HOME:$HOME \
    kicad7
```

At this point, you should see the KiCad 7 main window.

For convenience, you can alias this command in your `.bashrc` file like so:
```shellsession
DCKR_X11="docker run --rm -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -v /usr/share/kicad:/usr/share/kicad -v $HOME:$HOME"
alias kicad7="$DCKR_X11 kicad7"
```
