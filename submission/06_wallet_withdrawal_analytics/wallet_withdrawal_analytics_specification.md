# VELOOP Rewards — Wallet & Withdrawal Analytics Specification (D06)

## 1. Document Overview

**Deliverable:** D06 — Wallet & Withdrawal Analytics Specification
**Work Package:** D — Wallet & Withdrawal Analytics
**Status:** DRAFT v0.2 — remediated draft, in review
**Scheduled window:** Days 9–10 (per `registers\progress_tracker.csv`)
**Companion artifact:** `sf1_withdrawal_lifecycle.md` (SF1 — Withdrawal Lifecycle), same folder

### 1.1 Purpose

This document specifies the analytical model for VELOOP Rewards' wallet and withdrawal area: platform currencies, wallet balances and corrections, internal credit exchange, withdrawal requests, verification and review, reversals, and withdrawal history — together with the withdrawal KPI set, the fields each KPI needs, and what can and cannot be measured today.

### 1.2 Scope

- Platform currencies: VEs, XP, Gems, Tokens, Spins, Badges.
- Wallet: per-currency balances, system corrections.
- Exchange: Gems Exchange Center / Swap Center credit conversion.
- Withdrawal: request, eligibility, verification/review, outcome, reversal, history.
- Withdrawal KPIs: definitions, formulas, required fields, dimensions, feasibility.

**Out of scope (owned elsewhere):** reward earning mechanics (D05, on hold), referral analytics (D07), event catalogue construction (D08), KPI catalogue (D11).

### 1.3 Evidence labels used in this document

| Label | Meaning (per `docs\requirements_and_deliverable_register.md` §Evidence policy) |
|---|---|
| **Verified (public website)** | Stated on the official public website; proves the product *describes* something, not that it is live in production for all users/regions (ASM-001) |
| **Supplied data** | Observed only in the two simulated workbooks in `source datasets/`; never actual VELOOP users, earnings, withdrawals, or performance |
| **Proposed** | A design in this specification; not confirmed to exist in VELOOP today |
| **To Be Verified** | Open question requiring Product/Payments/Engineering confirmation (Section 12) |
| **Assumption** | Recorded in `registers\assumption_and_verification_register.csv` (ASM-xxx) |

### 1.4 Critical data statement

**The two supplied simulated workbooks contain no wallet, withdrawal, payout, currency-ledger, or transaction records.** A full-text scan of every sheet header and data cell in both workbooks found zero withdrawal- or payout-related fields or values. Everything in this specification that describes production behaviour is therefore **Verified (public website)** or **Proposed**; the simulated workbooks can only support the limited engagement proxies listed in Section 9. **No withdrawal KPI in Section 11 is currently computable from the supplied data, and no withdrawal success rate or actual withdrawal performance may be derived from it** (progress tracker, Day 10 note: "No success-rate claim may be derived yet").

---

## 2. Source references

| Source | Content used in this document | Status |
|---|---|---|
| SRC-003 | Payout method UI (UPI Transfer, Amazon Pay, Google Play, PayPal "Coming Soon"); `/Payout?method=<name>` route | Verified (public website) |
| SRC-004 | Withdrawal & Reward Verification Policy: 10 INR minimum, five verification check types, five review aspects, delayed/denied/reversed outcomes, "no automatic payout obligation" | Verified (public website) |
| SRC-005 | Platform Currency Policy: roles of VEs, XP, Gems, Tokens, Spins; all virtual platform-managed credits; rates/limits/pairings changeable and not itemized | Verified (public website) |
| SRC-001 | Home meta description: "instant payouts via PayPal or Paytm" (one side of the method contradiction) | Verified (public website) |
| SRC-009 | Vercel marketing page redemption list (UPI, Amazon, Google Pay, PayPal) — illustrative only | Illustrative (marketing) |
| SRC-007 | 19 published FAQ items: wallet system, system correction rights, task-completion validity | Verified (public website) |
| SRC-006 | Disclaimer: rewards/withdrawals may change, pause, or be removed at any time | Verified (public website) |
| D02 | `submission\02_product_data_audit\product_data_audit.md` §4 (currencies), §5 rows 18–22, §6 (proposed events), §7 (system outcomes), §8.1 (method contradiction) | Stage 2 deliverable |
| D03 | `submission\03_data_coverage_matrix\data_coverage_matrix.csv` DCM-019…DCM-023; `analytics_gaps.csv` GAP-003, GAP-004, GAP-005, GAP-009 | Stage 2 deliverable |
| Simulated workbooks | `source datasets\VELoop_Rewards_Data_01.xlsx`, `source datasets\VELOOP_Simulated_User_Behavior_1000.xlsx` | Supplied data |

All `SRC-xxx`, `ASM-xxx`, `DCM-xxx`, and `GAP-xxx` references resolve to the files above (`registers\source_and_verification_register.csv`, `registers\assumption_and_verification_register.csv`).

---

## 3. Platform currencies (Verified, public documentation)

From SRC-005 and SRC-007 (see D02 §4):

| Currency | Documented role | Analytics relevance for D06 |
|---|---|---|
| VEs | Primary platform reward unit; usable in supported redemption flows | Primary unit of reward and, per current model, of withdrawal amounts |
| XP | Level progression | Not a redemption currency in the documented model |
| Gems | May be exchangeable into VEs where supported | Exchange flow (DCM-020) |
| Tokens | Platform utilities (e.g. buying Gems, Spins) | Consumption flow; not itemized publicly |
| Spins | Wheel-based features | Consumed by Spin the Wheel |
| Badges | Recognition items | Not a currency in the documented model |

**Verified constraints:**

1. All six are **virtual platform-managed credits** — explicitly *not* bank balances, stored-value instruments, or investment products (SRC-005, SRC-006).
2. **Exchange rates, limits, and pairings are public in principle but not itemized** and may change at any time (SRC-005) — this is the root cause of GAP-003.
3. The documented redemption currencies and withdrawal currency conversion (e.g., VEs → INR) are **not described in any public source**. The marketing-page figure "1,000 VEs ≈ ₹100" is explicitly illustrative (SRC-009) and is excluded from all analysis.

**Consequence:** any wallet model in this specification is a **Proposed** field structure built on top of these verified currency roles; no exchange rate, limit, or pairing value is stated as fact anywhere in this document.

---

