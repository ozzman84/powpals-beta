# Bear Lodge historical restoration — Story #142

Only Bear Lodge was confirmed as real. Its house history was copied from
powpals_beta_development into the separate powpals_beta_revival_development.
The source database was not migrated, edited, deduplicated, or reset.

## Restored scope

- One house, three accounts and their three linked profiles, three memberships.
- Five rooms, seven beds, and 205 calendar records dated November 2023–May 2024.
- Other houses, unlinked profiles, and unrelated pass/resort/ski-day data are excluded.
- Account 1's second, unlinked profile is retained in the source backup; it was
  not merged or deleted. The profile referenced by Bear Lodge history was copied.
- Source passwords, confirmation status, and account lock state are preserved.
  Transient password-reset, confirmation, remember-session and unlock tokens are cleared.
- Blank membership roles become ordinary roommate memberships. No manager is inferred.
- Historical null guest/car counts become zero, matching the upgraded schema.
- Original historical capacity, draft status and room/bed values are retained.
  They should be reviewed before configuring a current rental season.

These historical records are not proof that the source was a production backup.
Some linked member names and settings may still be practice data. Review them
before treating this as the current season's membership or inventory.

## Private backup

The full original database archive and a selected-house JSON snapshot are stored
outside Git under ~/code/backups/powpals/2026-10-28-bear-lodge/ with private permissions.
The archive includes the original duplicate profiles and excluded houses.
The JSON includes account password hashes and personal information. Never commit,
upload, print, or serve it through the app.

## Commands and safeguards

Use rbenv from the project root. Export refuses to overwrite an existing path:

```sh
rbenv exec bundle exec ruby bin/export-bear-lodge /private/backup/new-snapshot.json
SNAPSHOT=/private/backup/new-snapshot.json rbenv exec bundle exec rake history:bear_lodge
```

The task defaults to a dry run: it inserts into a transaction, verifies database
constraints, reports counts, then rolls back. APPLY=true commits the same operation.
The task is development-only, rejects DATABASE_URL, and requires the isolated
revival database. The service locks the destination tables and refuses any
nonempty account, profile, house, membership, room, bed or calendar table.
It never overwrites records or silently merges identity conflicts. Foreign-key
or uniqueness failures roll back the whole import. Do not clear a populated
destination merely to rerun it. Use a separately reviewed migration if needed.

The service intentionally bypasses callbacks when copying reviewed historical
values, so it sends no Devise emails and does not apply current-season occupancy
rules to old dates. Database constraints remain enforced; SQL sequences are reset
after successful imports so new records can be created safely.

## Remaining setup

Current-season users, invitations and manager assignments are deferred at the
user's request. Review historical capacity and inventory separately. Then set the
current rental dates, guest limits and parking capacity. Do not infer any of
these values from the old calendar. Production deployment is excluded.
