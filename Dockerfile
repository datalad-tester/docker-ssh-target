FROM neurodebian:latest
MAINTAINER DataLad developers

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y --no-install-recommends eatmydata && \
    eatmydata apt-get install -y --no-install-recommends gnupg locales && \
    echo "en_US.UTF-8 UTF-8" >>/etc/locale.gen && locale-gen && \
    eatmydata apt-get install -y --no-install-recommends \
      git git-annex-standalone datalad p7zip rsync openssh-server \
      apache2 apache2-utils systemd && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN git config --system user.name "Docker Datalad" && \
    git config --system user.email "docker-datalad@example.com"

RUN sed -ri \
      -e 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' \
      -e 's/UsePAM yes/#UsePAM yes/g' \
      /etc/ssh/sshd_config && \
    echo 'MaxSessions 100' >>/etc/ssh/sshd_config && \
    mkdir -p /var/run/sshd

#RUN mkdir -p /ds
ADD apache/store1.conf /etc/apache2/sites-enabled/
ADD apache/store2.conf /etc/apache2/sites-enabled/
ADD apache/git-http-backend.conf /etc/apache2/conf-enabled/
RUN /usr/sbin/a2enmod alias
RUN /usr/sbin/a2enmod cgid
RUN /usr/sbin/a2enmod env
RUN /usr/sbin/a2enmod http2
RUN /usr/sbin/a2enmod rewrite
RUN /usr/sbin/a2enmod ssl

ADD ria-stores /ds/
# TODO: Move htpasswd to ria-stores directly? Disadvantage: Decoupled from user
# setup. So: Possibly Move into setup script instead.
ADD apache/htpasswd /ds/store1/
ADD apache/htpasswd /ds/store2/
ADD server-start.sh /usr/local/bin/

RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -subj "/C=DE/O=DataLad Project/OU=Test Infra/CN=store1.tests.datalad.org" -keyout /etc/ssl/private/store1.pem -out /etc/ssl/certs/store1.pem
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -subj "/C=DE/O=DataLad Project/OU=Test Infra/CN=store1.tests.datalad.org" -keyout /etc/ssl/private/store2.pem -out /etc/ssl/certs/store2.pem

# TODO: git config call per user? -> setup script
# Also: Permissions within stores



EXPOSE 22 80 443