## 4. Wallet model (Proposed field design on Verified currency roles)

### 4.1 Balance records

The public documentation confirms users have per-currency balances displayed in the Wallet (DCM-019; SRC-007 wallet FAQ), but **no balance field structure, ledger, or transaction model is publicly specified** (GAP-003). The following is therefore **Proposed**:

| Field | Type | Required? | Purpose | Status |
|---|---|---|---|---|
| `user_id` | String | Required | User the balance belongs to (join key; semantics defined in D04 §2.1) | Proposed (production); evidenced as simulated identifier in both workbooks |
| `currency` | Categorical (VEs/XP/Gems/Tokens/Spins/Badges) | Required | Which platform credit the balance record holds | Proposed |
| `balance_amount` | Decimal | Required | Balance of that currency for that user at a point in time | Proposed |
| `balance_timestamp` | Datetime | Required | When the balance snapshot was taken | Proposed |

**Why a balance *history* (amount + timestamp), not just a current balance:** the public policy reserves system-correction rights (SRC-007), so a reliable wallet model must be able to reconstruct how a balance changed over time; a single current number cannot support correction or exchange analysis. This is a design requirement of this specification, not a documented VELOOP capability.

### 4.2 Wallet corrections

**Verified:** the platform reserves the right to correct wallet balances (system correction; SRC-007; DCM-019 notes balances are "subject to verification; abuse checks; system correction"). **Not verified:** corrections are not represented anywhere as a defined, auditable event or state (GAP-004, Critical).

| Field | Type | Required? | Purpose | Status |
|---|---|---|---|---|
| `correction_id` | String | Required | Unique identifier of one correction record | Proposed |
| `user_id` | String | Required | User whose balance was corrected | Proposed |
| `currency` | Categorical | Required | Currency corrected | Proposed |
| `correction_type` | Categorical | Required | Why the balance was corrected (taxonomy not public — Proposed, see Open Question OQ-6) | Proposed |
| `correction_amount` | Decimal | Required | Amount added or removed (signed) | Proposed |
| `correction_timestamp` | Datetime | Required | When the correction was applied (DCM-019) | Proposed |

**Proposed event:** `wallet_correction_applied` (DCM-019) — not confirmed to exist in production.

### 4.3 Wallet transaction types — documented vs unsupported

**Documented transaction types** — the only wallet-area transaction types established by the public evidence reviewed in this project. The *existence* of each type is documented; every field, event, and state that models it remains **Proposed** (Sections 4.2, 5, 7; SF1):

| Transaction type | Public evidence | Field model in this document |
|---|---|---|
| Wallet correction (system correction of a balance) | SRC-007 (wallet FAQ: platform reserves the right to correct balances); not represented anywhere as a defined, auditable event or state (GAP-004, Critical) | §4.2 (all fields Proposed) |
| Exchange (internal credit conversion, e.g. Gems → VEs where supported) | SRC-005 (Gems "may be exchangeable into VEs where supported"; rates/limits/pairings not itemized); SRC-007 (Gems Exchange Center / Swap Center FAQ); route evidence per SRC-002 (Section 5) | §5 (all fields Proposed; no public rates — GAP-003) |
| Payout / withdrawal request (redemption in VEs per the current model, Section 3) | SRC-003 (Payout UI request flow, `/Payout?method=<name>`); SRC-004 (Withdrawal & Reward Verification Policy: minimum amount, verification checks, outcomes) | §7 and SF1 (all fields and events Proposed — DCM-021/023). Documented withdrawal request workflow only; actual VE debit timing and ledger posting remain To Be Verified (see OQ-10). |

**Unsupported / unverified transaction types** — the types below are **not established by the evidence reviewed in this project**. They are listed because Work Package D (D1) requires the distinction to be explicit; **nothing in this document claims that any of them is confirmed absent from the product** — the absence of public documentation is not evidence of absence in production (Section 1.3 evidence policy; ASM-001):

- **Deposits / top-ups** — user-initiated crediting of funds or credits into a wallet
- **Refunds** — return of a payout or credit outside the documented correction/reversal paths
- **Manual adjustments** — operator-initiated balance changes other than the documented system-correction right
- **Batch postings** — system-generated grouped or scheduled balance entries

**Handling rules (binding for this specification and for all downstream use of it):**

1. **No existence claims.** No unsupported type may be described as existing VELOOP functionality, and no field, event, or state for it may be presented as confirmed (ASM-008; Section 1.3 evidence labels).
2. **Newly encountered types stay To Be Verified.** Any transaction type newly encountered (in supplied data, an engineering input, or new public material) that is not in the documented list above is marked **To Be Verified** until Product/Payments confirms it.
3. **Safe-mapping fallback.** If an observed record cannot be mapped safely to a documented type, it is classified as `Unspecified/Other` (**Proposed** classification — not a public code) and **flagged for review**; it is never silently assigned to a documented type.
4. **Change-controlled extension.** A type is added to the documented list only after Product/Payments confirmation, and the addition is recorded in this document's revision history with the confirming source.
5. **Day-9 tracker principle preserved.** "Unsupported transaction types remain Proposed" (`registers\progress_tracker.csv`, Day 9): every type not in the documented list remains Proposed / To Be Verified in this document and in downstream deliverables (Section 14).

### 4.4 Unified Wallet Transaction Ledger Schema (D1 Master Model)

Per the official assignment brief (Work Package D, D1), the intern must design a transaction model that allows VELOOP to understand wallet and withdrawal operations. While Sections 4.1, 4.2, 5, and SF1 define domain-specific records, the master transaction ledger brings all balance-altering movements into a unified, auditable transaction schema.

The 10 fields required by Work Package D (D1) are defined below. All fields and schemas remain **Proposed** because internal engineering ledger specifications are not publicly published (GAP-003, ASM-008):

