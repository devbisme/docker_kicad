## Run KiCad 5 Using Docker

I upgraded to Ubuntu 22.04 and the appimage for KiCad 5.1 would no longer work. So I built a Docker image to run KiCad 5.1 without disturbing my KiCad 6 installation. Here are the steps to do that in case anyone else needs it.

## Building the KiCad5 Docker Image

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

# Install KiCad 5.1.12. Had to dig into /var/lib/apt/lists/ppa.launchpadcontent... to get version info.
# (See https://askubuntu.com/questions/202285/how-do-i-list-the-content-of-a-ppa-that-i-have-added-to-ubuntu)
RUN add-apt-repository --yes ppa:kicad/kicad-5.1-releases && \
    apt-get update && \
    apt-get install -y kicad=5.1.12-202111050916+84ad8e8a86~92~ubuntu20.04.1

# Replace with your login name, user ID and group ID from your local host machine.
ENV USER_NAME=devb UID=1000 GID=1000
ENV HOME=/home/${USER_NAME}

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
#ENTRYPOINT ["eeschema"]
ENTRYPOINT ["kicad"]
```

Build the Docker image and name it `kicad5`:
```bash
docker build -t kicad5 .
```

## Running the KiCad5 Docker Container

The Docker container can access the local host's X11 display and KiCad libraries when it's run using the following command:
```shellsession
docker run --rm -e DISPLAY=$DISPLAY \
   -v /tmp/.X11-unix:/tmp/.X11-unix \ 
	 -v /usr/share/kicad:/usr/share/kicad \ 
	 -v /home/devb:/home/devb \  <== Change this to match the login account in dockerfile.
	 kicad5
```

At this point, you should see the KiCad 5 main window.

For convenience, you can alias this command in your `.bashrc` file like so:
```shellsession
DCKR_X11="docker run --rm -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -v /usr/share/kicad:/usr/share/kicad -v /home/devb:/home/devb"
alias kicad5="$DCKR_X11 kicad5"
```
