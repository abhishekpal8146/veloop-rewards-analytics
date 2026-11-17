# SF1 — Withdrawal Lifecycle (Supporting Artifact for D06)

## 1. Artifact control

| | |
|---|---|
| Artifact | SF1 — Withdrawal Lifecycle |
| Enabling deliverables | D06 (Wallet & Withdrawal Analytics Specification), D08 (Event Tracking Plan) — per `docs\requirements_and_deliverable_register.md` (Supporting artifacts: "SF1 \| Withdrawal Lifecycle \| 06, 08") |
| Required output of | D06 — `registers\progress_tracker.csv` Days 9–10 ("required_outputs: 06; SF1") |
| Status | DRAFT v0.2 — remediated draft, in review |
| Date | 2026-11-13 |

### 1.1 Evidence labels

Same classes as the D06 main document (`wallet_withdrawal_analytics_specification.md` §1.3): **Verified (public website)**, **Supplied data**, **Proposed**, **To Be Verified**, **Assumption**.

**Status of this lifecycle:** the *outcomes* of a withdrawal are described qualitatively in the public Withdrawal & Reward Verification Policy (SRC-004) — a request "may be delayed, denied, or reversed", verification checks are performed, and "a submitted request does not automatically create a payout obligation". The policy publishes **no status enum, no reason codes, no transition rules, and no timestamps** (GAP-005). The lifecycle below is therefore a **Proposed** model: its state names and transition structure are a design proposal mapped onto those qualitatively public outcomes. No state, event, field, or reason code in this artifact is claimed to exist in production (ASM-008).

---

## 2. Lifecycle states (all Proposed)

| State | One-line meaning | Closest public evidence |
|---|---|---|
| `withdrawal_requested` | User chose a reward, entered payout details, and confirmed the request; amount subject to the documented 10 INR minimum (current model value) | SRC-003 (request flow, `/Payout?method=<name>`); SRC-004 (minimum amount) |
| `withdrawal_under_review` | Platform verification checks are running (account-level, transaction-level, behavioral, technical, or compliance) | SRC-004 (five check types) |
| `withdrawal_completed` | Request ended with a payout | SRC-004 (outcomes are qualitative; "completed" naming is Proposed) |
| `withdrawal_rejected` | Request ended without a payout | SRC-004 ("denied") |
| `withdrawal_reversed` | A payout or credit was taken back after the fact | SRC-004 ("reversed"); SRC-007 (fraud-related cancellation) |
| *(implicit) `withdrawal_pending`* | Request has been submitted but has not yet reached a terminal state; may be *delayed* | SRC-004 ("may be delayed"; D02 §5 row 20: "Request created as PENDING") |

Notes:
- The set of terminal states is {`withdrawal_completed`, `withdrawal_rejected`, `withdrawal_reversed`} (Proposed; see transition table below for the open question on reversal from completed).
- `withdrawal_pending` is shown as implicit because the public material references a PENDING creation state (D02 §5 row 20, citing the request flow) and a "delayed" outcome (SRC-004), but no pending-state semantics are publicly defined.

---

## 3. Transition table (all transitions Proposed)

| From | To | Trigger (Proposed wording; public evidence noted) | Timestamp recorded (Proposed field) |
|---|---|---|---|
| (none) | `withdrawal_requested` | User confirms the payout request (SRC-003 flow); eligibility and the 10 INR minimum (current model value, SRC-004) applied | `requested_timestamp` |
| `withdrawal_requested` | `withdrawal_under_review` | Verification checks begin (SRC-004 check types) | `transition_timestamp` |
| `withdrawal_under_review` | `withdrawal_completed` | Checks passed; payout proceeds. **A submitted request does not automatically create a payout obligation** (SRC-004) | `transition_timestamp` |
| `withdrawal_under_review` | `withdrawal_rejected` | Check(s) failed; request denied (SRC-004) | `transition_timestamp` + `reason_category` |
| `withdrawal_under_review` | `withdrawal_reversed` | Correction during/after review (SRC-004 "reversed"; exact semantics not public) | `transition_timestamp` + `reason_category` |
| `withdrawal_completed` | `withdrawal_reversed` | Post-completion reversal (fraud detection, correction). **Open: the policy allows reversals but does not state from which states — confirm, OQ-5** | `transition_timestamp` + `reason_category` |
| `withdrawal_requested` / `withdrawal_under_review` | (stays in pending) | Delayed by review (SRC-004 "may be delayed"); no terminal timestamp until a terminal transition occurs | — |

Rules that follow from the above (all Proposed):

