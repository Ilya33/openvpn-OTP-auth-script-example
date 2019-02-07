# authentication script example with [one-time password](https://en.wikipedia.org/wiki/One-time_password) for OpenVPN


need to add to OpenVPN config:

```
auth-user-pass-verify /PATH_TO_SCRIPT/openvpn_oath_verify.pl via-file
script-security 2
username-as-common-name # without this option openvpn will use cn in the certificate as username
```

it wotks with eTokens, applications like "Google Authenticator", etc.
