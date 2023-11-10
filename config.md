# Configuration Mail

* Configuration de Exim4 (serveur SMTP) et de Dovecot (serveur POP3/IMAP) en mode *local only*
* Préparation d'une image docker pour faire des tests, basée sur Exim4 & Dovecot sous Linux.

## Installation de Exim4

Ajouter dans /etc/hosts la ligne suivante :

127.0.0.1 prout.com prout

Installer exim4 :

```
$ sudo apt install exim4
$ sudo dpkg-reconfigure exim4-config
```

Configuration :

* local delivery only; not on a network
* System mail name: prout.com
* IP-addresses to listen on for incoming SMTP connections: 127.0.0.1 (*)
* Keep number of DNS-queries minimal (Dial-on-Demand)? no
* Delivery method for local mail: mbox format in /var/mail/
* Split configuration into small files? no

(*) An empty value will cause Exim to listen for connections on all available
 network interfaces. External connections are impossible when 127.0.0.1 is
entered here, as this will disable listening on public network interfaces.

TODO: try Maildir format in home directory

```
$ sudo service exim4 restart
```

Faire un test en envoyant un mail en local depuis le compte `orel@prout.com` vers le compte `toto@prout.com`

```
orel@prout$ echo "testing message" | mail -s "test" toto@prout.com
```

Regarder les logs :

```
$ tail /var/log/exim4/mainlog
2023-11-07 10:08:25 Warning: No server certificate defined; will use a selfsigned one.
 Suggested action: either install a certificate or change tls_advertise_hosts option
2023-11-07 10:08:25 exim 4.95 daemon started: pid=28661, -q30m, listening for SMTP on [127.0.0.1]:25
2023-11-07 10:21:16 1r0IGq-0007bJ-3i <= orel@prout.com U=orel P=local S=363
2023-11-07 10:21:16 1r0IGq-0007bJ-3i => toto <toto@prout.com> R=local_user T=mail_spool
2023-11-07 10:21:16 1r0IGq-0007bJ-3i Completed
```

Consulter les mails avec `mail` ou `mutt` depuis le compte `toto` :

```
toto@prout:~$ mail
"/var/mail/toto": 1 message 1 unread
>U   1 orel               mar. nov.  7 10:  21/516   test
?
Return-path: <orel@prout.com>
Envelope-to: toto@prout.com
Delivery-date: Tue, 07 Nov 2023 10:21:16 +0100
Received: from orel by prout.com with local (Exim 4.95)
	(envelope-from <orel@prout.com>)
	id 1r0IGq-0007bJ-3i
	for toto@prout.com;
	Tue, 07 Nov 2023 10:21:16 +0100
Subject: test
To: <toto@prout.com>
User-Agent: mail (GNU Mailutils 3.14)
Date: Tue,  7 Nov 2023 10:21:16 +0100
Message-Id: <E1r0IGq-0007bJ-3i@prout.com>
From: orel <orel@prout.com>
X-UID: 3
Status: O
Content-Length: 16
Lines: 1

testing message
```

Faire la même chose avec Telnet (sans STARTTLS).

```
toto@prout.com$ telnet localhost 25
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
220 prout.com ESMTP Exim 4.95 Ubuntu Tue, 07 Nov 2023 10:32:30 +0100
EHLO prout
250-prout.com Hello localhost [127.0.0.1]
250-SIZE 52428800
250-8BITMIME
250-PIPELINING
250-PIPE_CONNECT
250-CHUNKING
250-STARTTLS
250-PRDR
250 HELP
MAIL FROM: <toto@prout.com>
250 OK
RCPT TO: <orel@prout.com>
250 Accepted
DATA
354 Enter message, ending with "." on a line by itself
Subject: test
To: <orel@prout.com>
From: <toto@prout.com>
pouet pouet
.
250 OK id=1r0IT8-0007he-RC
QUIT
221 prout.com closing connection
Connection closed by foreign host.
```

