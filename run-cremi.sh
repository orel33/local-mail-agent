#!/bin/bash

[ -z "$TMPDIR" ] && TMPDIR=/tmp # or /local ?
[ -z "$USER" ] && USER=$(whoami)
CMD='podman'
OPT="--rm -it --hostname=pouet.com"
STORAGE="--storage-driver=overlay --root=$TMPDIR/$USER/containers"
EXPOSE="-p 10110:110 -p 10995:995 -p 10025:25 -p 10465:465"

$CMD run $OPT $EXPOSE $STORAGE orel33/local-mail-agent

