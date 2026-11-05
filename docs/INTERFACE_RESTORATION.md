# Original interface and demo data restoration — Stories #147–149

## Original screens

The pre-revival revision db079c5 is the reference for the restored PowPals logo,
dark navigation/header, white content panel, house/room cards, rental forms and
calendar month grids. Profile details, pass lists, ski houses and resort tables
are visible again. The people directory retains its card layout.

The restoration keeps the revival fixes: scoped house permissions, DELETE
sign-out, CSRF protection, safe missing-weather rendering, ten actual forecast
columns, editable guest/car counts, season/parking fields and seasonal ledger
navigation. Real stay activity replaces the original sample invoice/meeting text.
Broken placeholder links are not presented as completed social or booking features.

Personal calendar dates cycle unknown → staying → away → unknown. Old rental
periods remain readable with colored status indicators and no editable day
controls outside the active season. Guest/car details remain available alongside
the original month grid. Both shared and personal grids render on a phone.

Populated ski plans exposed a legacy eager-loading/GROUP BY error. Ranking now
uses a separate aggregate of ski days, retains eligible resorts with no plans,
deduplicates resorts covered by several passes, and excludes day eleven from a
ten-day display. Regression coverage exercises those cases.

## Preserved data and restored catalog

The original powpals_beta_development remains intact: 53 accounts, 36 profiles,
five houses, five rooms, seven beds, 205 calendar rows, 43 resorts and four passes.
The main revival preview keeps only the previously confirmed Bear Lodge subset:
three accounts/profiles, one house, 205 calendar rows, 137 source annotations and
31 historical ledger entries. Current-season user/manager setup remains deferred.

The 43 resorts and four passes are restored additively to the main preview, with
84 distinct pass/resort associations, four matching existing account/pass links,
and three ski-day records for matching imported accounts. Source IDs are mapped
to destination records; unrelated accounts are never created or assigned by name.
The source's duplicate join rows remain intact there and are not duplicated in
the upgraded database. Current destination records are not overwritten.

A private pre-catalog revival database archive and reviewed source snapshot live
under ~/code/backups/powpals/2026-11-05-interface-restoration/. No account data or
private source snapshots are committed. db/historical_catalog.json contains only
historical public resort/pass metadata and relationships, with empty account
collections. It is not a claim about current pass coverage or resort operations.

The original CSV contains 93 rows, including incomplete coordinates/location
fields. Its original `season passes` header is now supported alongside the
underscore aliases, but validation still rejects incomplete records. The demo
uses the preserved complete catalog instead of inventing missing coordinates.

## Explicit, isolated demo seeds

Default db:seed adds no sample users to the real or historical databases. To
create a separate demo with the original FactoryBot workflow:

```sh
POWPALS_DATABASE=powpals_beta_demo_development rbenv exec bundle exec rails db:create db:migrate
POWPALS_DATABASE=powpals_beta_demo_development POWPALS_DEMO=true rbenv exec bundle exec rails db:seed
```

DemoSeedData checks both Rails.env.development? and the exact demo database name,
rejects DATABASE_URL, and refuses test, revival, historical or production targets.
Its repeatable dataset has six fictional people, three houses, nine rooms, 126
stay rows, 43 resorts, four passes, upcoming ski plans and sample accounting.
Repeating the seed command on the same date does not duplicate those records.

Sample sign-in is demo@powpals.test with password PowPals-Demo-Only-2026!.
These intentionally public sample credentials are shown only in the isolated
demo. Use password sign-in there, not Google. Real Bear Lodge credentials are
unchanged. A demo banner and separate session cookie distinguish the sample
site from the main preview; cookies otherwise share a hostname across ports.

## Private previews and security patches

See PHONE_PREVIEW.md for the main and demo background services, separate PID
files, separate ports and targeted shutdown commands. Normal authentication
remains enabled. No public Funnel, Fly deployment, real payment transfers or
current-season role assignments were introduced.

The refreshed security advisory database flagged versions that had passed the
previous handoff. Story #149 patches existing dependencies through bundle install
only: Rails 8.1.4.1 and audited fixes for Rack, Dalli, Nokogiri, Addressable,
Loofah and rails-html-sanitizer. Ruby remains 3.4.12. No bundle update was used.
