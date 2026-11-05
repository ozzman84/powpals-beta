# First seven features — local review

Tracker: #158. Production deployment remains excluded.

| Story | Delivered behavior |
| --- | --- |
| #159 Invite-only access | Hide house navigation from ordinary skiers; prevent self-enrollment; manager-created, email-bound, seven-day invitations with hashed tokens, explicit acceptance and revocation. Existing restored memberships are preserved. |
| #160 Seasonal directory | Reuse profiles and pass history; separate seasonal roster, responsibilities, pets, pet rules and optional preferences. Sharing email/phone defaults off and requires the member's consent. Former members of the configured current season and revoked memberships lose private access. Managers can change permission roles separately from descriptive responsibilities. |
| #161 Sleeping inventory | Add/edit rooms and permanent or temporary sleeping spaces, labels, capacities, notes and an HTTPS layout reference. Explicit capacities remain intact; size defaults fill legacy nulls. House occupancy and parking limits remain advisory. |
| #137 Calendar integration | Preserve staying/away/undecided calendar and historical entries. Weekly totals include approved named guests and their additional cars; checkout is excluded. Existing manual guest/car counts mean additional unnamed guests/cars and must not duplicate named stays. |
| #43 Bed requests | Dated requests with space counts are distinct from confirmed assignments. Managers confirm; confirmed spaces cannot overlap beyond bed capacity. Pending roommate requests take priority over guest requests. Cancellation releases related guest assignments. |
| #48 Named guest stays | Host-linked named guests, requested/approved/declined/cancelled states, email-bound invitation acceptance and a narrow own-stay portal. Guests gain no general house membership, roster access or full financial access. Duplicate overlapping guest requests in the same house are rejected. |
| #162 Guest charges | Only guests incur guest fees; roommates' own stays are never charged. No free allowance. Accountant explicitly posts approved stays once, by occupied month, with rate snapshots. Guest and host share one balance; either can be identified as payer on accountant-recorded receipts. |

## Cancellation and changes

Unpaid guest charges are voided, retained for audit and excluded from active totals
when a stay is cancelled. Paid charges cannot be erased: cancellation is blocked
pending refund reconciliation. Refund execution is outside these stories. Charged
stays cannot be moved back to requested status or reopened after cancellation;
create a replacement request after reviewing the original. No money moves through
the app. Posting twice never duplicates charges or silently replaces their rates.

## Invitations and private previews

Invitations generate links for a manager or host to share privately. Nothing sends
email or SMS automatically. The recipient signs in or registers with the invited
email, then explicitly accepts. Links expire after seven days; create a new one if
needed. House and guest acceptance are separate from approval of a guest stay.

The isolated demo now includes seasonal rosters, named guest stays, bed requests,
and posted guest charges. Guest account: guest@powpals.test, using the shared demo
password shown on its sign-in page. This account can see its own guest stays only.
Other sample roles remain manager demo@powpals.test, accountant pal2@powpals.test,
collector pal3@powpals.test and member pal1@powpals.test.

The real house roster, roles, rates, pass dates, physical bed inventory and parking
limits remain for Ozzie to confirm (#154). No fictional users were seeded into the
real house. The original historical database remains unchanged. New migrations
were applied only to revival, test and isolated demo databases. Weather remains
blocked by the disabled provider key (#157).

## Validation

RSpec covers invitation identity/expiry/revocation, seasonal renewal and privacy,
room/bed authorization, dated assignment conflicts, named guest attendance and
checkout, roommate fee exemption, monthly billing idempotence/rate snapshots,
shared balances and cancellation audits. A phone-width system flow traverses the
directory, guest request, bed request, accountant posting and limited guest portal.
Full preflight includes Ruby and ERB lint, CSS build, RSpec, Brakeman and dependency
audit. Private HTTPS previews are checked after restart.

Final validation: 199 RSpec examples pass; 175 Ruby files and 55 ERB templates
are clean; Brakeman reports zero warnings; refreshed dependency audit reports no
vulnerabilities; eager loading passes. Live HTTPS checks confirm manager,
accountant, collector, member and limited guest access boundaries.
