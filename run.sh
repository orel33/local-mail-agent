#!/bin/bash

# IMG="orel33/local-mail-agent"
IMG="registry.u-bordeaux.fr/l2info/local-mail-agent"
EXPOSE="-p 10110:110 -p 10995:995 -p 10025:25 -p 10465:465"
docker run -it --hostname=pouet.com $EXPOSE $IMG
