# Deliverable 02 — Product Data Audit

| | |
|---|---|
| Project | VELOOP Rewards — Data Analyst Internship, Task 01 |
| Work package | A — Product Data Readiness Audit |
| Version | 1.0 |
| Date | 2026-11-10 |
| Status | Complete for Stage 2 (Days 1–4) |
| Evidence base | Public website sources only (SRC-001…SRC-010); see Source & Verification Register |
| Companion file | `submission/03_data_coverage_matrix/data_coverage_matrix.csv` (A4 matrix + SC1 gaps) |

---

## 1. Purpose and scope

This audit maps the product data VELOOP Rewards will eventually need to support analytics, based **only on public product information**. It covers:

- Product areas, features, user actions, system actions, transactions, states, and measurable outcomes (A1–A3).
- Feature status classification: **Confirmed (Public Documentation)**, **Proposed**, **To Be Verified**.
- At least 10 analytics gaps that could affect future production reporting (SC1; full list in Deliverable 03).

This audit is **not** a product performance analysis. It contains no user counts, earnings, withdrawals, revenue, retention, conversion rates, or any other business metric. No simulated data is used in this deliverable.

## 2. Source and evidence policy

All factual product claims in this document trace to a `SRC-xxx` entry in `registers/source_and_verification_register.csv`.

| Classification used in this audit | Meaning |
|---|---|
| **Confirmed (Public Documentation)** | The feature/statement is published on the official public website (help center, policy pages, in-app UI text). This proves the product *describes* the feature publicly; it does **not** prove production implementation, region availability, or current operational state. |
| **Proposed** | An analytics requirement (event, field, state, KPI) recommended by this audit. Not confirmed to exist in the product today. |
| **To Be Verified** | A fact that public documentation cannot settle and requires product or engineering confirmation (see Assumption Register ASM-001…ASM-008). |

Excluded source: the public GitHub repository `Ilma-gulzar21/VELOop-Rewards` is a student portfolio project and was **not** used as product evidence (SRC-011). Marketing-page figures (e.g., Vercel landing page VE examples) are explicitly illustrative and are excluded from all claims (SRC-009).

## 3. Product context (as publicly documented)

Per the official site's own FAQ (SRC-007) and disclaimer (SRC-006):

- VELOOP Rewards is an **online rewards platform** where eligible users complete supported activities (ads, tasks, spins, referrals, games, and other features) to receive **in-platform rewards** subject to platform rules, validation, and availability.
- The platform is a **promotional rewards and gamified engagement platform**, explicitly *not* a bank, investment service, gambling platform, betting service, or financial institution (SRC-006).
- Rewards, exchanges, withdrawals, rankings, and offers **may be changed, paused, reviewed, delayed, limited, or removed at any time** (SRC-006). The Future Features Notice (SRC-002) restates that features and technical experiences may change as the platform evolves.

**Analytics consequence:** every baseline, KPI, or dashboard definition produced in this project must be versioned, because the product explicitly reserves the right to change mechanics at any time.

## 4. Platform currencies (public documentation)

From the Platform Currency Policy and FAQ (SRC-005, SRC-007):

| Currency | Publicly documented role | Analytics implication |
|---|---|---|
| VEs | Primary platform reward unit; usable in supported redemption flows | Primary unit for reward and wallet KPIs |
| XP | Level progression | Progression/engagement analytics |
| Gems | May be exchangeable into VEs where supported | Exchange flow analytics |
| Tokens | Platform utilities (e.g., buying Gems, Spins, similar items) | In-app consumption analytics |
| Spins | Wheel-based features | Spin feature analytics |
| Badges | Recognition items (feature present per help center "Missions and Badges", SRC-002) | Achievement analytics |

All are **virtual platform-managed credits**, not bank assets or financial instruments (SRC-005). Exchange rates, limits, and pairings are public but **not itemized** and may change (SRC-005) — see GAP-003.

