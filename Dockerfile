# Dockerfile for Local Mail Agent

# Build with: debian 12
FROM debian:bookworm

LABEL maintainer="aurelien.esnard@u-bordeaux.fr"
WORKDIR /home/docker
ARG DEBIAN_FRONTEND=noninteractive

### apt tools
RUN apt update
RUN apt install -yq build-essential apt-utils apt-file

### set locales
RUN apt install -yq locales-all
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

### misc tools
RUN apt install -yq bash bash-completion
RUN apt install -yq man-db
RUN apt install -yq coreutils
RUN apt install -yq moreutils sudo
RUN apt install -yq emacs-nox nano

### network tools
RUN apt install -yq net-tools wget curl
RUN apt install -yq tcpdump inetutils-ping
RUN apt install -yq netcat-openbsd telnet
RUN apt install -yq openssl ssl-cert
RUN apt install -yq exim4
RUN apt install -yq dovecot-pop3d

### clean
RUN apt-get -y autoremove

### add user toto
RUN useradd -ms /bin/bash toto
RUN echo 'toto ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
RUN gpasswd -a toto sudo
RUN echo "toto:toto" | chpasswd
RUN chown -R toto:toto /home/toto

### add user tutu
RUN useradd -ms /bin/bash tutu
RUN echo 'tutu ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
RUN gpasswd -a tutu sudo
RUN echo "tutu:tutu" | chpasswd
RUN chown -R tutu:tutu /home/tutu

### config exim4 (smtp server)
RUN echo 'pouet.com' > /etc/mailname
COPY ./config/exim4/update-exim4.conf.conf /etc/exim4/
RUN update-exim4.conf

### enable TLS & AUTH in exim4
COPY ./config/exim4/03_exim4-config_tlsoptions /etc/exim4/conf.d/main/
COPY ./config/exim4/30_exim4-config_examples /etc/exim4/conf.d/auth/
RUN cp /etc/ssl/private/ssl-cert-snakeoil.key /etc/exim4/exim.key
RUN cp /etc/ssl/certs/ssl-cert-snakeoil.pem /etc/exim4/exim.crt
RUN chown root:Debian-exim /etc/exim4/exim.key /etc/exim4/exim.crt
RUN chmod 640 /etc/exim4/exim.key /etc/exim4/exim.crt
COPY ./config/exim4/exim4.passwd /etc/exim4/passwd
RUN chown root:Debian-exim /etc/exim4/passwd
RUN chmod 640 /etc/exim4/passwd
RUN update-exim4.conf

### config dovecot (pop3 server)
COPY ./config/dovecot/dovecot.conf /etc/dovecot/dovecot.conf

### initialize empty mailboxes for toto & tutu
RUN touch /var/mail/toto && chown toto:mail /var/mail/toto
RUN touch /var/mail/tutu && chown tutu:mail /var/mail/tutu

### start services
COPY ./config/app.sh /
CMD /app.sh

### EOF