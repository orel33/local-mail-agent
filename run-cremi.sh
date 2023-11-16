#!/bin/bash

# alias podman="podman --root=$TMPDIR/containers --storage-driver=overlay"
# alias docker=podman

# alias podman-compose="podman-compose --podman-args="--root=$TMPDIR/containers --storage-driver=overlay"
# alias docker-compose="podman-compose"

# [ -z "$TMPDIR" ] && TMPDIR=/tmp/$USER
# [ -z "$TMPDIR" ] && TMPDIR=/local/$USER 
# [ -z "$USER" ] && USER=$(whoami)

OPT="--rm -it --hostname=pouet.com"
STORAGE="--storage-driver=overlay --root=$TMPDIR/containers"
EXPOSE="-p 10110:110 -p 10995:995 -p 10025:25 -p 10465:465"
IMG="registry.u-bordeaux.fr/l2info/local-mail-agent"

podman run $OPT $EXPOSE $STORAGE $IMG

