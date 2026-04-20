#!/bin/bash

# start SSH
/usr/sbin/sshd

# and Apache
/usr/sbin/apachectl -D FOREGROUND

