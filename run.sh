#!/bin/bash

set -x

OPT="--rm -it --hostname=pouet.com"
STORAGE="--storage-driver=overlay --root=$TMPDIR/containers"
EXPOSE="-p 10110:110 -p 10995:995 -p 10025:25 -p 10465:465"
IMG="registry.u-bordeaux.fr/l2info/local-mail-agent"

podman run $OPT $EXPOSE $STORAGE $IMG