## 5. Product area mapping (A1)

Feature status key: **C** = Confirmed (Public Documentation) · **P** = Proposed · **TBV** = To Be Verified.
"Confirmed" means publicly documented, never "confirmed to be in production" (see ASM-001).

| # | Product area | Feature / module | Feature status | User action | System action | Measurable outcome | Data required (proposed) | Business question |
|---|---|---|---|---|---|---|---|---|
| 1 | Account & Authentication | Registration (`/register`) | C | Create account (name, email, password) | Account created; account record stored | Registered user | user_id, registration timestamp, channel, device/platform | How do registrations behave over time and by channel? |
| 2 | Account & Authentication | Login (`/login`) | C | Log in | Session authenticated (JWT-style auth implied by protected routes) | Successful/failed login | user_id, timestamp, device/platform, session_id (P) | Login success and failure patterns |
| 3 | Account & Authentication | Forgot password (`/forgot-password`) | C | Request password reset | Reset request processed (FAQ: reset email or manual verification, SRC-007) | Reset requested/completed | request timestamp, outcome | Friction in account recovery |
| 4 | Account & Authentication | User profile (`/user-profile`) | C | View/update profile | Profile updated | Profile changed | changed fields, timestamp | Account maintenance behavior |
| 5 | Earning — Ads | Watch Ads (`/watch-Ads`), Watch Ad Bonuses (`/watchAd-bonus`); help: watch-ads, watch-ad-bonuses | C | Start and watch an eligible ad | Ad completion tracked; reward validated (FAQ: "ad tracking delays, invalid completion", SRC-007) | Ad watched; reward credited (or not) | user_id, task/ad id, start & completion timestamps, validation status, reward amount & unit | Ad-based earning volume and failure rate |
| 6 | Earning — Tapping | Tap & Earn (`/tap-n-earn`, `/tap-token`); help: tap-and-earn | C | Perform quick tap interactions | Interaction validated; reward credited | Task completed | same task-event core as row 5 | Tap feature adoption and completion |
| 7 | Earning — Daily | Daily Bonus (`/daily-bonus`); help: daily-rewards | C | Claim daily reward | Daily reward credited (eligibility applied) | Daily reward claimed | claim timestamp, streak context, reward | Daily return rate |
| 8 | Earning — Streaks | Daily Streak (`/daily-streak`); help: streak-rewards | C | Maintain consecutive activity | Streak state updated; streak reward granted | Streak updated/extended | streak length, date, reward | Retention proxy and streak decay |
| 9 | Earning — Spins | Spin the Wheel (`/spin-wheel`); help: spin-the-wheel | C | Consume a Spin on the wheel | Wheel outcome generated; result credited | Spin completed | spin id, cost (Spins), outcome, reward | Spin usage and outcome distribution |
| 10 | Earning — Captcha | Captcha tasks (`/captcha-tasks`); help: solve-captcha | C | Solve captcha task | Task validated; reward credited | Task completed | task id, timestamps, validation status | Task completion quality |
| 11 | Earning — Missions & Badges | Missions and Badges (help: missions-and-badges) | C | Complete mission objectives | Mission completion validated; badge awarded | Mission completed; badge earned | mission id, objectives, badge id, dates | Progression engagement |
| 12 | Earning — Mining | Mine & Earn (help: mining-rewards) | C | Participate in mining activity | Mining outcome processed; reward credited | Mining session completed | session id, duration, reward | Mining participation |
| 13 | Earning — Social | Follow & Earn (help: follow-and-earn) | C | Follow a promoted account/brand | External follow verified (third-party dependency) | Follow verified; reward credited | target, verification timestamp, provider | Third-party earn reliability |
| 14 | Earning — Leaderboards | Leaderboard (`/leaderboard`); help: leaderboard-rewards, weekly-leaderboard-entry | C | Accumulate ranking points | Leaderboard position computed; entry/reward applied | Ranked; reward awarded | period, position, points, reward | Competitive engagement |
| 15 | Earning — Staking / Vault | Staking, Staking Portfolios, Contribution Vault (`/staking`, `/staking/portfolios`, `/contribution-vault`) | C | Allocate virtual credits to a portfolio/vault | Allocation tracked; periodic reward accrual | Allocation made; accrual credited | portfolio id, amount, unit, period, accrual | Long-term commitment behavior |
| 16 | Earning — Codes | Giveaway / promo codes (`/giveaway-code`); help: promo-codes | C | Redeem a promo or giveaway code | Code validated against time/quantity/eligibility rules; denied if expired/revoked/abused (SRC-007) | Code redeemed or denied | code id, timestamp, outcome, deny reason | Campaign effectiveness |
| 17 | Levels & Progression | Level System (`/Lvl-Dashboard`); help: level-system | C | Earn XP | Level/XP updated | Level up | xp delta, level before/after, timestamp | Progression engagement |
| 18 | Wallet | Wallet (`/Wallet`); help: wallet-overview | C | View balances and activity | Balances displayed per platform records; subject to verification, abuse checks, system correction (SRC-007) | Balance view; correction applied | per-currency balances, correction events | Wallet trust and correction volume |
| 19 | Wallet | Gems Exchange Center / Swap Center (`/exchange-center`); help: gems-exchange-center, swap-center | C | Request internal credit conversion | Exchange executed at current rate/limits | Exchange completed | from/to currency, amounts, rate, timestamp | Exchange volume and rate sensitivity |
| 20 | Withdrawal | Payout / withdrawal request (`/Payout`) | C | Choose reward, enter payout details, confirm request | Request created as PENDING; VE debit; verification checks run | Withdrawal requested | withdrawal id, user_id, method, amount, requested timestamp | Withdrawal demand by method |
| 21 | Withdrawal | Withdrawal history (`/withdrawal-history`) | C | View past withdrawal requests | Statuses shown | — | (derived from row 20 lifecycle) | — |
| 22 | Withdrawal | Verification & review (help: reward-verification; withdrawal-verification-policy) | C | Respond to verification if requested | Account/transaction/behavioral/technical/compliance checks; request may be delayed, denied, or reversed (SRC-004) | Withdrawal completed / rejected / reversed / pending | status transitions with timestamps, reason category, verifier | Withdrawal funnel and processing time |
| 23 | Referral | Referral (`/Referral`), invite history (`/invite-history`); help: referral-rewards | C | Share invite link; invited user registers | Referral recorded; "only valid referrals accepted by the platform may qualify"; fixed platform-defined reward logic, not a public percentage (SRC-007) | Referral created / registered / accepted | referral id, referrer, referee, timestamps, accepted flag, reward | Referral funnel and quality |
| 24 | Future features | Lucky Draw, Team Battle, Referral Milestones, Collect Cards, Surprise Rewards, Mystery Rewards (help: `future/*`) | TBV | — (not yet live per public FAQ, SRC-007) | — | — | define at launch | "Are these live now?" → publicly answered: future/upcoming |
| 25 | Safety & Compliance | Anti-fraud, Security & Platform Protection (legal pages; help: multiple-accounts-and-vpn, bot-emulator-autoclicker-rules) | C | (violation) multi-account, self-referral, VPN, bot, emulator, auto-clicker | Detection → reward cancellation, account restriction, or suspension (SRC-007) | Enforcement action taken | action type, rule violated, timestamp, scope | Fraud control effectiveness |
| 26 | Support | Customer service (`/customer-service`); help FAQ mentions tickets | C | Open a support ticket | Ticket created; support response | Ticket opened/resolved | ticket id, category, timestamps | Support demand and categories |
| 27 | Administration | Admin console (`/admin` route present in app) | TBV | — | — | — | define after engineering confirmation | Admin activity audit |
| 28 | Third-party | Advertising & Offerwall (advertising-offerwall-policy) | C | Interact with rewarded ads / offerwall / surveys / external promotions | External validation; policy notes "tracking limitations" (SRC-002) | External task validated | provider, task id, validation timestamp, failure type | External dependency reliability |