### Enable TLS + AUTH LOGIN dans Exim4

Nota Bene : on ne veut le AUTH LOGIN que dans TLS pour des raisons évidentes de
sécurité !

* <https://wiki.debian.org/Exim#TLS_and_authentication>
* <https://bobcares.com/blog/exim4-smtp-authentication/>

```
cp /etc/ssl/private/ssl-cert-snakeoil.key exim.key
cp /etc/ssl/certs/ssl-cert-snakeoil.pem exim.crt
chmod 640 exim.key exim.crt
chgrp Debian-exim exim.key exim.crt
openssl x509 -in exim.crt -text -noout
```

En unsplit config, on peut ajouter dans /etc/exim4/exim4.conf.localmacros

```
MAIN_TLS_ENABLE = yes
```

Ajouter dans `exim4.conf.template` (ou dans
`conf.d/main/03_exim4-config_tlsoptions`) :

```
### section main/03_exim4-config_tlsoptions ###
MAIN_TLS_ENABLE = yes
daemon_smtp_ports    = 25 : 465
tls_on_connect_ports =      465
# pour permettre AUTH LOGIN tout le temps, même en clair !
# auth_advertise_hosts = *
# AUTH LOGIN uniquement avec TLS
auth_advertise_hosts = ${if eq{$tls_cipher}{}{nope}{*}}
```

Concernant l'authentification, il faut décommenter dans le fichier
`/etc/exim4/exim4.conf.template`  (ou `conf.d/auth/30_exim4-config_examples`)

la section `login_server:` et l'adapter si
besoin...





Concernant le password :

```
touch /etc/exim4/passwd
chmod 640 /etc/exim4/passwd
chgrp Debian-exim /etc/exim4/passwd
```

Puis ajouter les comptes utilisateurs avec la commande `/usr/share/doc/exim4-base/examples/exim-adduser`

```
$ cat /etc/exim4/passwd
tutu:$1$AlO7$kwlCzfh0/eoGXZWEyZ0RV.:tutu
toto:$1$FG3L$AiY2ehTYYymp1HQdGowLQ.:toto
```

<https://wiki.sharewiz.net/doku.php?id=exim4:enable_smtp-auth_with_pam>
<https://www.exim.org/exim-html-current/doc/html/spec_html/ch-smtp_authentication.html>

Puis on redémarre tout ça :

```
update-exim4.conf && service exim4 restart
```

on vérifie :

```
$ netstat -tlpn | grep exim
tcp        0      0 0.0.0.0:25              0.0.0.0:*               LISTEN      214598/exim4
tcp        0      0 0.0.0.0:465             0.0.0.0:*               LISTEN      214598/exim4
```

test :

```
openssl s_client -crlf -connect localhost:465
EHLO test
```

puis :

```
# test en clair (port 25, sans AUTH)
./sendmail.py --load config/demo-local-secure.json -v
# test en TLS (port 465, avec AUTH LOGIN)
./sendmail.py --load config/demo-local-secure.json -v
```

```
$ man 5 exim4_passwd
```
/etc/exim4/passwd contains account and password data for SMTP authentication
when the local exim is SMTP server and clients authenticate to the local exim.

Debug :

```
tail /var/log/exim4/mainlog
```

## Installation de Dovecot

Test avec POP3 (110) branché sur la même mbox...

```
echo "hello world..." | mail toto@prout.com -s "test"
```

certtool --infile /etc/ssl/certs/ssl-cert-snakeoil.pem -i

## Docker image

Mettre en place une image docker/podman de test !

* https://hub.docker.com/r/dovecot/dovecot/

* Submission on 587 (SMTP STARTTLS)
* POP3 on 110, TLS 995
* IMAP on 143, TLS 993
* LMTP on 24
* default configuration which accepts any user with password `pass`

```
$ docker run -d -p 143:143 -p 993:993 -p 587:587 dovecot/dovecot
```

---