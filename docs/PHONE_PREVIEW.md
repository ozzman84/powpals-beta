# Private phone preview — Story #146

The existing Tailscale connection is reused. PowPals serves from localhost:3105
and is proxied privately through Tailscale HTTPS port 8443. Another application's
existing HTTPS port 443 route remains unchanged. No public Funnel was enabled.
Normal app authentication remains in place; users and manager roles were not set up.
The private HTTPS URL was tested successfully with HTTP 200.

To restart, use the machine's actual Tailscale DNS name in place of TAILNET_HOST:

```sh
RAILS_DEVELOPMENT_HOSTS=TAILNET_HOST PORT=3105 bin/dev
tailscale serve --bg --https=8443 http://127.0.0.1:3105
```

On the phone, connect Tailscale and open https://TAILNET_HOST:8443/.
The Mac and the development server must remain running. Google sign-in may need
this exact callback URL added to the existing provider configuration; live OAuth
has not been reconfigured by this preview setup. Local development email opens
on the Mac through letter_opener.

Stop this preview proxy without touching the other app:

```sh
tailscale serve --https=8443 off
```

Stop the local foreground bin/dev process with Ctrl-C. Do not use serve reset,
which would also remove other applications' private preview routes.
