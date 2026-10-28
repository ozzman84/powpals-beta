# PowPals revival

Branch: revival/local-restoration. Work is organized into story-linked commits.
Production deployment is outside this revival scope.

## Implemented

- Provider-scoped Google identity and safe rejection of existing-email collisions;
  transactional profile creation, password checks, no registration parameter dump.
- Per-house Pundit authorization, nested resource boundaries, manager-only membership
  and room management; restricted guest and archived-house stay writes.
- Ruby 3.4.12 / Rails 8.1.4 and compatible, audited dependencies.
- Duplicate-prevention migrations with explicit stops for existing conflicts.
- Season bounds, guest/car editing, occupancy and parking capacity validation.
- Resilient HTTPS weather requests, background refresh without blocking pages,
  caching with duplicate-refresh prevention, true ten-day ranges, repeatable imports.
- Real house screens, phone-accessible navigation, and removed sample activities.
- Template-derived RuboCop/ERB lint, CI gates, request regression coverage, and
  headless Chrome acceptance coverage. Obsolete empty scaffolds were retired.

## Verification

Latest full run including sheet operations: 139 examples, zero failures, including the
390px phone workflow. Brakeman: zero warnings. Dependency audit: no vulnerabilities.
Ruby lint: 142 files, no offenses. ERB lint: 40 files, clean.
Local development boot and HTTP 200 smoke test also passed; test server stopped.

## Preserved historical data

The upgraded app defaults to powpals_beta_revival_development, a fresh separate
local database. The original powpals_beta_development was not changed or reset.
It contains duplicates and missing manager assignments; importing it remains
a separate, reviewed task. Use POWPALS_DATABASE to select a development database.
See LOCAL_SETUP.md for findings, startup commands, and external-service limits.

## Historical house restoration

Bear Lodge was confirmed and imported into the isolated revival database with
three linked accounts/profiles, three memberships, five rooms, seven beds and
205 historical calendar records. The original database and a private backup
preserve all excluded records. No manager access was inferred. See
HISTORICAL_DATA.md for scope, safeguards and current-season setup still needed.

## Sheet operations

Stories #143–145 add separate seasonal rules/rates, a manual guest-fee and expense
ledger, partial-payment recording and repeatable source-sheet imports. The latest
TSV has a blank 2024–25 day plan and 137 populated 2023–24 bed annotations; these
are preserved as historical observations without changing the 205 existing stays
or matching names to accounts. The 31 historical financial rows reconcile to
the supplied monthly nets. Current 2026–27 rates remain unconfirmed.

Story #146 provides a private Tailscale HTTPS preview, preserving the existing
other-app route and normal sign-in. Users, invitations, manager assignments,
public deployment and money transfers remain excluded.