| # | Field Name | Data Type | Required? | Description & Analytical Purpose | Allowed / Example Values | Status |
|---|---|---|---|---|---|---|
| 1 | `transaction_id` | String | Required | Unique immutable identifier for every wallet transaction record. Enforces deduplication and double-entry auditing (D04 §2.4). | `WTX00000001`, `TXN_10001` | Proposed (GAP-003; absent in simulated data) |
| 2 | `user_id` | String | Required | Stable user identifier of the wallet owner (join key; semantics defined in D04 §2.1). | `VLUSR000001` | Proposed (production); Evidenced in simulated data |
| 3 | `timestamp` | Datetime (ISO 8601 UTC) | Required | Exact datetime when the transaction was recorded in the ledger. | `2026-05-15T14:32:00Z` | Proposed |
| 4 | `transaction_type` | Categorical | Required | Operational classification of the movement. Distinguishes earning credits from redemptions, conversions, and corrections. | Documented: `reward_credit`, `redemption_withdrawal`, `exchange_conversion`, `system_correction`. Unsupported/Proposed: `deposit_topup`, `refund`, `manual_adjustment`, `batch_posting` (see §4.3). | Proposed |
| 5 | `amount` | Decimal(18,4) | Required | Magnitude of the balance movement. Stored as an unsigned positive value with debit/credit direction governed by `transaction_type`. | `100.0000`, `250.0000` | Proposed |
| 6 | `unit` | Categorical | Required | The platform virtual credit unit affected. | `VEs`, `XP`, `Gems`, `Tokens`, `Spins`, `Badges` | Field Proposed; currency roles Verified (SRC-005) |
| 7 | `status` | Categorical | Required | Current ledger posting state. Unconfirmed in production; standard proposed states avoid ambiguous processing states. | `posted`, `pending`, `failed`, `reversed`, `cancelled` | Proposed |
| 8 | `source` | Categorical | Required | Subsystem, feature, or route that originated the transaction. | `watch_ads`, `tap_n_earn`, `daily_bonus`, `exchange_center`, `payout_engine`, `admin_correction` | Proposed |
| 9 | `reference_id` | String | Conditional / Required where applicable | Foreign key linking to the source entity that triggered the transaction. | `activity_id` (task reward), `withdrawal_id` (redemption), `exchange_id` (credit swap) | Proposed |
| 10 | `reversal_ref_id` | String | Conditional (for reversals / corrections) | Self-referencing foreign key pointing to the original `transaction_id` being reversed or corrected (enforces the audit trail required by D1 and GAP-004). | Points to original `transaction_id`; `null` for initial transactions | Proposed |

#### Polymorphic Transaction Mapping Matrix

How each platform operation maps into this unified 10-field ledger schema:

| Transaction Flow | `transaction_type` | Balance Direction | `unit` | `source` | `reference_id` | `reversal_ref_id` | Ledger Debit / Credit Timing Rule |
|---|---|---|---|---|---|---|---|
| Earning Reward Credit | `reward_credit` | Credit (+) | `VEs`, `XP`, `Tokens` | Feature name (e.g. `watch_ads`) | `activity_id` (D05 / `05_Task_Activity`) | `null` | Posted upon validation (D05 analytical lifecycle) |
| Credit Exchange (From) | `exchange_conversion` | Debit (-) | `from_currency` (e.g. `Gems`) | `exchange_center` | `exchange_id` (§5) | `null` | Posted upon exchange confirmation |
| Credit Exchange (To) | `exchange_conversion` | Credit (+) | `to_currency` (e.g. `VEs`) | `exchange_center` | `exchange_id` (§5) | `null` | Posted upon exchange confirmation |
| Withdrawal / Payout Request | `redemption_withdrawal` | Debit (-) | `VEs` | `payout_engine` | `withdrawal_id` (SF1 §5) | `null` | **To Be Verified (OQ-10):** Debited immediately at `withdrawal_requested` vs held in pending and debited upon `withdrawal_completed`. |
| System Wallet Correction | `system_correction` | Credit (+) or Debit (-) | Any virtual currency | `admin_correction` | `correction_id` (§4.2) | Points to original `transaction_id` if correcting an earlier entry | Posted upon admin action (SRC-007) |
| Withdrawal Reversal | `reversal` | Credit (+) [refund] | `VEs` | `payout_engine` | `withdrawal_id` (SF1 §5) | Points to original `transaction_id` of the redemption debit | Posted upon transition to `withdrawal_reversed` (SF1 §3) |

**Critical Ledger Behavior Constraints (To Be Verified — OQ-10):**
1. **Debit Timing on Withdrawal:** Whether VEs are debited from the available balance immediately upon submission (`withdrawal_requested`) or held as "reserved" and finalized upon approval (`withdrawal_completed`) is not documented publicly. It is recorded strictly as **To Be Verified (OQ-10)**.
2. **Immutability of Reversal Ledger Entries:** A withdrawal reversal or wallet correction must never overwrite or delete the original transaction row. It must post an offsetting `reversal` entry referencing `reversal_ref_id` to preserve double-entry auditability (GAP-004).

---

## 5. Exchange (Gems Exchange Center / Swap Center)

**Verified:** the exchange feature is publicly documented (SRC-002 route map; SRC-005 — Gems "may be exchangeable into VEs where supported"; SRC-007 exchange/swap FAQ). **Not verified:** exchange rates, limits, and supported pairings are not itemized and may change (SRC-005; GAP-003).

| Field | Type | Required? | Purpose | Source / Status |
|---|---|---|---|---|
| `exchange_id` | String | Required | Unique identifier of one exchange | Proposed (not public) |
| `user_id` | String | Required | User performing the exchange | Proposed |
| `from_currency` | Categorical | Required | Currency given (e.g. Gems) | DCM-020 (Proposed) |
| `to_currency` | Categorical | Required | Currency received (e.g. VEs) | DCM-020 (Proposed) |
| `from_amount` | Decimal | Required | Amount given | DCM-020 (Proposed) |
| `to_amount` | Decimal | Required | Amount received | DCM-020 (Proposed) |
| `rate` | Decimal | Conditional | Applied rate, where one is applied | DCM-020 (Proposed); no public rate values exist |
| `exchange_timestamp` | Datetime | Required | When the exchange occurred | DCM-020 (Proposed) |
| `exchange_status` | Categorical | Required | Outcome (states not public — Proposed taxonomy) | Proposed |

**Proposed events:** `exchange_requested`, `exchange_completed` (DCM-020, D02 §6) — not confirmed to exist in production.

---

## 6. Payout methods (Verified, with a documented contradiction)

The three public sources **disagree** (ASM-003; GAP-009; D02 §8.1):

