#!/bin/bash

# Set ZeroTier Auth Token
if [ ! -z "$ZEROTIER_NODE_AUTHTOKEN" ]
then
  echo -n $ZEROTIER_NODE_AUTHTOKEN > /var/lib/zerotier-one/authtoken.secret
  chmod 600 /var/lib/zerotier-one/authtoken.secret
fi

# Set ZeroTier Public Identity
if [ ! -z "$ZEROTIER_NODE_PUBLICIDENTITY" ]
then
  echo -n $ZEROTIER_NODE_PUBLICIDENTITY > /var/lib/zerotier-one/identity.public
  chmod 644 /var/lib/zerotier-one/identity.public
fi

# Set ZeroTier Secret Identity
if [ ! -z "$ZEROTIER_NODE_SECRETIDENTITY" ]
then
  echo -n $ZEROTIER_NODE_SECRETIDENTITY > /var/lib/zerotier-one/identity.secret
  chmod 600 /var/lib/zerotier-one/identity.secret
fi

# Setup ZeroTier Planet
if [ ! -z "$ZEROTIER_PLANET" ]
then
  echo -n "$ZEROTIER_PLANET" | base64 -d > /var/lib/zerotier-one/planet
fi

# Setup ZeroTier Network
mkdir -p /var/lib/zerotier-one/networks.d/
for network in $(find /var/lib/zerotier-one/networks.d/* -regextype egrep -regex '/var/lib/zerotier-one/networks\.d/[0-9a-z]+\.conf' -printf '%f\n'); do
  rm -f /var/lib/zerotier-one/networks.d/${network}.conf
  rm -f /var/lib/zerotier-one/networks.d/${network}.local.conf
done
if [ ! -z "$ZEROTIER_NETWORK_ID" ]
then
  for network in $(echo $ZEROTIER_NETWORK_ID | tr "," "\n")
  do
    touch "/var/lib/zerotier-one/networks.d/${network}.conf"
  done
fi

# Create TUN/TAP
mkdir -p /dev/net
mknod /dev/net/tun c 10 200

# Blacklist Interfaces that ZeroTier wont use
if [ ! -z $ZEROTIER_LOCAL_SETTING_interfacePrefixBlacklist ]; then
  export ZEROTIER_LOCAL_SETTING_interfacePrefixBlacklist=$(echo \"${ZEROTIER_LOCAL_SETTING_interfacePrefixBlacklist}\" | jq -c 'split(",")')
fi

# Management subnets
if [ ! -z $ZEROTIER_LOCAL_SETTING_allowManagementFrom ]; then
  export ZEROTIER_LOCAL_SETTING_allowManagementFrom=$(echo \"${ZEROTIER_LOCAL_SETTING_allowManagementFrom}\" | jq -c 'split(",")')
fi

# Build Local Config
export ZEROTIER_SETTINGS='{}'
while read line ; do
  export SETTING_NAME=$(echo -n $line | awk -F'ZEROTIER_LOCAL_SETTING_' '{print $2}'| awk -F'=' '{print $1}')
  export SETTING_VALUE=$(echo -n $line | awk -F'=' '{print $2}')
  if [[ $SETTING_VALUE = "true" ]] || [[ $SETTING_VALUE = "false" ]] || [[ $SETTING_VALUE =~ ^[0-9]+$ ]] ; then
    export ZEROTIER_SETTINGS=$(echo $ZEROTIER_SETTINGS | jq -r -c ". + {\"$SETTING_NAME\": $SETTING_VALUE}")
  else
    export ZEROTIER_SETTINGS=$(echo $ZEROTIER_SETTINGS | jq -r -c ". + {\"$SETTING_NAME\": \"$SETTING_VALUE\"}")
  fi
done < <(env | grep -i "ZEROTIER_LOCAL_SETTING_")
export ZEROTIER_LOCAL_CONF=$(echo "{}" | jq -r -c ". + {\"settings\": $ZEROTIER_SETTINGS}")
echo $ZEROTIER_LOCAL_CONF > /var/lib/zerotier-one/local.conf

# Make sure we fix permissions
chown -R zerotier-one:zerotier-one /var/lib/zerotier-one

# Start App
zerotier-one -U -p${ZEROTIER_LOCAL_SETTING_primaryPort}
