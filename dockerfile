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
