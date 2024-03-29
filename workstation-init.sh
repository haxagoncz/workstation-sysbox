#!/bin/bash

PASS=${PASSWORD:-admin}
USER=${USERNAME:-admin}
LOGIN_SHELL=${SHELL:-/bin/bash}
ENTRYPOINT_REMOVE=${ENTRYPOINT_REMOVE:-true}
ENTRYPOINT_PATH=${ENTRYPOINT_PATH:-/tmp/entrypoint.sh}

if [ "${ENTRYPOINT_DEBUG}" == "true" ]; then
    set -x
fi

useradd --create-home --badnames --shell $LOGIN_SHELL $USER && echo "$USER:$PASS" | chpasswd

if [ "${SUDO}" != "false" ]; then
    usermod -aG sudo $USER
fi

[ -f $ENTRYPOINT_PATH ] && chmod +x $ENTRYPOINT_PATH && $ENTRYPOINT_PATH

if [ -f $ENTRYPOINT_PATH ] && [ "${ENTRYPOINT_REMOVE}" == "true" ]; then
    rm $ENTRYPOINT_PATH
fi
