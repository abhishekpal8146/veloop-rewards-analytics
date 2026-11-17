# VELOOP Rewards — Supporting Artifact SE2: Reward-Event Requirements

## 1. Document Overview

**Artifact ID:** SE2 — Reward-Event Requirements  
**Parent Deliverable:** Deliverable 05 — Earning & Reward Analytics Specification (`earning_reward_analytics_specification.md`)  
**Work Package:** C — Earning & Reward Analytics (Brief pages 8–9, Section C3)  
**Status:** DRAFT v0.1 — in review  
**Enables:** Deliverable 05 (Earning & Reward Analytics), Deliverable 06 (Wallet & Withdrawal Analytics), Deliverable 08 (Event Tracking Plan), Deliverable 10 (Logical Data Model), Deliverable 11 (KPI Catalogue), Deliverable 15 (Developer Analytics Handoff)  
**Scheduled Window:** Days 7–8 (per `registers\progress_tracker.csv`)  

### 1.1 Purpose

This supporting artifact establishes the event specifications, state transition mechanics, idempotency rules, and ledger integration requirements for platform reward events in VELOOP Rewards. It formally operationalizes the four mandatory reward events defined in Work Package C (Section C3, page 9) of the master brief:
1. **`reward_credited`**
2. **`reward_pending`**
3. **`reward_reversed`**
4. **`reward_corrected`**

### 1.2 Evidence Policy & Classification Standards

All statements, event names, and schemas in this document adhere to the project evidence framework:

| Label | Meaning in this Artifact |
|---|---|
| **Verified (public website)** | Documented in official VELOOP public sources (`SRC-001` through `SRC-010`), including the Platform Currency Policy (`SRC-005`), Disclaimer (`SRC-006`), and Help Center FAQ on system corrections and fraud cancellations (`SRC-007`). |
| **Supplied data** | Observed in `source datasets\VELOOP_Simulated_User_Behavior_1000.xlsx` sheet `05_Task_Activity`. Contains simplified synthetic states (`Credited`, `Not Credited`, `Pending`), which must not be confused with production architecture. |
| **Proposed** | Architectural designs, event schemas, payload definitions, and state machine models designed in this specification; requires engineering implementation. |
| **To Be Verified** | Unresolved operational decisions requiring confirmation from Engineering, Product, or Payments teams (Section 7). |
| **Assumption** | Documented in `registers\assumption_and_verification_register.csv` (`ASM-xxx`). |

---

## 2. The Core Architectural Separation Principle: Activity Occurrence vs. Reward Crediting

> [!CRITICAL]
> **Core Principle (Brief Page 9, Section C3 & GAP-002):**  
> *"The analyst must distinguish: activity occurred FROM reward was actually credited."*

### 2.1 Why Activity and Reward Must Be Decoupled

In naive analytics implementations, when a user finishes an ad, completes a survey, or clicks a button, the system records `task_completed` and immediately assumes the reward has been granted. In production rewards platforms, **this assumption leads to severe reporting errors, financial reconciliation failures, and fraud vulnerability**:

1. **Asynchronous Verification & External Postbacks:** Rewarded ads, offerwalls, and surveys rely on external third-party servers (`SRC-002`, `GAP-008`). A user may finish viewing an ad or filling a survey on their device, but the partner postback verifying completion may take seconds, minutes, or hours to arrive.
2. **Anti-Fraud & Quality Validation:** The platform policy explicitly states that task completions are subject to verification checks (`SRC-004`, `SRC-007`). Activities flagged for suspicious duration (speed-running), proxy/VPN usage, or emulator automation must be placed in a review state or denied before currency is created.
3. **Multi-Currency Payout Structures:** A single activity can yield heterogeneous virtual currencies (e.g., a mission granting 50 VEs + 100 XP + 1 Gem per `SRC-005`). A binary activity status cannot represent multi-currency ledger postings.
4. **Subsequent Reversals & Clawbacks:** External partners frequently conduct batch postback reconciliations (reversing fraudulent leads or chargebacks days after the fact). Platforms also exercise system correction rights (`SRC-006`, `SRC-007`). If rewards are tied directly to immutable activity records, retrospective balance reversals cannot be audited cleanly.