## 6. User action inventory (A2) — which steps become measurable events

Public documentation confirms the *existence* of each flow but not how it is instrumented. The event column is therefore **Proposed** for every row (to be finalized in Deliverable 08).

| Feature | Documented user journey (public evidence) | Proposed measurable steps |
|---|---|---|
| Registration | Account creation is the entry point; joining is optional (SRC-007) | `user_registered` (Proposed) |
| Login | Login screen with forgot-password recovery (SRC-007) | `user_logged_in`, `password_reset_requested` (Proposed) |
| Watch Ads | Watch eligible content; "ad tracking delays, invalid completion" acknowledged (SRC-007) | `ad_watch_started`, `ad_watch_completed`, `ad_validation_failed` (Proposed) |
| Tap & Earn / Captcha / Mining / Missions | Task-style completion flows | `task_started`, `task_completed`, `task_failed`, `reward_credited` (Proposed) |
| Daily bonus / streak | Claim bonus; maintain streak | `daily_reward_claimed`, `streak_updated` (Proposed) |
| Spin | Wheel-based feature consuming Spins (SRC-005) | `spin_started`, `spin_completed` (Proposed) |
| Exchange | Internal conversion request (SRC-005, SRC-007) | `exchange_requested`, `exchange_completed` (Proposed) |
| Withdrawal | Request → eligibility/verification → outcome; minimum 10 INR per current model (SRC-004) | `withdrawal_requested`, `withdrawal_under_review`, `withdrawal_completed`, `withdrawal_rejected`, `withdrawal_reversed`, `withdrawal_pending` (Proposed) |
| Referral | Share link → invited registration → acceptance; fixed reward logic (SRC-007) | `referral_created`, `referral_registered`, `referral_accepted` (Proposed); conversion definition TBD |
| Levels | XP accrual → level progression (SRC-005) | `xp_earned`, `level_up` (Proposed) |
| Codes | Redeem code → validation → granted/denied (SRC-007) | `code_redeemed`, `code_denied` (Proposed) |
| Fraud enforcement | Detection → cancellation/restriction/suspension (SRC-007) | `account_restricted`, `reward_cancelled` (Proposed; reason code TBD) |

