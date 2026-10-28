# Seasons, guest fees, expenses and sheet references

Stories #143–145 add a house navigation item: Seasons & guest fees. Ordinary
house members can read their house's seasonal history. Guest memberships cannot
read financial operations. Only house admins and lease holders can edit policies,
add entries or record receipts. Every nested season, entry and receipt is scoped
to its house. No users, invitations, manager roles or payment recipients were set up.

## Separate seasons and policies

The upcoming rental remains November 1, 2026 through April 30, 2027. Its guest
rates, rent, participant count, rules and payment instructions are unconfirmed.
Historical rates never automatically become current rates. Policies are draft,
reference or confirmed. Quotes require a confirmed seven-day rate schedule.

Quotes count occupied nights and exclude checkout. An explicitly configured
free-night allowance applies per guest per stay. Dog fees require an amount and
an explicit per-night or per-stay basis. Estimating never creates a charge or
transfers money. Historical policies disagree: a 2022 screenshot describes one
free night and $25 extras, later notes mention $50 nightly, and the detailed
sheet specifies Monday–Wednesday $30 and Thursday–Sunday $50. The $25 dog fee's
period is unspecified. These differences remain visible reference notes.

House rules and departure instructions are editable text, displayed with safe
HTML handling. Historical instructions are labeled by their source year. They do
not automatically create current pet approvals, chores, events, payment targets,
late fees or guaranteed bed reservations. The old rent participant/lease counts
are separate from physical sleeping capacity and parking.

Season records organize financial/source history. The house's active stay-calendar
limits remain its season_start/season_end settings under Edit house. Editing a
historical source season never moves confirmed stays or changes that active window.

## Historical sheet import findings

The latest attached TSV contains two sections with different date headers:

- The day plan is November 1, 2024–May 1, 2025. All participant date cells are
  blank. They remain unknown; no away records or current accounts were fabricated.
- The bed-request grid is November 1, 2023–April 30, 2024. Its 137 populated cells
  were preserved as dated source annotations with the original room, bed and text.
  Repeated labels across bed rows are not counted as distinct people or fees.
- Existing imported calendar history remains unchanged: 205 records. Bed labels
  have not been matched to user accounts or substituted for actual stay records.

The generic TSV importer uses each section's date header and keeps blanks separate
from explicit zero (away), one (staying) and larger counts (one member plus guests).
Repeated imports with the same stable source key do not duplicate records. Changed
or removed populated cells fail and roll back pending changes for review. Ambiguous
day-plan values also fail instead of guessing an occupancy count.

```sh
LODGING_ID=1 SOURCE_KEY=historical-sheet SHEET_PATH=/private/backup/source.tsv \
  rbenv exec bundle exec rake history:stay_sheet
```

The task only permits local development on powpals_beta_revival_development,
without DATABASE_URL. It does not change the original historical database.

## Ledger and receipts

Money is stored in integer cents. Entries have a season, accounting month,
description, guest-fee/expense category and positive amount. Entries and receipts
are append-only through the UI. Exact financial corrections/refunds are not
inferred or generated from source notes; reconcile them explicitly before posting.

Manual receipts require a date and retain the entering account and optional
external reference. They can be partial, but cannot exceed the outstanding
balance. Receipt writes lock the entry while validating the balance. Recording a
payment does not connect to Venmo, charge anyone, transfer money or verify a bank.

The supplied 2023–24 financial table was privately transcribed into 31 entries:
29 guest fees totaling $3,420 and two expenses totaling $340. Its Y flags create
source-reported receipts with no invented exact date or transaction identifier.
The two Pending expenses remain unreimbursed. The six monthly nets reconcile to
the pasted summary: November -$190, December $1,460, January $830, February $730,
March $250 and April $0. Net means fees received less expenses incurred, including
pending reimbursements; it is not a bank balance or proof of a payout.

The rent table is historical reference only. Its $6,300 monthly rent and 16-way
split produce exact cents plus explicit remainder penny allocations. Lease caps
do not become occupancy limits. Unclear deposit/rollover notes and fractional
per-head payout figures were retained as notes rather than invented transactions.

HouseFinancialReferenceImport accepts reviewed rows for reference seasons only,
is repeatable, and refuses to overwrite a changed imported row. Source-reported
payment status is distinct from manual receipt dates and actual bank verification.

## Private sources and verification

Original TSV copies, the rules screenshot, the financial transcription and a
pre-import revival database archive are under the private local folder
~/code/backups/powpals/2026-10-28-sheets/. None are in Git. Only generic importer
code and synthetic regression data are committed. The source database and earlier
full backup remain intact.

The phone acceptance test exercises confirming a policy, calculating occupied
nights, creating a fee and recording a partial payment at a 390px viewport, with
no horizontal page overflow. Regression checks cover privacy, nested resource
boundaries, partial payments, overpayments, source revisions, date years, blanks,
explicit zeros, draft policies, free nights, dog-fee basis and exact-cent parsing.
