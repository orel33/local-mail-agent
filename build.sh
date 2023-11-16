#!/bin/bash

set -x

docker build -t "orel33/local-mail-agent:latest" . || exit 1
docker push "orel33/local-mail-agent:latest" || exit 1

### push on docker@ubx
docker tag "orel33/local-mail-agent" "registry.u-bordeaux.fr/l2info/local-mail-agent" || exit 1
docker push "registry.u-bordeaux.fr/l2info/local-mail-agent"

# docker login registry.u-bordeaux.fr
