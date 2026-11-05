# PowPals revival status — November 5, 2026

Branch: revival/local-restoration. Changes are committed in story-sized blocks.
Production deployment and public Funnel are outside this scope.

## Implemented

- Ruby 3.4.12 / Rails 8.1.4.1 with audited security patches to existing dependencies.
- Verified-provider Google identity handling, transactional profiles, account lock
  handling and safe rejection of existing-email collisions.
- Scoped house permissions and manager-only membership/room controls.
- Season bounds, occupancy and parking validation, guest/car editing and guarded
  stay writes. Weather refresh is cached, asynchronous and safe when unavailable.
- The original branded layout, detailed profile/resort views, house/room cards,
  rental forms and colored calendar grids are restored. New season and manual
  accounting features remain accessible from the original-style house navigation.
- Resort ranking works with populated ski plans and multiple pass coverage.
- Separate seasonal rules/rates, guest-fee estimates, expenses, partial receipts
  and historical source annotations. Current-season policies remain unconfirmed.

## Data

The original historical database is unchanged. The main revival database retains
Bear Lodge, three accounts/profiles, 205 historical stays, 137 bed annotations
and 31 financial entries. Its 43 resorts, four passes and matching existing
account/pass/ski-day relationships have been restored additively.

The separate demo database has six fictional people, three houses, nine rooms,
126 stay entries and a populated catalog/accounting example. Explicit FactoryBot
seeding is repeatable and refuses other database targets. Source snapshots and
backups containing account information remain private and outside Git.

See HISTORICAL_DATA.md, HOUSE_OPERATIONS.md and INTERFACE_RESTORATION.md for source
boundaries and reconciliation. Demo names are not current-season roster changes.

## Verification

Final run: 148 RSpec examples, zero failures; 150 Ruby files and 43 ERB templates
clean; Brakeman zero warnings; refreshed dependency audit clean; eager loading passed.
The suite covers phone and desktop screens, colored stay controls and historical
read-only dates, nested authorization, rates, accounting, source imports and
seed isolation. bin/preflight includes RSpec, Ruby/ERB lint, a CSS build, Brakeman
and a refreshed dependency audit. Eager-loading checks are also run.

Both private Tailscale previews have independent background services. Normal
password sign-in to the demo was exercised over HTTPS and its session cookie was
verified separate from the main site. See PHONE_PREVIEW.md for lifecycle controls.

## Remaining current-season setup

The rental window is November 1, 2026–April 30, 2027. Confirm physical sleeping
capacity (the historical value is still 86), parking, current guest rates, rent
split, rules and payment instructions. Current members, invitations and manager
assignments remain deferred at the user's request. Social messaging/meetups,
guaranteed bed bookings and payment-provider integrations remain separate work.
