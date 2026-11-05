# Local readiness review — November 5, 2026

Production deployment is excluded. These findings concern the private Tailscale
previews and restored local data, not a deployed production system.

| Area | Result | Remaining work |
| --- | --- | --- |
| Sign-in | Google sign-in confirmed by Ozzie; demo password sign-in exercised over HTTPS | None for current review |
| Original interface and catalog | Restored profile, house navigation, rooms, calendars, 43 resorts and four pass catalogs | Continue manual product review as new documents arrive |
| Stay planning | Seasonal bounds, date validation, guests/cars, and soft occupancy/parking warnings tested | Confirm actual sleeping arrangements and parking (#154) |
| Bed inventory | Blank house guidance derives from bed capacities; legacy null capacities use size defaults; explicit bed overrides preserved | Bear Lodge's seven legacy beds imply 11 default spaces, not confirmed occupancy; imported 86 cleared only in revival DB |
| Accounting | One designated accountant per house; managers cannot view full books; integer cents and partial manual receipts | Assign real accountant and reconcile ledger ownership (#154) |
| Rent collection | Separate rent/deposit collection view and scoped receipt writes | Assign real collector and current charges (#154) |
| Member finances | Own assigned entries only; no self-marking charges as paid | Historical unassigned entries intentionally absent from personal balances |
| Historical data | 205 stays, 137 source bed annotations and 31 ledger rows preserved | Historical names are not current membership or proof of bank receipts |
| Ski passes | Explicit season dates, expiry, renewal history and active-only resort filtering | Legacy undated passes remain unknown/inactive until dates are confirmed |
| Weather | LIVE FAILURE: WeatherAPI returned HTTP 403/error 2008, “API key has been disabled.” | Restore account/key or evaluate another provider (#157); provider unchanged |
| Unavailable weather | Existing safe failure path keeps the rest of the dashboard usable; demo disables external calls | Live forecast completeness cannot be verified with disabled key |
| Season configuration | Rental dates November 1, 2026–April 30, 2027 | Confirm rates, rent split, policies and payment instructions (#154) |

## Review accounts

Use the isolated demo preview at https://macbook-air-2.tail969c8b.ts.net:10000/.
The sign-in page lists its fictional accounts and shared demo password.

- Accountant: pal2@powpals.test (Casey Summit).
- Rent collector: pal3@powpals.test (Taylor Woods).
- Ordinary member: pal1@powpals.test (Jordan Snow).
- House manager: demo@powpals.test (Alex Rider); no full-books access.

No real member, accountant or collector assignments were inferred. Payment recording
is manual bookkeeping; Venmo/bank transfers, bank reconciliation, automatic payouts,
refund workflows and guaranteed bed reservations are not implemented by this work.
Pass catalogs are historical reference, not verified current resort entitlement lists.

## Verification and next planning

The automated suite covers privacy against forged IDs and cross-role access,
capacity warnings, pass expiry/renewal, existing house operations and phone layouts.
Live checks exercise HTTPS sign-in, session isolation and all four demo roles.
Private backups precede the capacity cleanup and demo reseed. Demo seeds are repeatable.

Stories #151–153 cover the implemented changes, #155 this review. Keep #154 open for
Ozzie's season decisions, #157 for weather, and #156 for reviewing remaining stories
and future documents. Do not silently promote old policies to current rules.
