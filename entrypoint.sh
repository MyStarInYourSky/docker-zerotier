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

# Setup ZeroTier Network
if [ "$ZEROTIER_PLANET" != "" ]
then
  echo -n "$ZEROTIER_PLANET" | base64 -d > /var/lib/zerotier-one/planet
fi

# Create TUN/TAP
mkdir -p /dev/net
mknod /dev/net/tun c 10 200

# Blacklist Interfaces that ZeroTier wont use
if [ -n $ZEROTIER_LOCAL_SETTING_interfacePrefixBlacklist ]; then
  export ZEROTIER_LOCAL_SETTING_interfacePrefixBlacklist=$(echo \"${ZEROTIER_LOCAL_SETTING_interfacePrefixBlacklist}\" | jq -c 'split(",")')
fi

# Management subnets
if [ -n $ZEROTIER_LOCAL_SETTING_allowManagementFrom ]; then
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

# Start App
zerotier-one -U -p${ZEROTIER_LOCAL_SETTING_primaryPort}