| Source | Methods stated |
|---|---|
| SRC-001 (home meta description) | "instant payouts via **PayPal or Paytm**" |
| SRC-003 (in-app Payout UI) | **UPI Transfer** ("Instant Bank Transfer", "Processing within 24 hours"); **Amazon Pay** ("Gift Card Balance", "Instant delivery"); **Google Play** ("App Store Credit", "Global redemption"); **PayPal** ("Coming Soon", "Currently unavailable in your region"). No Paytm anywhere in the app. |
| SRC-009 (Vercel marketing page, illustrative) | UPI, Amazon Gift Card, Google Pay Gift Card, PayPal |

Rules applied in this specification:

1. **No single source of truth exists.** The `payout_method` dimension is **frozen as "To Be Verified"** until Product/Payments confirms (GAP-009 mitigation).
2. The in-app Payout UI (SRC-003) is treated as the most specific source, but not as authoritative — its timing strings ("24 hours", "instant") are **UI marketing text, not measured performance** (SRC-003 limitation).
3. No payout method in this document is described as *confirmed available in production*; region availability may differ (SRC-003).

**Verification questions** (owner: Product/Payments) — see Open Questions OQ-1/OQ-2 in Section 12.

---

## 7. Withdrawal lifecycle — SF1

The full withdrawal lifecycle is specified in the standalone supporting artifact **`sf1_withdrawal_lifecycle.md` (SF1)** in this folder. SF1 is a required output of D06 (progress tracker Days 9–10) and feeds D08 (Event Tracking Plan) per the register (`SF1 | Withdrawal Lifecycle | 06, 08`).

Summary (details, transition table, and evidence per state in the SF1 file):

```
withdrawal_requested  →  withdrawal_under_review  →  withdrawal_completed
                                            ├──────→  withdrawal_rejected
                                            └──────→  withdrawal_reversed
                                            (or remains pending / delayed)
```

- **States that are qualitatively public:** SRC-004 describes outcomes (delayed, denied, reversed) and the five verification check types; it does **not** publish a status enum, reason codes, or transition rules (GAP-005). The state names and transition structure above are therefore **Proposed**, mapped onto the qualitatively public outcomes.
- **Verified rule:** the minimum withdrawal amount is **10 INR per the current platform model**, changeable at any time (SRC-004; ASM-007). Used here strictly as the "documented current model value."
- **Verified rule:** "A submitted request does not automatically create a payout obligation" (SRC-004).
- **Proposed events:** `withdrawal_requested`, `withdrawal_under_review`, `withdrawal_completed`, `withdrawal_rejected`, `withdrawal_reversed` (DCM-021/023; D02 §6) — none confirmed to exist in production (ASM-008).

---

## 8. Verification and review (Verified process, Proposed taxonomy)

**Verified (SRC-004):** a withdrawal request may be subject to **account-level, transaction-level, behavioral, technical, or compliance checks**; the review may cover **login status, region eligibility, payout details, task-completion validity, and referral validity**; the request may be **delayed, denied, or reversed**.

**Proposed** (no public status enum or reason codes exist — GAP-005; per the C2-style rule noted in GAP-005, the taxonomy below is a design proposal, not an internal code list):

| Field | Type | Required? | Purpose | Status |
|---|---|---|---|---|
| `status_from` / `status_to` | Categorical (SF1 state names) | Required | One transition record per status change (DCM-023) | Proposed |
| `transition_timestamp` | Datetime | Required | When the transition occurred (enables processing-time KPIs) | Proposed |
| `verification_type` | Categorical (the five public check types above) | Conditional | Which check(s) applied to the request | Verified categories; per-request values are production data |
| `reason_category` | Categorical | Conditional (for rejected/reversed) | Why the request was rejected or reversed — **taxonomy to be proposed, not invented as internal codes** | Proposed |
| `verifier_type` | Categorical | Conditional | Automated vs manual review (distinction not public) | Proposed (DCM-023) |

---

## 9. Reversals and corrections (GAP-004)

**Verified:** reversal/correction is a real concept — withdrawals "may be delayed, denied, or reversed" (SRC-004); wallet corrections are reserved (SRC-007); fraud-related reward cancellation exists (SRC-007).

**Gap (Critical):** none of this is represented anywhere as a defined, auditable event or state with a reason code and timestamp (GAP-004). D06's mitigation, per the gap register: "reversal relationship modeling required in Deliverable 06."

Specification treatment (all **Proposed**):

- A withdrawal may end in `withdrawal_reversed` after any earlier state, including after `withdrawal_completed` (the public policy does not say otherwise; this is a design assumption to confirm — OQ-5).
- Every reversal and every wallet correction must carry a `reason_category` and a timestamp so that **gross vs net** reward/withdrawal volume can be separated in reporting (GAP-004 impact statement).
- Naming coordination: D05 (on hold) will define the reward-side events `reward_reversed` / `reward_corrected` (DCM-031); D06 owns the withdrawal-side `withdrawal_reversed`. The two taxonomies must stay aligned — flagged to avoid divergence (OQ-7).

---

## 10. Withdrawal history (DCM-022)

**Verified:** a withdrawal-history view exists publicly (route `/withdrawal-history`; D02 §5 row 21) and displays past request statuses.

Specification treatment:

- The history is a **derived view over the SF1 lifecycle** (DCM-022: "derived from DCM-023 lifecycle") — it introduces **no new events** of its own.
- Required to display, per DCM-022: past request list with statuses; no additional fields are publicly documented.
- Any history-specific fields (e.g. list filter states) are **Proposed** and out of scope until the lifecycle fields exist.

---

## 11. Withdrawal KPIs

**Documented KPI requirement (corrected):** the Work Package D section of the assignment brief, as supplied by the project team, lists **ten required KPI areas**: withdrawal requests, completed withdrawals, pending withdrawals, rejected withdrawals, reversed withdrawals, processing time, completion rate, pending queue, withdrawal volume, and method distribution. The six-item list quoted in GAP-005 (*"The brief's withdrawal KPI list (requests, completed, pending, rejected, processing time, completion rate)"*) is a **partial excerpt** of that same list — it omits reversed withdrawals, pending queue, withdrawal volume, and method distribution — and **is not the complete requirement**. The ten KPIs below are the complete documented set; every one is documented with the nine required fields (name, definition, formula, required data, data source, frequency, stakeholder, business purpose, limitations).

**Global feasibility statement:** **none of the ten KPIs is currently computable.** The supplied simulated workbooks contain no withdrawal, payout, or ledger records (Section 12.1). Every KPI below is a specification; no value, target, or trend for any of them may be reported.

