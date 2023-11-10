#!/bin/bash

[ -z "$TMPDIR" ] && TMPDIR=/tmp # or /local ?
[ -z "$USER" ] && USER=$(whoami)
alias docker='podman'
OPT="--rm -it --hostname=pouet.com"
STORAGE="--storage-driver=overlay --root=$TMPDIR/$USER/containers"
EXPOSE="-p 1110:110 -p 1995:995 -p 1025:25 -p 1465:465"

docker run $OPT $EXPOSE $STORAGE orel33/local-mail-agent


### clean containers
# docker container ls -a
# docker rm $(docker ps -a -q)
# docker container prune
# docker images -a -q
# docker rmi $(docker images -a -q) --force
