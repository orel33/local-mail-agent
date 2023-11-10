# Local Mail Agent

This repository contains [Dockerfile](Dockerfile) and [assets](config/) for a
Docker image, that runs a **local-only mail agent** on Linux (Debian 12). This
image is published to the [Docker
Hub](https://hub.docker.com/repository/docker/orel33/local-mail-agent). Besides,
this repository contains scripts to build & run this Docker image.

## In few words

More precisely, this Dockerized mail agent consists of two servers:

* an SMTP server (Exim4) listening on ports 25 (plaintext) and 465 (TLS),
* a POP3 server (Dovecot) listening on ports 110 (plaintext) and 995 (TLS).

**Nota Bene**: The server that lets you send mail is called an *outgoing*
server, or SMTP server. The server that lets you receive mail is called an
*incoming* server, or POP3 server.

Both servers are configured to work with a secure TLS connection (*snakeoil*
certificate) or not, with authentication (using *login*) or not.

For the purposes of the demo, the Docker image has two user accounts `toto`
(password `toto`) and `tutu` (password `tutu`), associated with email accounts
`toto@pouet.com` and `tutu@pouet.com` respectively. In this *local-only*
configuration, the `pouet.com` domain is fictitious, and can only be used
locally on the Docker machine.

In short, `toto@pouet.com` can send an email to `tutu@pouet.com` (via the SMTP
protocol). And symmetrically, `tutu@pouet.com` can receive this email (via the
POP3 protocol).

For each user, both servers are linked locally to the same mailbox, which is
stored in the `/var/mail/` directory in *mbox* format. This mailbox can be
accessed directly, by logging into the user account on the Docker machine, and
using a command-line mail client, such as `mutt` or `mail`.

The advantage of this Docker image is that it allows you to launch an instance
of this email agent locally on a machine without root privileges, with the SMTP
& POP3 servers listening on alternative ports. This makes it easy to develop a
mail client (MUA) in Python, for example, without having its own domain name
(DNS).


## Demo

*todo*