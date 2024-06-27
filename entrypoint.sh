#!/bin/bash

# Set ZeroTier Auth Info
if [ "$ZEROTIER_NODE_AUTHTOKEN" != "" ]
then
  echo -n $ZEROTIER_NODE_AUTHTOKEN > /var/lib/zerotier-one/authtoken.secret
  chmod 600 /var/lib/zerotier-one/authtoken.secret
fi

# Set ZeroTier Public Identity
if [ "$ZEROTIER_NODE_PUBLICIDENTITY" != "" ]
then
  echo -n $ZEROTIER_NODE_PUBLICIDENTITY > /var/lib/zerotier-one/identity.public
  chmod 644 /var/lib/zerotier-one/identity.public
fi

# Set ZeroTier Secret Identity
if [ "$ZEROTIER_NODE_SECRETIDENTITY" != "" ]
then
  echo -n $ZEROTIER_NODE_SECRETIDENTITY > /var/lib/zerotier-one/identity.secret
  chmod 600 /var/lib/zerotier-one/identity.secret
fi

# Setup ZeroTier Network
if [ "$ZEROTIER_NETWORK_ID" != "" ]
then
  mkdir -p /var/lib/zerotier-one/networks.d/
  touch "/var/lib/zerotier-one/networks.d/${ZEROTIER_NETWORK_ID}.conf"
fi

# Create TUN/TAP
mkdir -p /dev/net
mknod /dev/net/tun c 10 200

# Build Management Subnets
export ZEROTIER_SETTING_INTERFACEPREFIXBLACKLIST=$(echo \"${ZEROTIER_SETTING_INTERFACEPREFIXBLACKLIST}\" | jq -c 'split(",")')
export ZEROTIER_SETTING_ALLOWMANAGEMENTFROM=$(echo \"${ZEROTIER_SETTING_ALLOWMANAGEMENTFROM}\" | jq -c 'split(",")')

# Render Jinja2 Local Config
envsubst < /docker/local.conf.j2 > /var/lib/zerotier-one/local.conf

# Start App
zerotier-one -U -p${ZEROTIER_SETTING_PRIMARYPORT}
