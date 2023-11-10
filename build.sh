#!/bin/bash

docker build -t "orel33/local-mail-agent:latest" . && docker push "orel33/local-mail-agent:latest"

