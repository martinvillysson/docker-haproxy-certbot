FROM haproxytech/haproxy-alpine:latest

# install packages
RUN \
  echo "**** install build packages ****" && \
  apk add --no-cache \
    bash \
    ca-certificates \
    coreutils \
    curl \
    jq \
    procps \
    shadow \
    tzdata \
    patch \
    tar \
    xz \
    git \
    nano \
    openssl \
    certbot \
    supervisor \
    echo "**** cleanup ****" && \
    rm -rf \
    /tmp/* /var/cache/apk/*

# supervisord configuration
COPY conf/supervisord.conf /etc/supervisord.conf
# haproxy configuration
COPY conf/haproxy.cfg /etc/haproxy/haproxy.cfg
COPY haproxy-acme-validation-plugin/ /etc/haproxy
# cert creation script & bootstrap & renewal script
COPY scripts/ /
# renewal cron job
COPY conf/crontab.txt /var/crontab.txt
# install cron job
RUN crontab /var/crontab.txt && chmod 600 /etc/crontab

RUN mkdir /jail

EXPOSE 80 443

VOLUME /etc/letsencrypt

ENV STAGING=false

ENTRYPOINT ["/bootstrap.sh"]
