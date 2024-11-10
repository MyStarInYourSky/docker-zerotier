# docker-zerotier

Debian based ZeroTier Container

Automatically built with Github Workflows.

## Environment Variables

| Variables                                | Description                                                                                                            | Required | Default |
|------------------------------------------|------------------------------------------------------------------------------------------------------------------------|----------|---------|
| `ZEROTIER_NODE_AUTHTOKEN`                | Allows for a pre-set authtoken (authtoken.secret) to be set.                                                           | `False`  | `n/a`   |
| `ZEROTIER_NODE_PUBLICIDENTITY`           | Allows for a pre-set public identity (identity.public) to be set.                                                      | `False`  | `n/a`   |
| `ZEROTIER_NODE_SECRETIDENTITY`           | Allows for a pre-set secret identity (identity.secret) to be set.                                                      | `False`  | `n/a`   |
| `ZEROTIER_PLANET`                        | Allows for custom ZeroTier Planet to be set. Must be encoded in base64.                                                | `False`  | `n/a`   |
| `ZEROTIER_NETWORK_ID`                    | Sets networks to join. Networks should be seperated by commas without spaces in between the networks.                  | `True`   | `n/a`   |
| `ZEROTIER_LOCAL_SETTING_${LocalSetting}` | Allows for values in the settings section of `local.conf` to be set. The setting name is defined by `${LocalSetting}`. | `False`  | `n/a`   |
| `ZEROTIER_LOCAL_SETTING_primaryPort`     | Sets the primary port that ZeroTier will listen on.                                                                    | `False`  | `9993`  |