```
┌───────────────────────────────────────────────────────────────────────────────┐
│                           ANALYTICAL LIFECYCLE                                │
├───────────────────────────────────────────────────────────────────────────────┤
│                                                                               │
│  [User Engagement Layer]                                                      │
│    Discovery (task_viewed) ──► Start (task_started) ──► Completion (task_completed)
│                                                              │                │
│                                                              ▼                │
│  [Validation Engine / Partner Gateway]               Validation Engine        │
│                                                     (task_validated / failed) │
│                                                              │                │
│                                            ┌─────────────────┴─────────────┐  │
│                                            ▼                               ▼  │
│  [Reward State Machine]             reward_pending                  reward_credited
│                                            │                               │  │
│                                            ▼ (Validation Passed)           │  │
│                                     reward_credited                        │  │
│                                                                            ▼  │
│  [Unified Ledger Layer (D06 §4.4)]                                  reward_reversed /
│                                                                     reward_corrected
│                                                                               │
└───────────────────────────────────────────────────────────────────────────────┘
```

---

## 3. The Four Mandatory Reward Events

### 3.1 Event 1: `reward_credited`

#### Operational Meaning & Triggers
Emitted when a user has satisfied all validation checks and the platform has successfully posted virtual currency credits to the user's wallet ledger.
- **Triggers:** Immediate server-side validation pass for first-party activities (e.g., daily bonus, streak claim, captcha solve); or receipt of a cryptographically verified callback/postback from an external offerwall or ad network; or resolution of a previously pending reward.
- **Idempotency Requirement:** High. Must be protected by a unique composite key (`user_id + activity_id + reward_event_type`) to prevent double-crediting from duplicated network webhooks.

#### Event Payload Schema
```json
{
  "event_id": "evt_rc_901824a",
  "event_name": "reward_credited",
  "event_datetime": "2026-11-16T14:35:10.120Z",
  "user_id": "USR_000842",
  "session_id": "SES_004128",
  "activity_id": "ACT_009846",
  "task_id": "TSK_000045",
  "task_category": "Advertisement",
  "feature": "/watch-Ads",
  "reward_amount": 25.0000,
  "reward_unit": "VEs",
  "status": "CREDITED",
  "provider_id": "ADMOB_NETWORK",
  "external_transaction_id": "adm_tx_881924",
  "ledger_transaction_id": "WTX00048102",
  "wallet_balance_after": 325.0000
}
```

#### Downstream Ledger Integration (D06 Section 4.4 Master Ledger)
- Creates a record in the Unified Wallet Transaction Ledger with:
  - `transaction_id`: `"WTX00048102"`
  - `user_id`: `"USR_000842"`
  - `transaction_type`: `"reward_credit"`
  - `amount`: `25.0000`
  - `unit`: `"VEs"`
  - `status`: `"posted"`
  - `source`: `"watch_ads"`
  - `reference_id`: `"ACT_009846"`
  - `reversal_ref_id`: `null`

---

### 3.2 Event 2: `reward_pending`

#### Operational Meaning & Triggers
Emitted when an activity has completed from the user's perspective, but the reward cannot be credited immediately due to pending external validation, batch settlement latency, or automated risk review hold.
- **Triggers:** High-value survey completion awaiting partner verification; offerwall app-install requiring a 24-hour retention verification window; or risk scoring engine placing a transaction on hold due to velocity spikes (`SRC-004`).
- **User Impact:** Informs user UI that the reward is "In Review" or "Pending Partner Confirmation" rather than missing (FAQ item 14, `SRC-007`).

