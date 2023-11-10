#!/bin/bash

service exim4 start
service dovecot start
netstat -tlpn
echo "Local Mail Agent for toto@$HOSTNAME and tutu@$HOSTNAME"
exec /bin/bash
