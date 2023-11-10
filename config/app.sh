#!/bin/bash

# Set mailname to hostname
echo "$HOSTNAME" > /etc/mailname

# Start services
service exim4 start
service dovecot start

# Start bash
netstat -tlpn
echo "Local Mail Agent for toto@$HOSTNAME and tutu@$HOSTNAME"
exec /bin/bash