**Global constraint (progress tracker Day 10):** "No success-rate claim may be derived yet." KPI-7 is defined below but must not be reported as a performance or success-rate claim from current evidence.

Common conventions used below (to keep each KPI entry readable):

- **Data source** refers to the withdrawal request records defined in SF1 §5 (fields `withdrawal_id`, `payout_method`, `requested_amount`, `currency`, `requested_timestamp`) and the SF1 transition records (`status_from`, `status_to`, `transition_timestamp`, `reason_category`). All of these fields are **Proposed**; the exact source-of-truth structure (transition log vs request table) is OQ-3.
- **Frequency** and **stakeholder** values are **Proposed / To Be Confirmed** — no frequency or stakeholder assignment is confirmed by any available evidence.
- All formulas are **Proposed** and operate only on the Proposed fields above.

### KPI-1 — Withdrawal requests

- **Definition:** Number of withdrawal requests initiated (confirmed by the user) in a period.
- **Formula (Proposed):** `COUNT(withdrawal_requested)` for requests whose `requested_timestamp` falls in the period; equivalently `COUNT(DISTINCT withdrawal_id)` over request records.
- **Required data:** `withdrawal_id`, `user_id`, `payout_method`, `requested_amount`, `currency`, `requested_timestamp` (SF1 §5; DCM-021 — all Proposed).
- **Data source:** Withdrawal request records per SF1 (Proposed; structure pending OQ-3). Not present in the supplied workbooks.
- **Frequency:** Daily and monthly — **Proposed / To Be Confirmed**.
- **Stakeholder:** Payments operations; product analytics — **Proposed / To Be Confirmed**.
- **Business purpose:** Baseline of withdrawal demand; drives capacity and eligibility analysis (DCM-021 business question: "Withdrawal demand by method").
- **Limitations:** Not computable today (no withdrawal records in supplied data, §12.1). `payout_method` dimension is frozen **To Be Verified** (ASM-003, GAP-009) and must not be used for reporting until confirmed.

### KPI-2 — Completed withdrawals

- **Definition:** Number of requests that reached the `withdrawal_completed` outcome in a period.
- **Formula (Proposed):** `COUNT(status_to = completed)` over SF1 transition records whose `transition_timestamp` falls in the period.
- **Required data:** `withdrawal_id`, `status_from`, `status_to`, `transition_timestamp` (SF1 §5 — Proposed).
- **Data source:** SF1 transition records (Proposed; structure pending OQ-3). Not present in the supplied workbooks.
- **Frequency:** Daily and monthly — **Proposed / To Be Confirmed**.
- **Stakeholder:** Payments operations; finance reporting — **Proposed / To Be Confirmed**.
- **Business purpose:** Measure of fulfilled withdrawal demand; input to processing-time and completion analysis (DCM-023 business question: "Withdrawal funnel and processing time").
- **Limitations:** Not computable today. The `completed` state is **Proposed** — no status enum is public (GAP-005). Counting completions is a volume statement, not a success-rate or performance claim.

### KPI-3 — Pending withdrawals

- **Definition:** Number of distinct requests that were in a pending or under-review state at any point during the period (a **flow** measure of how much demand sat in review).
- **Formula (Proposed):** `COUNT(DISTINCT withdrawal_id WHERE a state in {pending, under_review} existed at any time in the period)`.
- **Required data:** `withdrawal_id`, `status_from`/`status_to`, `transition_timestamp`, `requested_timestamp` (SF1 §5 — Proposed).
- **Data source:** SF1 transition records (Proposed; structure pending OQ-3). Not present in the supplied workbooks.
- **Frequency:** Daily and monthly — **Proposed / To Be Confirmed**.
- **Stakeholder:** Payments operations; support — **Proposed / To Be Confirmed**.
- **Business purpose:** Shows review load over time; complements KPI-8 (which is a point-in-time backlog) and KPI-6 (how long the wait lasts).
- **Limitations:** Not computable today. Distinct from KPI-8 Pending queue: KPI-3 counts requests that passed through pending during the period (flow); KPI-8 counts requests still waiting right now (stock). Pending-state semantics are not publicly defined (SF1 §2 note).

### KPI-4 — Rejected withdrawals

- **Definition:** Number of requests that reached the `withdrawal_rejected` outcome in a period.
- **Formula (Proposed):** `COUNT(status_to = rejected)` over SF1 transition records in the period; breakdown `GROUP BY reason_category`.
- **Required data:** `withdrawal_id`, `status_from`/`status_to`, `transition_timestamp`, `reason_category` (SF1 §5 — Proposed; reason taxonomy pending OQ-6).
- **Data source:** SF1 transition records (Proposed; structure pending OQ-3). Not present in the supplied workbooks.
- **Frequency:** Daily and monthly — **Proposed / To Be Confirmed**.
- **Stakeholder:** Payments operations; fraud/risk — **Proposed / To Be Confirmed**.
- **Business purpose:** Review friction and eligibility outcomes; feeds fraud-control monitoring (D02 §7: "Withdrawal rejected / reversed — fraud control").
- **Limitations:** Not computable today. `reason_category` values must stay **Proposed** until a taxonomy is confirmed (GAP-005 C2-style rule); no public rejection codes exist. Must remain separable from KPI-5 (reversed).

### KPI-5 — Reversed withdrawals

- **Definition:** Number of requests that reached the `withdrawal_reversed` outcome in a period (a payout or credit taken back after the fact).
- **Formula (Proposed):** `COUNT(status_to = reversed)` over SF1 transition records in the period; breakdown `GROUP BY reason_category`.
- **Required data:** `withdrawal_id`, `status_from`/`status_to`, `transition_timestamp`, `reason_category` (SF1 §5 — Proposed; taxonomy pending OQ-6).
- **Data source:** SF1 transition records (Proposed; structure pending OQ-3). Not present in the supplied workbooks.
- **Frequency:** Daily and monthly — **Proposed / To Be Confirmed**.
- **Stakeholder:** Fraud/risk; finance reporting — **Proposed / To Be Confirmed**.
- **Business purpose:** Reversal exposure and reward/withdrawal integrity (GAP-004: gross vs net must stay separable; "reversal relationship modeling required in Deliverable 06").
- **Limitations:** Not computable today. Whether `withdrawal_completed` can transition to `withdrawal_reversed` is open (OQ-5); the KPI formula covers all transition sources regardless of that answer. Reason codes are **Proposed** only.

