#!/bin/bash

EXPOSE="-p 1110:110 -p 1995:995 -p 1025:25 -p 1465:465"
docker run -it --hostname=pouet.com $EXPOSE orel33/local-mail-agent
