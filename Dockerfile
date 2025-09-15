# Copyright (c) Forge
# SPDX-License-Identifier: MPL-2.0

FROM docker.io/library/ubuntu:24.04

RUN apt-get update -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        locales \
        rsyslog \
        systemd \
        systemd-cron \
        sudo \
        ssh

RUN apt-get clean

RUN rm -Rf /var/lib/apt/lists/*
RUN rm -Rf /usr/share/doc
RUN rm -Rf /usr/share/man

RUN sed -i 's/^\($ModLoad imklog\)/#\1/' /etc/rsyslog.conf

RUN locale-gen en_US.UTF-8

RUN rm -rf /usr/lib/python3.12/EXTERNALLY-MANAGED

RUN rm -rf /sbin/init
RUN ln -s /lib/systemd/systemd /sbin/init

RUN rm -f /lib/systemd/system/systemd*udev*
RUN rm -f /lib/systemd/system/getty.target

RUN systemctl enable ssh

RUN useradd -m forge
RUN echo "forge ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
RUN echo "forge:forge" | chpasswd

RUN mkdir -p /home/forge/.ssh
RUN chmod 700 /home/forge/.ssh
RUN chown forge:forge /home/forge/.ssh

COPY ssh/authorized_keys /home/forge/.ssh/authorized_keys
RUN chmod 600 /home/forge/.ssh/authorized_keys
RUN chown forge:forge /home/forge/.ssh/authorized_keys

EXPOSE 22

CMD ["/sbin/init"]
