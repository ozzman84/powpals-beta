# Private phone previews

Tailscale Serve exposes two separate local development processes to the existing
tailnet. It does not publish either application through public Funnel. The other
application's HTTPS port 443 route is preserved.

| Preview | Local port | Tailscale HTTPS port | Database |
| --- | --- | --- | --- |
| Bear Lodge | 3105 | 8443 | powpals_beta_revival_development |
| Fictional demo | 3106 | 10000 | powpals_beta_demo_development |

On the phone, connect Tailscale and use https://TAILNET_HOST:8443/ or
https://TAILNET_HOST:10000/, substituting the Mac's actual Tailscale DNS name.
The Mac must remain on and reachable. The demo sign-in page displays sample
credentials; the main site uses existing accounts. No real users or manager roles
were set up as part of these previews.

## Background services

User LaunchAgents keep the processes independent of chat terminal sessions and
restart them if they exit. They run at user login:

- ~/Library/LaunchAgents/com.powpals.phone-preview.plist
- ~/Library/LaunchAgents/com.powpals.demo-preview.plist

Both run bin/dev in this checkout with the exact private hostname allowed.
The demo additionally sets POWPALS_DATABASE=powpals_beta_demo_development,
PORT=3106 and PIDFILE=tmp/pids/demo-server.pid. Separate PID files avoid Rails
mistaking the other preview for an already running server. The demo disables
external weather API calls; it still shows catalog and seeded skier counts.

The demo uses _powpals_demo_session rather than the main cookie, so testing the
sample sign-in does not replace the main site's session cookie. Google sign-in
is not offered in the fictional demo. It uses the normal password sign-in form.

Logs are in ~/Library/Logs/PowPals/. Check a service with:

```sh
launchctl print gui/$(id -u)/com.powpals.phone-preview
launchctl print gui/$(id -u)/com.powpals.demo-preview
```

Stop a service, without removing its saved plist or any data:

```sh
launchctl bootout gui/$(id -u)/com.powpals.demo-preview
```

Load it again with launchctl bootstrap and its exact plist path. Do not launch a
second manual process on the same local port while its LaunchAgent is running.

## Tailscale routes

```sh
tailscale serve --bg --https=8443 http://127.0.0.1:3105
tailscale serve --bg --https=10000 http://127.0.0.1:3106
```

Stop only the desired proxy using tailscale serve --https=10000 off (demo) or
--https=8443 off (main). Do not use serve reset; that would also remove the other
application's route.

The main Google OAuth client must permit the exact callback
https://TAILNET_HOST:8443/accounts/auth/google/callback, including its port.
This is a Google client setting, not a reason to change the existing password or
client secret. Local development email opens on the Mac through letter_opener.