### KPI-6 — Processing time

- **Definition:** Elapsed time per request from `requested_timestamp` to the terminal outcome (`completed`, `rejected`, or `reversed`), reported per period.
- **Formula (Proposed):** per request: `transition_timestamp(terminal) − requested_timestamp`; reported as **median and p95** (not mean only) across requests in the period.
- **Required data:** `withdrawal_id`, `requested_timestamp`, terminal `transition_timestamp` (SF1 §5 — Proposed).
- **Data source:** SF1 transition records (Proposed; structure pending OQ-3). Not present in the supplied workbooks.
- **Frequency:** Weekly and monthly — **Proposed / To Be Confirmed**.
- **Stakeholder:** Payments operations; product analytics — **Proposed / To Be Confirmed**.
- **Business purpose:** Review and payout speed; the "processing time" area of the D3 KPI list; input to queue decisions (KPI-8).
- **Limitations:** Not computable today. The figure includes time spent pending; a split between review time and payout time is **Proposed** and not derivable from public evidence. The SRC-003 strings "Processing within 24 hours" / "instant" are UI marketing text, not a target or baseline (SRC-003 limitation).

### KPI-7 — Completion rate

- **Definition:** Share of requests in a period that reached the `withdrawal_completed` outcome.
- **Formula (Proposed — denominator NOT confirmed):** numerator: `COUNT(status_to = completed)` in the period. Denominator is **unconfirmed** — candidate definitions: (a) all requests initiated in the period, (b) requests that reached a terminal state in the period, (c) requests that left pending in the period. The exact denominator is **flagged for confirmation (OQ-4)** and this KPI must not be computed until it is fixed.
- **Required data:** KPI-1 + KPI-2 fields (`withdrawal_id`, `requested_timestamp`, `status_from`/`status_to`, `transition_timestamp`).
- **Data source:** SF1 transition records + request records (Proposed; structure pending OQ-3). Not present in the supplied workbooks.
- **Frequency:** Monthly — **Proposed / To Be Confirmed**.
- **Stakeholder:** Payments operations; finance reporting — **Proposed / To Be Confirmed**.
- **Business purpose:** Outcome mix of the withdrawal funnel (DCM-023 business question: "Withdrawal funnel and processing time").
- **Limitations:** **Defined only — no success-rate claim may be derived yet** (progress tracker Day 10). Not computable today. Do not report as an actual VELOOP success rate or performance figure. Denominator choice materially changes the value (OQ-4).

### KPI-8 — Pending queue

- **Definition:** Number of requests **still** in a pending or under-review state at a point in time T (a **stock/backlog** measure), optionally with an age breakdown.
- **Formula (Proposed):** `COUNT(status ∈ {pending, under_review} as of T)`; aging: bucket the same set by `(T − requested_timestamp)`.
- **Required data:** `withdrawal_id`, current status (from SF1 transition records or a current-status column), `requested_timestamp` (SF1 §5 — Proposed).
- **Data source:** SF1 transition records (Proposed; structure pending OQ-3 — a current-status column would make this KPI cheaper to compute). Not present in the supplied workbooks.
- **Frequency:** Daily (operational snapshot) — **Proposed / To Be Confirmed**.
- **Stakeholder:** Payments operations; support — **Proposed / To Be Confirmed**.
- **Business purpose:** Backlog visibility for review capacity planning; complements KPI-3 (flow) and KPI-6 (age in days).
- **Limitations:** Not computable today. Point-in-time measure: value is only meaningful with an explicit timestamp T. Distinct from KPI-3 Pending withdrawals (flow vs stock). Pending-state semantics not publicly defined.

### KPI-9 — Withdrawal volume

- **Definition:** Total requested withdrawal amount in a period, grouped by the **original currency** of the request.
- **Formula (Proposed):** `SUM(requested_amount) GROUP BY currency` for requests in the period. No currency conversion is applied: no VE↔INR (or other) exchange rate is documented in any public source (SRC-005; OQ-8), so **rates are not invented** and volumes are never summed across currencies. Variant (Proposed): `SUM(requested_amount) GROUP BY currency` restricted to requests that reached `completed`, reported separately as completed volume.
- **Required data:** `withdrawal_id`, `requested_amount`, `currency`, `requested_timestamp`, and for the variant `status_to`/`transition_timestamp` (SF1 §5 — Proposed).
- **Data source:** SF1 request/transition records (Proposed; structure pending OQ-3). Not present in the supplied workbooks.
- **Frequency:** Monthly — **Proposed / To Be Confirmed**.
- **Stakeholder:** Finance reporting; payments operations — **Proposed / To Be Confirmed**.
- **Business purpose:** Size of redemption demand in the currency actually requested (DCM-021/023 business questions; DCM-020 analogue "volume").
- **Limitations:** Not computable today. Amounts are per-currency only; the 10 INR minimum (SRC-004, ASM-007) is a rule, not a volume. Marketing figures (e.g. "1,000 VEs ≈ ₹100", SRC-009) are illustrative and excluded.

### KPI-10 — Method distribution

- **Definition:** Number and share of withdrawal requests per payout method in a period.
- **Formula (Proposed):** count: `COUNT(withdrawal_requested) GROUP BY payout_method`; share: `count(method) / COUNT(all requests in period)`.
- **Required data:** `withdrawal_id`, `payout_method`, `requested_timestamp` (SF1 §5 — Proposed).
- **Data source:** SF1 request records (Proposed; structure pending OQ-3). Not present in the supplied workbooks.
- **Frequency:** Monthly — **Proposed / To Be Confirmed**.
- **Stakeholder:** Payments operations; product analytics — **Proposed / To Be Confirmed**.
- **Business purpose:** Method-mix visibility (DCM-021 business question: "Withdrawal demand by method"); supports method rollout and dashboard filters (D02 §8.1).
- **Limitations:** Not computable today. The `payout_method` dimension itself is **frozen To Be Verified** — the three public sources contradict each other (ASM-003; GAP-009; Section 6) — and this KPI must not be reported until the method list is confirmed (OQ-2).

### 11.1 Supplementary metrics (NOT substitutes for the ten KPIs above)

