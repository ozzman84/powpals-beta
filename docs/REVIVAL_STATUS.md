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

Latest full run before final handoff: 111 examples, zero failures, including the
390px phone workflow. Brakeman: zero warnings. Dependency audit: no vulnerabilities.
Ruby lint: 122 files, no offenses. ERB lint: 36 files, clean.
Local development boot and HTTP 200 smoke test also passed; test server stopped.

## Preserved historical data

The upgraded app defaults to powpals_beta_revival_development, a fresh separate
local database. The original powpals_beta_development was not changed or reset.
It contains duplicates and missing manager assignments; importing it remains
a separate, reviewed task. Use POWPALS_DATABASE to select a development database.
See LOCAL_SETUP.md for findings, startup commands, and external-service limits.
