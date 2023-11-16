#!/bin/bash

set -x

### list all containers
docker container ls --all

### kill all containers
docker kill $(docker ps -q)

### remove all stoped containers
# docker container prune --force

### clean images
# docker images --all
# docker rmi $(docker images --all -q) --force

### systeme prune all (to remove cache)
docker system prune -a -f
docker system df -v

echo "Done."