FROM johannweging/base-debian:latest

ARG SEAFILE_VERSION

ENV SEAFILE_VERSION=${SEAFILE_VERSION}

RUN set -x \
&& apt-get install -y python2.7 libpython2.7 python-mysqldb \
      python-setuptools python-imaging python-ldap sqlite3 \
      python-memcache nginx locales procps \
&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN set -x \
&& echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
&& dpkg-reconfigure locales

RUN set -x \
&& useradd -d /seafile -M -s /bin/bash -c "Seafile User" seafile \
&& mkdir -p /opt/haiwen /seafile/ \
&& curl -LS https://download.seadrive.org/seafile-server_${SEAFILE_VERSION}_x86-64.tar.gz \
    | tar -C /opt/haiwen/ -xz \
&& chown -R seafile:seafile /seafile /opt/haiwen

ADD rootfs /

RUN chmod +x /seafile-entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/usr/bin/dumb-init"]
CMD ["/seafile-entrypoint.sh"]