1. One transition record per status change (fields: `withdrawal_id`, `status_from`, `status_to`, `transition_timestamp`, plus `reason_category` for rejected/reversed) — per DCM-023.
2. Every request has exactly one `withdrawal_requested` and at most one terminal transition.
3. A request may sit in pending/review without a terminal transition; time-in-pending is measurable from the last transition (supports "processing time" and "pending" KPIs).

---

## 4. Events mapped to this lifecycle (all Proposed)

| State | Proposed event (name per DCM-021/023 and D02 §6) | Confirmed to exist? |
|---|---|---|
| `withdrawal_requested` | `withdrawal_requested` | No — Proposed (ASM-008) |
| `withdrawal_under_review` | `withdrawal_under_review` | No — Proposed (ASM-008) |
| `withdrawal_completed` | `withdrawal_completed` | No — Proposed (ASM-008) |
| `withdrawal_rejected` | `withdrawal_rejected` | No — Proposed (ASM-008) |
| `withdrawal_reversed` | `withdrawal_reversed` | No — Proposed (ASM-008); naming must align with D05's `reward_reversed` (OQ-7) |
| pending/delayed | `withdrawal_pending` (listed in D02 §6) | No — Proposed (ASM-008) |

D08 will decide final event names and payloads; this artifact only fixes the lifecycle structure so D08 and D06 do not drift apart.

---

## 5. Data required to run the lifecycle (all Proposed)

| Field | Type | Required? | Purpose | Source / status |
|---|---|---|---|---|
| `withdrawal_id` | String | Required | Unique identifier of one withdrawal request | DCM-021; Proposed — no public identifier exists |
| `user_id` | String | Required | Requesting user (semantics per D04 §2.1) | DCM-021; join key |
| `payout_method` | Categorical | Required | Method chosen | DCM-021; **dimension frozen To Be Verified** (ASM-003, GAP-009 — sources conflict) |
| `requested_amount` | Decimal | Required | Amount requested | DCM-021; Proposed |
| `currency` | Categorical | Required | Currency of the request (VEs per current model; VE↔INR conversion not documented publicly) | DCM-021; Proposed |
| `requested_timestamp` | Datetime | Required | When the request was confirmed | DCM-021; Proposed |
| `eligibility_flags` | Categorical set | Conditional | Which SRC-004 review aspects applied (login status, region eligibility, payout details, task-completion validity, referral validity) | DCM-021; categories Verified (SRC-004), per-request values Proposed |
| `status_from` / `status_to` | Categorical (§2 states) | Required | One row per transition | DCM-023; Proposed |
| `transition_timestamp` | Datetime | Required | When the transition occurred | DCM-023; Proposed |
| `reason_category` | Categorical | Conditional (rejected/reversed) | Why — **taxonomy to be proposed, no public codes exist** (GAP-005, C2-style rule) | DCM-023; Proposed |
| `verifier_type` | Categorical | Conditional | Automated vs manual (distinction not public) | DCM-023; Proposed |

**Simulated data note:** neither workbook in `source datasets/` contains any field from this table (verified by full-text scan). The lifecycle has **zero** measurable instances in the supplied data.

---

## 6. Relationship to verification policy (Verified, SRC-004)

The public policy that anchors this lifecycle states:

1. Minimum withdrawal amount **10 INR** per the current platform model — changeable at any time (ASM-007; used strictly as "documented current model value").
2. Verification may be **account-level, transaction-level, behavioral, technical, or compliance**.
3. Review may cover **login status, region eligibility, payout details, task-completion validity, referral validity**.
4. Withdrawals **may be delayed, denied, or reversed**.
5. **"A submitted request does not automatically create a payout obligation."**

Every rule in §3 of this artifact is consistent with these five statements; nothing in this artifact asserts anything beyond them.

---

## 7. Open questions carried by this artifact

(Owners and details in D06 main document §12.5.)

- **OQ-3** — source-of-truth structure: transition log vs request table (changes how §3/§5 are consumed).
- **OQ-5** — can `withdrawal_completed` transition to `withdrawal_reversed`?
- **OQ-6** — reason-code taxonomy for rejection/reversal (Proposed, no public codes).
- **OQ-7** — alignment with D05 `reward_reversed` / `reward_corrected` naming.

---

## 8. Revision history

| Date | Version | Change |
|---|---|---|
| 2026-11-13 | v0.1 | First draft. Proposed lifecycle built on SRC-004 qualitative outcomes, DCM-021/022/023, GAP-005, and D02 §5–§7. Not approved; pending OQ-3/5/6/7. |
| 2026-11-16 | v0.2 | Remediated file extension from `.md.txt` to `.md`. Corrected cross-reference to main D06 document in §1.1. Lifecycle definitions, states, transition table, and fields unchanged. |
