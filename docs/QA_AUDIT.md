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

## Story #181 — shared Slate surfaces and people stacks

Slate surfaces now extend through rooms, personal/shared calendars, seasonal
members, guest stays, bed requests, season policies, accounting, rent collection
and personal balances. The application background shares the same slate palette.
Both attendee stacks use shared/attendee_stack and one Stimulus controller. The
final circle always shows the total, including unnamed guests. Calendar cells
use a compact stack; weekly rows use the larger stack. Hover expands icons with
names; clicking opens a native dialog with enlarged icons and preferred names
underneath. Fallbacks use full names or the guest name supplied by the host.

The dialog supports Escape, Close, backdrop dismissal and focus restoration.
Unnamed guests are counted separately without inventing profiles. Shared monthly
and weekly attendance now use one scoped aggregation with checkout excluded and
only approved named guests. Existing house permissions remain enforced.

Full preflight: 227 RSpec examples passed; Ruby/ERB lint, CSS build, Brakeman and
refreshed dependency audit clean. Dialog and overflow checks cover 320, 390 and
1366px. The final mobile stack spacing was checked again after visual review.

## Story #182 — empty calendar days and guest approval

Shared calendar days with no occupants no longer render a zero badge. Weekly
summary rows retain their zero counts. Every active non-guest house role can
request a guest stay, with the current member recorded as host. Submitted approval
status is ignored during creation. Only the admin role can approve or manage guest
statuses; lease holders no longer inherit guest approval from house editing
permissions. Hosts retain cancellation of their own guest stays.

Role coverage exercises invitation creation, forged approval requests, approval
controls and host cancellation for every non-guest role. Responsive calendar
checks verify that empty days have neither a count badge nor an opener.

## Story #183 — scrollable attendee dialog

The attendee dialog keeps three columns and renders every named attendee. Its
people area scrolls vertically within the screen height while the heading, Close
button and total remain visible. Long lists can be scrolled by touch, wheel or
keyboard. A crowded-list browser regression covers 18 attendees at phone and
desktop widths and checks that the final person can be reached.

## Story #184 — roommate portrait-card directory

Roommates on the overview and seasonal Members page use the supplied portrait-card
layout: large circular profile photo or initials, preferred name, skiing details,
actual role badge and a divided contact footer. The responsive grid has one column
on phones and up to four on desktops. Seasonal information remains visible;
authorized editing is available under Edit member details.

Email and Call links render only when the member opted into sharing contacts for
that season. The overview uses the configured current season's consent. No new
members, roles or contact-sharing preferences are assigned by this design change.
Regression checks cover contact-link consent in both views, 128px portrait sizing,
responsive columns, overflow and saving member preferences from the card.

## Story #185 — compact cards, full-detail modals and social sharing

Card faces show preferred/first name plus last name, portrait, riding summary,
actual role and permitted contact/social actions. Season labels, placeholder pet
information and preferences moved into the detail dialog. The pencil opens a
scrollable modal with complete seasonal details and authorized editing. Managers
assign existing roles and access using the existing protected roommate endpoint;
others receive read-only details for other members.

Members manage up to ten named HTTPS social links with per-link house-sharing
consent. Instagram, X and Facebook use platform marks; other links use a link icon.
Private URLs are omitted from other members' rendered cards and dialogs. Managers
cannot change another member's social-link consent. Unsafe URLs and embedded login
credentials are rejected. Sharing settings are scoped to the house season.

The additive social_links JSONB migration was applied to the local, demo and test
databases. Three fictional Bear Lodge demo contacts show Email/Call and sample
social icons. The example social URLs lead to platform landing pages, not invented
personal profiles. No real member sharing settings or role assignments changed.

## Story #186 — bed requests within Rooms

Rooms now contains the sleeping inventory and a Requests & assignments section,
including the existing request form, assignment list and authorized status controls.
The top-level Bed requests navigation item is removed. Existing request-page URLs
redirect to Rooms#bed-requests, and create/update/error redirects return there.
The overview's Requests & assignments link points to the same section. Host
cancellation, guest selection, house scoping and manager confirmation remain intact.

## Story #187 — main merge verification and coverage

Added request-level tests for invalid bed dates, over-capacity confirmation,
manager confirmation, host cancellation, successful room edits, blank/duplicate
names, ordinary-member denial and foreign-house room IDs. Social-link tests cover
malformed URLs and both sides of the ten-link limit. Test season-pass names now
use a deterministic sequence to prevent random uniqueness collisions.

SimpleCov tracks every application Ruby file, enforces at least 85% line coverage
and reports branch coverage. Full preflight on the merge candidate: 238 examples,
zero failures; line coverage 85.80% (1402/1634); branch coverage 70.38% (354/503).
Ruby/ERB lint, CSS build, Brakeman and refreshed dependency audit pass. Coverage
is a regression floor, not a claim that every path is tested. Production deployment
remains excluded. Existing local README edits are kept outside the merge.
