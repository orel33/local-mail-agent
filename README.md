# Local Mail Agent

This repository contains [Dockerfile](Dockerfile) and [configuration
files](config/) for a Docker image, that runs a **local-only mail agent** on
Linux (Debian 12). This image is published to the [Docker
Hub](https://hub.docker.com/repository/docker/orel33/local-mail-agent). Besides,
this repository contains scripts to build & run this image.

To run this image, simply use:

```bash
$ docker run -it --hostname=pouet.com orel33/local-mail-agent
```

In our case, the `--hostname` option is really important because the chosen
 *hostname* will also be used as the mail domain name (or *mailname*). In the
following, we will assume that the chosen *hostname* is `pouet.com`, but this
can be changed freely.

## In few words

More precisely, this Dockerized mail agent consists of two servers:

* an SMTP server (Exim4) listening on ports 25 (plaintext) and 465 (TLS),
* a POP3 server (Dovecot) listening on ports 110 (plaintext) and 995 (TLS).

*Nota Bene*: The server that lets you send mail is called an *outgoing* server,
or SMTP server. The server that lets you receive mail is called an *incoming*
server, or POP3 server.

Both servers are configured to work with or without a secure TLS connection
(*snakeoil* certificate), with or without authentication (using *login*).

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

## Demo

The advantage of this Docker image is that it allows you to launch our *local
mail agent* in a container without root privileges, or having its own domain
name (DNS). By the way, if you change the configuration of the servers in the
Docker container, there's no risk of breaking anything in the host system.

Let's start by launching the Docker image.

```bash
$ docker run -it --hostname=pouet.com orel33/local-mail-agent
```

You are logged in as *root* in the container. Check with *netstat* that the
servers have started successfully...

```bash
root@pouet$ netstat -tlpn
Proto Local Address     Foreign Address    State     Program name
tcp   0.0.0.0:25        0.0.0.0:*          LISTEN    exim4
tcp   0.0.0.0:465       0.0.0.0:*          LISTEN    exim4
tcp   0.0.0.0:110       0.0.0.0:*          LISTEN    dovecot
tcp   0.0.0.0:995       0.0.0.0:*          LISTEN    dovecot
root@pouet$
```

Now, let's send an email from `tutu@pouet.com` to `toto@pouet.com` by using the
`mail` command.

```bash
root@pouet$ su tutu
tutu@pouet$ echo "Testing message." | mail -s "test" toto@pouet.com
tutu@pouet$ exit
root@pouet$ su toto
toto@pouet$ mail
"/var/mail/toto": 1 message 1 new
>N   1 tutu@pouet.com     Fri Nov 10 11:47  16/462   test
? q
toto@pouet$
```

Furthermore, it is possible to make both SMTP & POP3 servers available outside
of the Docker world, listening on alternative ports. This is particularly
convenient to develop and test locally a *mail user agent* (MUA) on localhost,
that implements both a SMTP client and a POP3 client.

```bash
$ docker run -it --hostname=pouet.com -p 1110:110 -p 1995:995 -p 1025:25 -p 1465:465 orel33/local-mail-agent
```

---