#### Event Payload Schema
```json
{
  "event_id": "evt_rp_104829b",
  "event_name": "reward_pending",
  "event_datetime": "2026-11-16T14:30:05.450Z",
  "user_id": "USR_000842",
  "session_id": "SES_004128",
  "activity_id": "ACT_009846",
  "task_id": "TSK_000082",
  "task_category": "Survey",
  "feature": "/surveys",
  "reward_amount_estimated": 150.0000,
  "reward_unit": "VEs",
  "status": "PENDING",
  "pending_reason": "PARTNER_AUDIT_WINDOW",
  "expected_resolution_window_hours": 24,
  "provider_id": "BITLABS_SURVEYS",
  "external_session_id": "bl_ses_991823"
}
```

#### Downstream Ledger Integration (D06 Section 4.4 Master Ledger)
- **Zero Available Balance Impact:** Pending rewards do NOT increase available wallet balances. If tracked in the ledger, `status = 'pending'`, preventing premature withdrawal requests.

---

### 3.3 Event 3: `reward_reversed`

#### Operational Meaning & Triggers
Emitted when previously credited virtual currency is officially deducted/revoked from a user's wallet ledger due to retrospective partner chargebacks, fraud detection, or terms-of-service violations.
- **Triggers:** Third-party offerwall notifies VELOOP of an invalid lead, simulated device spoof, or chargeback; post-hoc anti-fraud audit detects multi-accounting, emulator use, or bot automation (`SRC-004`, `SRC-007`); withdrawal verification review determines prior task completions were invalid and revokes rewards prior to payout.
- **Audit Requirement:** Must strictly reference the original `activity_id` and the original `ledger_transaction_id` being reversed.

#### Event Payload Schema
```json
{
  "event_id": "evt_rr_552194c",
  "event_name": "reward_reversed",
  "event_datetime": "2026-11-17T09:15:22.880Z",
  "user_id": "USR_000842",
  "activity_id": "ACT_009846",
  "original_event_id": "evt_rc_901824a",
  "reward_event_type": "reward_reversed",
  "reversal_amount": 25.0000,
  "reversal_unit": "VEs",
  "status": "REVERSED",
  "reversal_reason_category": "PARTNER_CHARGEBACK",
  "reversal_reason_details": "Partner reported emulator signature on postback audit",
  "provider_id": "ADMOB_NETWORK",
  "ledger_transaction_id": "WTX00049510",
  "reversal_ref_id": "WTX00048102",
  "wallet_balance_after": 300.0000
}
```

#### Downstream Ledger Integration (D06 Section 4.4 Master Ledger)
- In strict adherence to D06 Section 4.4, **reversals never mutate or delete original ledger rows**. An offsetting transaction is appended:
  - `transaction_id`: `"WTX00049510"`
  - `user_id`: `"USR_000842"`
  - `transaction_type`: `"reversal"`
  - `amount`: `25.0000`
  - `unit`: `"VEs"`
  - `status`: `"posted"`
  - `source`: `"watch_ads"`
  - `reference_id`: `"ACT_009846"`
  - `reversal_ref_id`: `"WTX00048102"` (points directly to original debit/credit)

---

### 3.4 Event 4: `reward_corrected`

#### Operational Meaning & Triggers
Emitted when a user's reward balance is manually or systemically adjusted to correct operational calculation discrepancies, currency migration errors, compensation for verified system downtime, or customer support dispute resolutions.
- **Triggers:** Administrative dispute resolution via Support Center (`SRC-007`); platform-wide compensation grant following verified partner SDK outage; correction of an incorrect exchange rate conversion or rounding artifact (`SRC-006`, `SRC-007`).
- **Governance:** Requires an authorized admin ID or certified automated correction script identifier.

#### Event Payload Schema
```json
{
  "event_id": "evt_rco_771829d",
  "event_name": "reward_corrected",
  "event_datetime": "2026-11-17T11:45:00.000Z",
  "user_id": "USR_000842",
  "activity_id": "ACT_009846",
  "reward_event_type": "reward_corrected",
  "correction_delta": 10.0000,
  "direction": "CREDIT",
  "reward_unit": "VEs",
  "status": "CORRECTED",
  "correction_reason_category": "SUPPORT_DISPUTE_RESOLUTION",
  "ticket_reference": "SUP_TKT_44819",
  "authorized_by": "ADMIN_OPS_04",
  "ledger_transaction_id": "WTX00049822",
  "reversal_ref_id": "WTX00048102",
  "wallet_balance_after": 310.0000
}
```

