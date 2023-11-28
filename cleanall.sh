#!/bin/bash

set -x

STORAGE="--storage-driver=overlay --root=$TMPDIR/containers"

### list all containers
podman $STORAGE container ls --all

### kill all containers
podman $STORAGE kill $(podman $STORAGE ps -q)

### systeme prune all (to remove cache)
podman $STORAGE system prune -a -f
podman $STORAGE system df -v

echo "Done."