These two metrics come from DCM business questions and remain part of the wallet scope of this specification, but they do **not** replace or count toward the ten required D3 KPIs:

- **S-1 Wallet correction volume** (DCM-019, "wallet trust and correction volume"): `COUNT(wallet_correction_applied) GROUP BY correction_type` (Section 4.2 fields — Proposed). Not computable from supplied data (GAP-004).
- **S-2 Exchange volume** (DCM-020, "exchange volume and rate sensitivity"): `SUM(from_amount)` and `SUM(to_amount) GROUP BY from_currency, to_currency` (Section 5 fields — Proposed; no public rates, GAP-003). Not computable from supplied data.

Notes:

- Every formula above operates on **Proposed** events/fields from Sections 4, 5, 7–8 and SF1. Until those fields exist in a data source, every KPI is a specification, not a measurement.
- KPI-2…KPI-8 and KPI-10 assume the SF1 transition model (one record per status change) is the data source; a request table with a current-status column would change several formulas (OQ-3).
- Rejected (KPI-4) and reversed (KPI-5) are kept as **separate** KPIs: they answer different integrity questions and must never be merged into one "failed" bucket (GAP-004).
- No KPI in this section carries a target, threshold, or forecast: none is supported by available evidence, and the tracker Day 10 constraint applies.

---

## 12. Simulated data evidence, limitations, and open questions

### 12.1 What the supplied workbooks contain (Supplied data)

Both workbooks self-declare "SIMULATED / FICTIONAL / FOR ANALYTICAL WORK ONLY" and "Actual VELOOP production data: NO" (their own README sheets). A full-text scan of all sheets found **zero** wallet, withdrawal, payout, ledger, or transaction records.

Wallet-adjacent fields actually present:

| Field | Workbook / sheet | Values observed | What it may and may not support |
|---|---|---|---|
| `xp_balance` | Task 01 `Users_1000_Clean` and `Users_Messy_Audit` | 987 distinct values across ~1,000 users; includes one negative value `-0.1` | A single per-user **XP** number (data dictionary: "Simulated XP balance"). It is **not** VEs, not a financial wallet balance, and has no history or transaction detail. May support XP-distribution profiling (D12) only |
| `wallet_activity` (Yes/No) | Task 02 `04_Daily_Activity` (6,667 user-day rows) | Yes/No daily flag | "Did this user touch the Wallet feature that day." **Does not prove any withdrawal, transaction, or balance value** |
| `spin_activity` (Yes/No) | Task 02 `04_Daily_Activity` | Yes/No daily flag | Same caveat, for Spin the Wheel |
| `xp_activity_count` (integer) | Task 02 `04_Daily_Activity` | 0–35 observed (29 distinct integer values) | Count of XP-related activities per user-day; engagement only |
| `xp_related_flag` (Yes/No) | Task 02 `03_Feature_Events`, `10_Event_Data_Quality_Audit` | Yes/No per event row | Whether an event was XP-related; engagement only |
| `wallet_viewed`, `spin_opened/started/completed` | Task 02 `06_Milestones.source_event`; `07_Feature_Usage`; `02_Sessions` entry/exit | Event/feature names | Feature-interaction evidence only |

**Conclusion:** the supplied data can support *feature-touch* engagement for Wallet/Spin (e.g., "what share of active user-days included wallet activity" — a Supplied-data engagement figure, never a VELOOP production metric). It can support **none** of KPI-1…KPI-10, nor the two §11.1 supplementary metrics (S-1/S-2).

### 12.2 The observed `xp_balance` value of `-0.1`

`xp_balance` contains the value `-0.1` (present in both the clean and the audit user sheets). The Task 01 workbook's own `Data_Dictionary` states the validation rule for `xp_balance` as ">=0". The observed value therefore **conflicts with the workbook's own stated rule**; the cause is not known from available evidence — it may be an intentional synthetic edge case, a rounding artifact of the generation process, or a stale dictionary rule. **It is not classified as an error in this document.** It is logged here so the Data Quality Audit (D13) can investigate with full context, and so no downstream deliverable silently inherits a negative balance as "normal".

### 12.3 Dataset limitation statement (for all downstream use)

> Within the supplied simulated datasets, no wallet balance (other than the single per-user XP figure), no withdrawal, no payout method, no exchange, no correction, and no ledger record exists. Any analysis that needs these must either wait for a documented data source or state explicitly that the value is a Proposed specification, not a measurement.

### 12.4 Assumptions applied (all "To Be Verified" in the Assumption & Verification Register)

| ID | Assumption | How D06 uses it |
|---|---|---|
| ASM-001 | App-build routes/help content do not prove production availability, region support, or eligibility | No wallet/withdrawal feature or method is described as "live in production"; all marked Verified (public documentation) at most |
| ASM-002 | Published policy text may be stale | SRC-004/SRC-005 values (10 INR, currency roles) are cited as "documented current model values", with re-check required before D06 final |
| ASM-003 | Payout-method/region availability is contradictory across sources | `payout_method` dimension frozen as To Be Verified (Section 6) |
| ASM-007 | 10 INR minimum and redemption ratios may have changed | Used only as the documented current model value; KPI-1 eligibility logic references it conditionally |
| ASM-008 | Internal engineering instrumentation is unknown | Every event, field, and state in D06 is Proposed or To Be Verified; nothing is claimed to exist |

### 12.5 Open questions (unresolved — owner stated)