#### Downstream Ledger Integration (D06 Section 4.4 Master Ledger)
- Creates an adjustment entry:
  - `transaction_id`: `"WTX00049822"`
  - `user_id`: `"USR_000842"`
  - `transaction_type`: `"system_correction"`
  - `amount`: `10.0000`
  - `unit`: `"VEs"`
  - `status`: `"posted"`
  - `source`: `"admin_correction"`
  - `reference_id`: `"SUP_TKT_44819"`
  - `reversal_ref_id`: `"WTX00048102"`

---

## 4. Reward State Machine & Transition Rules

A reward lifecycle progresses through a formal finite state machine. Transitions are deterministic and bounded:

| Current State | Permitted Next States | Trigger Event | Transition Conditions & Rules |
|---|---|---|---|
| `NONE` | `CREDITED` | `reward_credited` | Activity completed and immediately validated (internal first-party task). |
| `NONE` | `PENDING` | `reward_pending` | Activity completed; validation requires external postback or batch verification. |
| `PENDING` | `CREDITED` | `reward_credited` | Partner postback received or validation engine approves transaction. |
| `PENDING` | `REJECTED` | `task_failed` (SE1) | Partner reports lead disqualified, or verification SLA expires without confirmation. |
| `CREDITED` | `REVERSED` | `reward_reversed` | Retrospective chargeback, fraud audit finding, or terms violation clawback. |
| `CREDITED` | `CORRECTED` | `reward_corrected` | Administrative dispute adjustment or balance recalculation. |
| `REVERSED` | *TERMINAL* | None | A reversed reward cannot transition back to credited. Any subsequent reimbursement requires a distinct new `reward_credited` or `reward_corrected` event. |
| `REJECTED` | *TERMINAL* | None | Final state for unapproved pending claims. |

### 4.2 Prohibited State Transitions
The following transitions are mathematically and operationally prohibited by system integrity constraints:
- `NONE` ➔ `REVERSED`: Currency cannot be reversed if it was never credited.
- `PENDING` ➔ `REVERSED`: A pending balance was never posted to available funds; it must transition to `REJECTED`, not `REVERSED`.
- `REVERSED` ➔ `CREDITED`: Direct state resurrection is forbidden to maintain ledger immutability.

---

## 5. Deduplication, Idempotency & Delivery Guarantees

Because rewarded ad networks and offerwalls transmit server-to-server callbacks across the public internet, duplicated webhooks and out-of-order deliveries are frequent occurrences (`GAP-008`).

### 5.1 Deduplication Key Architecture
To guarantee that no user receives duplicate rewards for a single activity, the ingest pipeline must enforce a unique composite constraint:
$$\text{Idempotency Key} = \text{SHA256}(\text{user\_id} \mathbin{\Vert} \text{activity\_id} \mathbin{\Vert} \text{reward\_event\_type} \mathbin{\Vert} \text{provider\_id})$$

1. **Ingest De-duplication:** Upon receiving a webhook or client completion call, the ingest layer checks the idempotency cache (e.g., Redis TTL 7 days).
2. **Duplicate Handling:** If the key already exists and status is `CREDITED`, the incoming message is acknowledged with HTTP `200 OK` (to satisfy partner retry logic) but discarded from analytical and ledger queues.
3. **Out-of-Order Webhook Protection:** If a `reward_reversed` arrives before `reward_credited` has processed, the system buffers the reversal in a dead-letter queue until the credit transaction is posted or resolves.

---

## 6. Empirical Grounding: Contrast with Simulated Dataset

The importance of this specification is proven by comparing it against the supplied simulated dataset (`source datasets\VELOOP_Simulated_User_Behavior_1000.xlsx` sheet `05_Task_Activity`):

