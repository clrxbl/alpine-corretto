FROM alpine:3.8

MAINTAINER Michael H. <michael@iptables.sh>

ENV JAVA_VERSION=8.212.04.2 \
    JAVA_HOME=/opt/jdk \
    PATH=${PATH}:/opt/jdk/bin \
    GLIBC_REPO=https://github.com/sgerrand/alpine-pkg-glibc \
    GLIBC_VERSION=2.29-r0 \
    LANG=C.UTF-8 \
    JAVA_MD5_CHECKSUM=782d5452cd7395340d791dbdd0f418a8 \
    IGNORE_CHECKSUM=false

RUN set -ex && \
    apk -U upgrade && \
    apk add libstdc++ curl ca-certificates bash && \
    wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub && \
    for pkg in glibc-${GLIBC_VERSION} glibc-bin-${GLIBC_VERSION} glibc-i18n-${GLIBC_VERSION}; do curl -sSL ${GLIBC_REPO}/releases/download/${GLIBC_VERSION}/${pkg}.apk -o /tmp/${pkg}.apk; done && \
    apk add /tmp/*.apk && \
    rm -v /tmp/*.apk && \
    ( /usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 C.UTF-8 || true ) && \
    echo "export LANG=C.UTF-8" > /etc/profile.d/locale.sh && \
    /usr/glibc-compat/sbin/ldconfig /lib /usr/glibc-compat/lib && \
    mkdir /opt && \
    curl -o /tmp/java.tar.gz \
      https://d3pxv6yz143wms.cloudfront.net/${JAVA_VERSION}/amazon-corretto-${JAVA_VERSION}-linux-x64.tar.gz && \
    if [ "${IGNORE_CHECKSUM}" == "false" ]; then echo "Verifying checksum" >&2 && \
      echo "${JAVA_MD5_CHECKSUM}  /tmp/java.tar.gz" > /tmp/java.tar.gz.md5 && \
      md5sum -c /tmp/java.tar.gz.md5 && \
      echo "Files verified"; \
    fi && \
    gunzip /tmp/java.tar.gz && \
    tar -C /opt -xf /tmp/java.tar && \
    ln -s /opt/amazon-corretto-${JAVA_VERSION}-linux-x64 /opt/jdk && \
    apk del curl glibc-i18n && \
    rm -rf /opt/jdk/*src.zip \
           /tmp/* /var/cache/apk/* && \
    echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' >> /etc/nsswitch.conf

# EOF