## 7. System outcomes (A3) — user event vs system event vs business outcome

Public policy text forces a strict three-way distinction. Examples:

| Event | Type | Public evidence | Business outcome it feeds |
|---|---|---|---|
| User submits withdrawal request | User event | SRC-004, SRC-007 | Withdrawal demand |
| VE debit on submission | System event | Policy describes request lifecycle; debit mechanics are internal → **To Be Verified** | Wallet integrity |
| Verification checks run | System event | SRC-004 | Review workload |
| Withdrawal completed (provider reference) | System event | SRC-004 (request "does not automatically create a payout obligation") | Successful payout |
| Withdrawal rejected / reversed | System event (enforcement) | SRC-004, SRC-007 | Fraud control |
| Reward credited after task validation | System event | SRC-007 ("task validation", "invalid completion") | Net reward volume |
| Reward cancellation due to fraud | System event (enforcement) | SRC-007 | Gross-vs-net gap |
| Badge awarded | Business outcome | SRC-002 (missions and badges feature) | Progression engagement |
| Referral accepted by platform | Business outcome | SRC-007 ("only valid referrals accepted… may qualify") | Referral quality |
| User suspension | Business outcome (enforcement) | SRC-007 | Platform integrity |

**Key distinction for analytics design:** public documentation shows the platform *separates activity from validated reward* (task completion validity, ad tracking delays, invalid completion, system correction rights). Any reward KPI must therefore be able to split **activity occurred** from **reward actually credited** (see GAP-002).