| # | Question | Owner | Blocks |
|---|---|---|---|
| OQ-1 | The brief's 10 required withdrawal KPI areas and the 9 documentation fields per KPI have now been supplied and are incorporated in §11 (the GAP-005 six-item quote is only a partial excerpt, not the complete requirement). Remaining: confirm that no further D06 KPI areas or acceptance-criterion requirements exist beyond the supplied list, and confirm the Proposed reporting frequencies and stakeholder assignments in §11 | Internship team / Product | KPI section completeness (final confirmation) |
| OQ-2 | Authoritative payout-method list, regions, and current status (resolves ASM-003 / GAP-009) | Product/Payments | KPI-10 method dimension; KPI-1 method breakdown |
| OQ-3 | Is the withdrawal source-of-truth a transition log (one row per status change, per SF1) or a request table with a current status column? Formulas in Section 11 depend on this | Engineering | KPI-2…KPI-6 formulas |
| OQ-4 | Denominator for completion rate: all requests, or requests that left the pending state? | Product | KPI-7 definition |
| OQ-5 | Can a *completed* withdrawal later be reversed (the policy allows reversals but does not state from which states)? | Product/Payments | SF1 transition table |
| OQ-6 | Reason-code taxonomy for rejections/reversals/corrections (must be Proposed, per GAP-005 C2-style rule) | Product | KPI-4, KPI-5, S-1 dimensions |
| OQ-7 | Align D06 `withdrawal_reversed` with D05's `reward_reversed` / `reward_corrected` naming (D05 on hold) | D05/D06 authors | D08 event catalogue |
| OQ-8 | Current 10 INR threshold + any change history; VE↔INR conversion mechanism (not documented anywhere public) | Product | KPI-1 eligibility context |
| OQ-9 | Will a wallet/withdrawal dataset be supplied for D12/D13, or are D06 KPIs feasibility-tested against a deliberately constructed synthetic sample (labelled, method-documented) later? | Internship team / Client | Feasibility testing schedule |
| OQ-10 | What is the exact internal engineering timing for the VE balance debit upon withdrawal request (immediate hold vs debit upon approval), and what ledger posting model applies? | Engineering / Payments | Wallet balance reconciliation and ledger consistency |

---

## 13. Third-party and engineering dependencies

| Dependency | Why needed | Recorded in |
|---|---|---|
| Payout processors (UPI, Amazon Pay, Google Play, PayPal) | Outcomes are partly outside VELOOP's control; availability is region-dependent | SRC-003 limitation; ASM-003 |
| Product team | Current thresholds, ratios, method list, status/reason taxonomy | ASM-002/003/007 |
| Payments team | Method/region status, reversal-from-completed behaviour | OQ-2, OQ-5 |
| Engineering | What is actually instrumented today; transition-log vs request-table source of truth | ASM-008; OQ-3 |

Until these are answered, all D06 content remains within the Verified (public) / Proposed / To Be Verified classes — no item may be upgraded to "confirmed in production".

---

## 14. Relationship to other deliverables

| Deliverable | Relationship |
|---|---|
| D04 (approved) | Provides `user_id` semantics and the session/event identifier model used by all D06 joins |
| D05 (on hold) | Owns the reward-side lifecycle (`reward_credited/pending/reversed/corrected`, DCM-031); D06 owns the withdrawal side; naming must align (OQ-7) |
| D07 | Referral validity is one of SRC-004's review aspects; referral-lifecycle states are D07's (GAP-006) |
| D08 | SF1 and the D06 Proposed events feed the event catalogue; D08 must keep all of them Proposed until engineering confirms (ASM-008) |
| D09/D10 | D06 field tables (Sections 4, 5, 8) are inputs to the 75-field data dictionary and the logical model (wallet/exchange/withdrawal entities) |
| D11 | KPI-1…KPI-10 (Section 11) move into the 30-KPI catalogue with the same feasibility flags |
| D12/D13 | The supplied workbooks' wallet-adjacent fields (Section 12.1) and the `-0.1` observation are profiling/DQ inputs |
| D18 | The data gap (no wallet/withdrawal records in supplied data) is a named readiness risk |

---

## 15. Acceptance checks (self-check against documented requirements)

Checklist used on this draft (v0.1). "Pass" means the documented requirement is addressed in the draft; it does **not** mean the deliverable is approved.

| # | Documented requirement (source) | Addressed where | Result |
|---|---|---|---|
| 1 | Format: Document (register line 36) | Whole document | Pass |
| 2 | Work Package D, Days 9–10 scope (register line 36; tracker days 9–10) | §1, §3–§10 | Pass |
| 3 | SF1 Withdrawal Lifecycle as required output (register line 65; tracker days 9–10) | Companion file `sf1_withdrawal_lifecycle.md` | Pass |
| 4 | Tracker note Day 9: "Unsupported transaction types remain Proposed" | All non-public transaction types/states marked Proposed (§4, §5, §8, SF1) | Pass |
| 5 | Tracker note Day 10: "No success-rate claim may be derived yet" | §11 KPI-7, §1.4 | Pass |
| 6 | GAP-003 mitigation: "full transaction model to be built in Deliverable 06" | §3, §4.1, §5 (balance history + exchange fields) | Pass |
| 7 | GAP-004 mitigation: "reversal relationship modeling required in Deliverable 06" | §9 | Pass |
| 8 | Work Package D (D3) withdrawal KPI list: all 10 required KPI areas, each documented with all 9 fields (name, definition, formula, required data, data source, frequency, stakeholder, business purpose, limitations); GAP-005 status taxonomy Proposed, no invented internal codes | §11 (KPI-1…KPI-10 + §11.1 supplementary metrics); §8 | Pass (10/10 KPIs × 9/9 fields, individually verified; the GAP-005 six-item quote is a partial excerpt, not the complete requirement; OQ-1 final confirmation open) |
| 9 | GAP-009: contradiction documented; method dimension frozen To Be Verified | §6 | Pass |
| 10 | Evidence labels per register §Evidence policy | §1.3, every section | Pass |
| 11 | Integrity constraint #2 (no simulated results as actual VELOOP performance) | §1.4, §12.1, §12.3 | Pass |
| 12 | Integrity constraint #4 (do not claim proposed events/fields exist) | §7, §13, SF1 | Pass |
| 13 | C1–C4 acceptance criteria (if any) for D06 | **Not documented in workspace** — original brief absent | **Cannot check — OQ-1** |

---

## 16. Revision history

| Date | Version | Change |
|---|---|---|
| 2026-11-13 | v0.1 | First draft. Built from D02, D03 (DCM-019…023, GAP-003/004/005/009), SRC-001/003/004/005/006/007/009, ASM-001/002/003/007/008, and read-only inspection of both supplied workbooks. Companion SF1 file created. Not approved; pending OQ-1…OQ-10. |
| 2026-11-16 | v0.2 | Remediated file extension from `.md.txt` to `.md`. Corrected dangling reference to OQ-10 by formally defining OQ-10 in Section 12.5. Corrected SF1 cross-references in Section 1, Section 7, and Section 15. Added consolidated Unified Wallet Transaction Ledger Schema in Section 4.4 covering all 10 fields required by the official internship brief (Work Package D, D1). All ledger timing and debit rules kept explicitly marked To Be Verified. |
