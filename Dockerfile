FROM debian:bookworm-slim

ARG ZEROTIER_VERSION
ARG CONTAINER_VERSION
ENV ZEROTIER_LOCAL_SETTING_primaryPort=9993

LABEL org.opencontainers.image.source https://github.com/MyStarInYourSkyCloud/docker-zerotier
LABEL org.opencontainers.image.description ZeroTier is a secure network overlay that allows you to manage all of your network resources as if they were on the same LAN.

ADD entrypoint.sh /docker/entrypoint.sh

RUN apt-get update \
    && apt -y --no-install-recommends install curl gnupg2 ca-certificates jq iputils-ping traceroute iproute2 \
    && echo "deb [signed-by=/etc/apt/keyrings/zerotier.gpg] https://download.zerotier.com/debian/bookworm bookworm main" > /etc/apt/sources.list.d/zerotier.list \
    && mkdir -p /root/.gnupg \
    && chmod 700 /root/.gnupg \
    && gpg --no-default-keyring --keyring /tmp/zerotier-apt-keyring.gpg --recv-keys 0x1657198823e52a61 \
    && gpg --no-default-keyring --keyring /tmp/zerotier-apt-keyring.gpg --export --output /etc/apt/keyrings/zerotier.gpg \
    && rm -r /root/.gnupg \
    && apt update \
    && apt -y --no-install-recommends install zerotier-one=${ZEROTIER_VERSION} \ 
    && service zerotier-one stop \
    && rm -rf /var/lib/zerotier-one/* \
    && chown root:root /var/lib/zerotier-one/ \
    && apt clean autoclean \
    && apt autoremove --yes \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/ \
    && rm /tmp/zerotier-apt-keyring.gpg

VOLUME /var/lib/zerotier-one/
WORKDIR /var/lib/zerotier-one

HEALTHCHECK CMD /bin/bash -c 'if [[ $(curl -s -H "X-ZT1-Auth: $(cat /var/lib/zerotier-one/authtoken.secret)" http://localhost:${ZEROTIER_LOCAL_SETTING_primaryPort}/status | jq -r ".online") == "true" ]]; then exit 0; else exit 1; fi'

ENTRYPOINT ["/bin/bash", "/docker/entrypoint.sh"]