## 8. Public-source contradictions and data-quality observations

These are source-quality findings, not product defects:

1. **Payout method contradiction.** Home meta description: "instant payouts via PayPal or Paytm" (SRC-001). Payout UI: UPI, Amazon Pay, Google Play available; PayPal "Coming Soon — currently unavailable in your region"; **no Paytm anywhere in the app** (SRC-003). Vercel marketing page: UPI/Amazon/Google Pay/PayPal (SRC-009). → Recorded as ASM-003; method-distribution KPIs are blocked until resolved.
2. **Boilerplate FAQ block.** Five FAQ items about points, Gold/Platinum membership, PCI-DSS/SOC 2, and card tokenization contradict the virtual-credit model documented everywhere else (SRC-005, SRC-006, SRC-007). → Recorded as ASM-004; excluded from all product claims.
3. **Marketing vs documentation.** Vercel landing page numbers ("+2,480 VEs this month", "1,000 VEs ≈ ₹100") are self-labelled illustrative (SRC-009) and are excluded from all analysis.
4. **Single-source concentration.** All product evidence comes from one domain's client-side bundle (SRC-002); individual help-center pages were not independently rendered (SRC-002 limitation).
5. **Changeable-by-design mechanics.** The disclaimer reserves the right to change rewards/exchanges/withdrawals at any time (SRC-006) — every metric definition needs versioning (feeds Deliverable 17/21 change management).

## 9. Analytics gaps (SC1 — summary)

Full register with priorities and rationale: `submission/03_data_coverage_matrix/analytics_gaps.csv` (12 gaps; requirement is ≥10).

| Gap | One-line statement | Priority |
|---|---|---|
| GAP-001 | No evidence of a stable cross-feature user identifier / unified event schema | Critical |
| GAP-002 | Reward lifecycle (activity → validation → credit) not defined anywhere public | Critical |
| GAP-003 | No transaction-ledger specification for the six virtual currencies; exchange rules not itemized | Critical |
| GAP-004 | Reward reversal/correction not represented as a defined event stream | Critical |
| GAP-005 | Withdrawal status taxonomy not published (only qualitative delayed/rejected/reversed) | High |
| GAP-006 | Referral lifecycle stages (created → registered → activated → converted) undefined | High |
| GAP-007 | No session identifier or session definition | High |
| GAP-008 | Third-party ad/offerwall "tracking limitations" with no external validation contract | High |
| GAP-009 | Payout method contradiction across public sources (see §8.1) | High |
| GAP-010 | Registration lacks documented acquisition-source and device fields | Medium |
| GAP-011 | No analytics change-management for a changeable-by-design product | Medium |
| GAP-012 | Public source reliability (boilerplate FAQ; single-source concentration) | Medium |

## 10. Limitations and unresolved questions

- This audit uses **public website sources only**. No internal engineering documentation, no access to production systems, and no dataset was available (ASM-005, ASM-006, ASM-008).
- Nothing in this document is a business metric or performance claim. No simulated data is used.
- "Confirmed (Public Documentation)" never means "verified in production" (ASM-001).
- Open items ASM-001…ASM-008 in the Assumption & Verification Register must be closed by Product/Engineering before Deliverables 08, 15, and 20 can claim implementation status.

## 11. Traceability

| Section | Source IDs |
|---|---|
| §3 product context | SRC-006, SRC-007 |
| §4 currencies | SRC-005, SRC-007 |
| §5 feature map | SRC-001…SRC-007, SRC-009 (illustrative, feature list cross-check only) |
| §6 event proposals | derived; all Proposed |
| §7 outcome classes | SRC-004, SRC-007 |
| §8 contradictions | SRC-001, SRC-003, SRC-007, SRC-009 |
| §9 gaps | derived from §5–§8 + SRC-002, SRC-004, SRC-005, SRC-006, SRC-007 |