| Analytical Capability | Simulated Dataset (`05_Task_Activity`) | Proposed Production Architecture (SE2) |
|---|---|---|
| **Reward States** | Only 3 static values (`Credited` [5,627], `Not Credited` [3,571], `Pending` [648]). | Formal state machine supporting `CREDITED`, `PENDING`, `REVERSED`, `CORRECTED`, `REJECTED`. |
| **Separation of Activity from Reward** | **Zero separation:** 100% of Completed tasks are Credited (5,627 / 5,627); 100% of Pending tasks are Pending (648 / 648); 100% of Failed/Abandoned are Not Credited. | Fully decoupled: Activity completion records user action; reward event records financial/ledger entitlement. |
| **Reversals & Corrections** | **Completely absent:** 0 reversal rows, 0 correction rows, 0 clawback tracking. | Explicit `reward_reversed` and `reward_corrected` events linked directly to D06 Section 4.4 Master Ledger. |
| **Reward Currency & Amounts** | **Completely absent:** No reward amount or currency unit exists in the sheet. | Full multi-currency support (`reward_amount`, `reward_unit` for VEs, XP, Gems, Tokens, Spins). |
| **External Partner Attribution** | **Completely absent:** No provider ID, webhook signature, or postback latency. | Dedicated provider tracking (`provider_id`, `external_transaction_id`) isolating third-party latency. |

> [!WARNING]
> Building production dashboards or financial models assuming the simulated dataset's 100% completion-to-credit conversion would severely distort business projections and hide partner clawback liabilities (`GAP-002`, `GAP-004`).

---

## 7. Open Questions & Engineering Verification Backlog

The following operational questions are registered in `registers\assumption_and_verification_register.csv`:

| Item ID | Technical Unknown | Why It Matters | Verification Owner | Status |
|---|---|---|---|---|
| **OQ-SE2-1** | What is the maximum clawback lookback window for partner offerwalls (e.g., 30 days vs 90 days)? | Determines data retention policies in the active cache and affects financial balance sheet closing. | Finance & Ad Operations | To Be Verified |
| **OQ-SE2-2** | What happens if a `reward_reversed` occurs after the user has already withdrawn their entire VE balance? | Determines whether user balance can go negative or if account is placed in restrictive recovery hold. | Payments / Product Risk | To Be Verified |
| **OQ-SE2-3** | Are secondary currencies (XP, Gems, Spins) subject to the same reversal policies as VEs? | Affects whether reversal schemas must support multi-currency cascade rollbacks. | Game Economy Designer | To Be Verified |
| **OQ-SE2-4** | What is the retry interval and maximum retry count for failed internal ledger postings? | Critical for pipeline reliability and ensuring zero dropped reward events. | Backend Engineering | To Be Verified |

---

## 8. Traceability & Revision History

### 8.1 Cross-Deliverable Traceability

- **Upstream Brief Requirements:** Directly fulfills Work Package C (Section C3, page 9) of `Data_Analyst_01 (4).pdf`.
- **Parent Deliverable:** Directly cited in Section 5 of `earning_reward_analytics_specification.md` (Deliverable 05).
- **Sister Deliverables:** Links directly to `sf1_withdrawal_lifecycle.md` and Section 4.4 of `wallet_withdrawal_analytics_specification.md` (Deliverable 06) for double-entry ledger alignment.
- **Downstream Deliverables:** Feeds Deliverable 08 (Event Tracking Plan), Deliverable 10 (Logical Data Model), Deliverable 11 (KPI Catalogue), and Deliverable 15 (Developer Analytics Handoff).

### 8.2 Revision History

| Version | Date | Author | Description of Changes | Status |
|---|---|---|---|---|
| **v0.1** | 2026-11-16 | Data Analyst Intern | Initial authoring of Supporting Artifact SE2. Defined architectural separation principle (activity vs reward), payload schemas and ledger integration for the 4 mandatory events (`reward_credited`, `reward_pending`, `reward_reversed`, `reward_corrected`), reward state machine, deduplication/idempotency rules, and simulated data contrast. Logged open questions OQ-SE2-1 through OQ-SE2-4. | DRAFT v0.1 — in review |
