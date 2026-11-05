# Adversarial and link audit — November 5, 2026

Story #173, related to feature tracker #158. Production deployment remains excluded.
Tests changed only transactional test data. The live crawl was read-only apart
from normal sign-in/session bookkeeping in the fictional demo.

## Reproduced and fixed

1. Former members regained access after the configured rental season changed.
   Once seasonal membership is managed, access now requires an active matching
   season; legacy memberships with no managed seasonal history are preserved.
2. Last-manager protection counted a former/ineligible manager. It now counts
   only accessible managers.
3. Blank invitation emails attempted a missing user lookup. They now produce
   validation feedback.
4. One nested request could save overlapping pass terms. Parent-account
   validation now checks both persisted and unsaved sibling terms.
5. Removing rooms with bed requests silently failed. The page now explains why
   those assignments must be preserved/reconciled.
6. Bed capacity edits could contradict confirmed assignments. Capacity changes
   now validate the peak upcoming confirmed use; house occupancy stays advisory.
7. The landing page exposed a house link to uninvited skiers/guests. It now uses
   the same membership visibility gate as the main navigation.
8. GitHub authentication links were placeholders. Removed unsupported actions.
9. Profile Cancel did nothing. It now returns to the profile; unfinished manual
   photo upload is explicitly disabled.
10. Demo registration exposed Google login despite being a password-only demo.
    Authentication surfaces consistently hide it in the isolated demo.
11. Mobile-menu photos bypassed the initials fallback. The shared avatar component
    is now used; profile-edit labeling and menu/sign-out interactions are checked.

12. Long member names overflowed phone cards and roster controls. Grids and text
    containers now constrain/wrap content; a deliberate long-name regression
    covers this rather than relying on random fixture values.

## Verification

- Read-only live graph crawl: 219 page requests over anonymous, manager,
  accountant, collector, member and guest access states; three fictional houses.
  No broken GET destinations after fixes. Calendar query pagination was bounded.
- Five distinct same-origin assets loaded successfully. Remaining hash links are
  functional dynamic Add Bed controls, exercised in the real browser system test.
- Phone checks cover 14 main manager pages, dynamic multi-bed forms, profile
  cancellation, mobile menu, sign-out and the prior guest/accountant workflow.
- Explicit role checks continue denying unauthorized finance/collector access;
  guests cannot open house, roster or accounting pages or another guest's visit.
- Main Google OAuth initiation returns a Google redirect with the correct :8443
  callback, and the button image loads. Full external Google sign-in remains a
  user walkthrough, not a simulated provider-login claim.
- Final preflight passes: 212 RSpec examples, 177 Ruby files, 55 ERB templates,
  CSS build, eager loading, zero Brakeman warnings and no dependency vulnerabilities.

## Log review

Reviewed phone/demo launchd stdout and stderr plus application development logs.
Both stderr files were empty. The audit generated no new application 500s. One
older demo 500 was a PG::GroupingError from the earlier resort-query restoration;
current dashboard/profile requests do not reproduce it. Observed 401/403 responses
match anonymous/permission probes; SIGTERM entries match intentional restarts.
Restart-time 502s cleared after server readiness; both private previews returned
200 before the final crawl. No tokens, account details or raw logs are committed.

## Known limits

WeatherAPI key remains disabled (#157). Manual photo upload is not implemented
(#103); Google photos and initials remain available. Invitation delivery uses
private links, not automatic email/SMS. Paid-stay refunds require reconciliation;
they are not executed or silently erased by cancellation. Real seasonal policies,
roster, bed inventory and parking remain #154. Other future features remain #158.

## Quick manual pages

Use the isolated demo at https://macbook-air-2.tail969c8b.ts.net:10000/ with the
shared demo password on its sign-in page. Sign out before changing roles.

| Check | Account | Direct path under the demo host |
| --- | --- | --- |
| Create/revoke/accept house invitations | demo@powpals.test | /users/lodgings/1#house-members |
| Seasonal details, pets, contact consent and access | demo@powpals.test or pal1@powpals.test | /users/lodgings/1/house_members?season_id=1 |
| Rooms, temporary spaces and capacity edits | demo@powpals.test | /users/lodgings/1/rooms |
| Staying/away/undecided, guests and cars | pal1@powpals.test | /users/lodgings/1/calendars/my_calendar |
| Shared calendar | any accepted member | /users/lodgings/1/calendars |
| Dated bed requests and manager confirmation | pal1@powpals.test then demo@powpals.test | /users/lodgings/1/bed_requests |
| Named guest request, approval and cancellation | pal1@powpals.test then demo@powpals.test | /users/lodgings/1/guest_stays |
| Post guest charges once | pal2@powpals.test | /users/lodgings/1/guest_stays |
| Full books and partial guest/host receipts | pal2@powpals.test | /users/lodgings/1/house_seasons/1/finance |
| Rent/deposit collection only | pal3@powpals.test | /users/lodgings/1/house_seasons/1/rent_collection |
| Personal balances only | pal1@powpals.test | /users/lodgings/1/my_payments?season_id=1 |
| Narrow own-stay guest portal | guest@powpals.test | /guest_visits/1 |
| Profile edit and cancellation | any demo account | /user/edit |
| Seasonal pass dates and overlap rejection | any demo account | /edit-profile |

Real Google login: https://macbook-air-2.tail969c8b.ts.net:8443/accounts/sign_in .
Use fictional demo data for create/edit/cancel tests; no real house data is needed.

## Story #180 — Slate overview and daily occupancy

The approved house overview uses a slate background, bordered white panels and
contrasting headers. Each upcoming day shows member and guest occupancy against
advisory capacity, available spaces, cars, identifiable attendees and a final total
circle. Hover/focus spreads avatars; tapping identifies a person on phones.
Unnamed additional guests remain counted without inventing identities. Season,
parking and capacity guidance sit beneath This week. Over-capacity stays remain
allowed with warnings; unset capacity does not imply zero availability.

Verified with full preflight (226 examples), including a phone/desktop regression
for attendee taps and long names. Review the overview on either private preview.
