# VELOOP Rewards — Earning & Reward Analytics Specification (D05)

## 1. Document Overview

**Deliverable:** D05 — Earning & Reward Analytics Specification  
**Work Package:** C — Earning & Reward Analytics (Brief pages 8–9, Sections C1, C2, C3, C4)  
**Status:** DRAFT v0.1 — in review  
**Scheduled Window:** Days 7–8 (per `registers\progress_tracker.csv`)  
**Companion Supporting Artifacts:**
- `se1_failed_activity_classification.md` (SE1 — Failed-Activity Classification Taxonomy)
- `se2_reward_event_requirements.md` (SE2 — Reward-Event Requirements & Separation of Activity from Reward)

---

### 1.1 Purpose

This specification establishes the analytical foundation, data schemas, telemetry requirements, and measurement methodologies for user earning behavior and virtual reward issuance across VELOOP Rewards. It defines how user engagement is captured through every phase of the analytical lifecycle—from discovery and task initiation through completion, validation, and reward posting into the platform's multi-currency wallet ledger.

### 1.2 Scope

This document specifies:
1. **The 5-Stage Analytical Lifecycle:** Discovery (`task_viewed`) → Start (`task_started`) → Completion (`task_completed`) → Validation (`task_validated` / `task_failed`) → Reward (`reward_credited` / `reward_pending`).
2. **C1 Task-Level Analytics:** Detailed specification of all 11 required fields (`task_id`, `task_type`, `feature`, `user_id`, `start_time`, `completion_time`, `status`, `reward_amount`, `reward_unit`, `validation_status`, `source_info`).
3. **C2 Failed Activity & Friction Modeling:** Executive synthesis of the 5 mandatory failure categories (`task_failed`, `tracking_failed`, `validation_failed`, `user_abandoned`, `system_error`) operationalized in companion artifact SE1.
4. **C3 Reward Events & Separation Architecture:** The fundamental architectural principle separating user activity from virtual currency crediting (`reward_credited`, `reward_pending`, `reward_reversed`, `reward_corrected`) operationalized in companion artifact SE2 and aligned with the Unified Wallet Ledger of D06.
5. **C4 Third-Party Dependencies:** Analytical risk isolation and tracking limitations for external rewarded video ad networks, offerwalls, survey providers, and social actions per official public policy (`SRC-002`).
6. **Empirical Grounding:** Full empirical profiling of the 9,846 records in simulated workbook sheet `05_Task_Activity`.
7. **Earning & Reward KPI Framework:** Standardized formulas, required fields, and feasibility assessments for 8 core product metrics.
8. **Open Questions:** Log of technical and policy unknowns (OQ-E1 through OQ-E6) logged for engineering and product confirmation.

**Out of Scope (Covered in Other Deliverables):**
- User identity semantics, registration, and session definitions (Deliverable 04).
- Fiat withdrawals, payout methods, and wallet balance reconciliations (Deliverable 06 & SF1).
- Referral trees and viral acquisition loops (Deliverable 07).
- Master event catalog construction and pipeline infrastructure (Deliverables 08, 09, 10, 16).

---

### 1.3 Evidence Policy & Classification Standards

All statements, field definitions, and formulas follow the project's evidence classification standards (`docs\requirements_and_deliverable_register.md`):

| Label | Meaning in this Specification |
|---|---|
| **Verified (public website)** | Confirmed by official VELOOP public documentation (`SRC-001` through `SRC-010`), including the Platform Currency Policy (`SRC-005`), Advertising & Offerwall Policy (`SRC-002`), Terms/Disclaimer (`SRC-006`), and published FAQ items (`SRC-007`). |
| **Supplied data** | Directly observed in the simulated assignment workbook `source datasets\VELOOP_Simulated_User_Behavior_1000.xlsx` sheet `05_Task_Activity`. Synthetically generated for testing; never represents actual VELOOP business metrics. |
| **Proposed** | Designed in this specification as a required production standard; not confirmed to exist in VELOOP today. |
| **To Be Verified** | Open technical question requiring confirmation from Engineering, Product, or Ad Operations (Section 10). |
| **Assumption** | Recorded in `registers\assumption_and_verification_register.csv` (`ASM-xxx`). |

> [!CRITICAL]
> **Data Authenticity Statement (Brief Page 1, Section 2 & Page 37, Section 30):**  
> VELOOP is a real product under development, but the data supplied for this assignment is fictional and simulated. The analyst must **never** represent simulated numbers as actual VELOOP users, task completion rates, ad engagement, reward issuance, or platform revenue.

---

## 2. Source References

The analytical requirements in this deliverable are derived from the official brief, public product surfaces, and Stage 2 registers:

| Source ID | Source Name / Location | Content Applied to this Deliverable | Status |
|---|---|---|---|
| **Brief C** | `Data_Analyst_01 (4).pdf` pages 8–9 | Work Package C: C1 (11 task fields), C2 (5 failure categories), C3 (4 reward events & separation principle), C4 (third-party dependencies) | Mandatory Brief Requirement |
| **SRC-002** | VELOOP Public Route Map & Advertising Policy | Public routes (`/watch-Ads`, `/watchAd-bonus`, `/tap-n-earn`, `/spin-wheel`, `/captcha-tasks`, `/giveaway-code`); Advertising & Offerwall Policy: "tracking limitations", external dependency caveats | Verified (public website) |
| **SRC-005** | Platform Currency Policy | Roles of the 6 virtual currencies: VEs (primary reward), XP (progression), Gems (rare/exchangeable), Tokens, Spins, Badges | Verified (public website) |
| **SRC-006** | Disclaimer & Terms of Service | Product rule: rewards, offers, and mechanisms may be changed, paused, reviewed, delayed, or removed at any time | Verified (public website) |
| **SRC-007** | Published FAQ (19 items) | Ad tracking delays (FAQ item 14), task validation rules (FAQ item 2), promo code restrictions, bot/VPN fraud cancellations, wallet correction rights | Verified (public website) |
| **D02** | `submission\02_product_data_audit\product_data_audit.md` | §4 (currencies), §5 rows 5–16 (earning features), §7 (system outcomes), §8.2 (ad tracking delays) | Stage 2 Deliverable |
| **D03** | `submission\03_data_coverage_matrix\data_coverage_matrix.csv` | DCM-005 through DCM-017 (earning features), DCM-029 through DCM-031 (reward states); `analytics_gaps.csv` GAP-002, GAP-004, GAP-008 | Stage 2 Deliverable |
| **D06** | `submission\06_wallet_withdrawal_analytics\` | Section 4.4 Unified Wallet Transaction Ledger Schema (D1 Master Model) for double-entry credit and reversal postings | Companion Specification |
| **Simulated Data** | `source datasets\VELOOP_Simulated_User_Behavior_1000.xlsx` | Sheet `05_Task_Activity`: 9,846 records across 8 task categories, 4 task statuses, 5 failure reasons, 3 reward statuses | Supplied Data |

---

## 3. The Basic Analytical Lifecycle

Per Work Package C of the master brief, earning analytics must investigate and measure the five sequential stages of the user earning lifecycle:

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Discovery  │ ──► │    Start    │ ──► │ Completion  │ ──► │ Validation  │ ──► │   Reward    │
│(task_viewed)│     │(task_started│     │(task_complet│     │(task_validat│     │(reward_credi│
│             │     │      )      │     │     ed)     │     │ ed / failed)│     │ted / pending│
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
       │                   │                   │                   │                   │
       ▼                   ▼                   ▼                   ▼                   ▼
 Impression /        User Enters         User Finishes       Server / Partner     Credit Posted
 Feed Display        Task Workflow       Action Criteria     Verifies Integrity   to Wallet Ledger
```

### 3.1 Stage 1: Discovery (`task_viewed`)
- **Operational Definition:** The user navigates to an earning surface (e.g., `/watch-Ads`, `/tap-n-earn`, `/daily-bonus`) and the client interface renders one or more available earning tasks, banners, or offer cards.
- **Telemetry Requirement:** Client-side impression tracking emitting `task_viewed` when an offer card satisfies standard viewport visibility rules (e.g., $\ge 50\%$ pixels visible for $\ge 1$ continuous second).
- **Analytical Value:** Establishes the top of the earning conversion funnel ($N_{\text{viewed}}$). Enables measurement of task catalog appeal, visual banner CTR, and impression-to-start drop-off.
- **Status in Simulated Dataset:** Evidenced via column `task_viewed_at` (populated for all 9,846 records).

### 3.2 Stage 2: Start (`task_started`)
- **Operational Definition:** The user expresses explicit intent by clicking an offer card, launching a rewarded video, initiating the tap-and-earn timer, or opening a captcha challenge.
- **Telemetry Requirement:** Immediate event emission `task_started` containing `user_id`, `session_id`, `task_id`, `task_category`, `feature`, and client timestamp. If the task relies on a third-party SDK (e.g., AdMob, Tapjoy), initialization parameters and partner placement IDs are bound here.
- **Analytical Value:** Marks active user commitment ($N_{\text{started}}$). Enables measurement of feature engagement, session depth, and user intent.
- **Status in Simulated Dataset:** Evidenced via column `task_started_at` (populated for all 9,846 records).

### 3.3 Stage 3: Completion (`task_completed`)
- **Operational Definition:** The user finishes the prescribed interactive activity (e.g., watches the video to the end, submits the captcha form, clicks the final daily bonus button, or finishes a survey questionnaire).
- **Telemetry Requirement:** Client emits `task_completed` with `task_completed_at` timestamp and preliminary payload (elapsed seconds, interaction step count). 
- **Critical Boundary Note:** This event indicates **user-claimed completion only**. It must **never** be treated as proof of reward entitlement or financial credit (GAP-002).
- **Status in Simulated Dataset:** Evidenced via column `task_completed_at` (populated for 5,627 rows; blank for all 4,219 uncompleted/pending rows).

### 3.4 Stage 4: Validation (`task_validated` / `task_failed`)
- **Operational Definition:** VELOOP backend verification services or external partner postback endpoints evaluate the integrity, authenticity, duration, and compliance of the completed task.
- **Verification Gates (SRC-004, SRC-007):**
  1. *Duration & Velocity Checks:* Ensuring user did not bypass timers (speed-running).
  2. *Anti-Fraud & Security:* Checking for VPN, proxy, multi-accounting, emulators, or auto-clickers (`SRC-007`).
  3. *Third-Party Partner Postback:* Cryptographic signature verification and confirmation of valid lead delivery (`SRC-002`).
  4. *Daily Frequency Caps:* Confirming user has not exceeded platform quotas for that task category.
- **Outcomes:** If passed, emits `task_validated`; if failed, emits `task_failed` with structured failure classification per companion artifact SE1.
- **Status in Simulated Dataset:** Column `validation_status` is **absent** as an explicit attribute, but reflected negatively via `failure_reason = 'Validation failed'` (732 rows).

### 3.5 Stage 5: Reward (`reward_credited` / `reward_pending`)
- **Operational Definition:** Following successful validation, the platform calculates virtual currency earnings and issues a formal credit transaction to the user's wallet ledger.
- **State Outcomes (Companion Artifact SE2):**
  - `reward_credited`: Currency immediately posted to the available balance.
  - `reward_pending`: Currency held in pending status awaiting asynchronous third-party settlement or manual fraud review.
  - Subsequent Lifecycle Events: `reward_reversed` (chargebacks/fraud clawbacks) and `reward_corrected` (system adjustments) per D06 Section 4.4 Master Ledger.
- **Status in Simulated Dataset:** Column `reward_status` contains static values `Credited` (5,627), `Not Credited` (3,571), and `Pending` (648). Currency amounts and units are absent.

---

## 4. C1 — Task-Level Analytics Specification

Work Package C1 requires the definition of **all 11 task-level analytical fields**. The table below specifies each field, its engineering data type, requirement level, analytical purpose, validation rules, and whether it is evidenced in the simulated data or Proposed for production:

| # | Field Name | Data Type | Required? | Description & Analytical Purpose | Allowed / Example Values | Status |
|---|---|---|---|---|---|---|
| 1 | `task_id` | String | Required | Unique identifier of the task template, ad placement, or campaign. Enables task-level performance comparisons and catalog rotation analysis. | `TSK_000012`, `AD_BANNER_04` | Evidenced in Sheet (`task_id`: 80 unique values) |
| 2 | `task_type` | Categorical | Required | High-level classification of the earning mechanism. Used for category-level engagement rollups and portfolio diversification. | `Advertisement`, `App Task`, `Survey`, `CAPTCHA`, `Social Activity`, `Game`, `Mission`, `Promotional Task` | Evidenced in Sheet (`task_category`: 8 categories) |
| 3 | `feature` | String / Route | Required | The application module, page route, or entry point where the user engaged with the task. Evaluates UI feature adoption. | `/watch-Ads`, `/tap-n-earn`, `/spin-wheel`, `/daily-bonus`, `/captcha-tasks`, `/giveaway-code` | Proposed (Derived from `SRC-002` route map) |
| 4 | `user_id` | String | Required | Immutable cross-feature identifier of the participating user. Primary foreign key linking task activity to user profiles, wallet balances, and referral records. | `USR_000842` | Evidenced in Sheet (`user_id`: 984 unique values) |
| 5 | `start_time` | Datetime (ISO 8601 UTC) | Required | Datetime when the user clicked start or launched the activity. Anchor for duration and latency calculations. | `2026-05-10T10:15:30Z` | Evidenced in Sheet (`task_started_at`) |
| 6 | `completion_time` | Datetime (ISO 8601 UTC) | Nullable | Datetime when user finished the task. Null if user abandoned or task failed before completion. | `2026-05-10T10:16:45Z` (null if uncompleted) | Evidenced in Sheet (`task_completed_at`: 5,627 populated, 4,219 null) |
| 7 | `status` | Categorical | Required | Terminal or active state of the task engagement attempt. Measures funnel progression. | `Completed`, `Abandoned`, `Failed`, `Pending` | Evidenced in Sheet (`task_status`) |
| 8 | `reward_amount` | Decimal(18,4) | Required | Nominal quantity of virtual currency granted or offered upon successful completion. | `10.0000`, `50.0000`, `1.0000` | Proposed (Absent from simulated workbook) |
| 9 | `reward_unit` | Categorical | Required | Virtual currency denomination earned. Aligned with platform currency roles (`SRC-005`). | `VEs`, `XP`, `Gems`, `Tokens`, `Spins`, `Badges` | Proposed (Absent from simulated workbook) |
| 10 | `validation_status` | Categorical | Required | Outcome of business validation, fraud scoring, and partner confirmation checks. Decouples task finish from reward entitlement (GAP-002). | `VALIDATED`, `PENDING_VALIDATION`, `FAILED_VALIDATION`, `EXEMPT` | Proposed (Absent as explicit column in sheet) |
| 11 | `source_info` | Structured Object / String | Required | Contextual metadata identifying client environment and distribution partner: `{device, session_id, provider_id, placement}`. Isolates vendor SDK issues. | `{"device":"Android", "session_id":"SES_004128", "provider_id":"ADMOB"}` | Partial in Sheet (`device`, `session_id`); `provider_id` Proposed |

---

### 4.1 Evidenced vs. Proposed Schema Comparison

To maintain absolute data integrity (Brief Page 43, Rule 11), the matrix below establishes what exists in the current simulated dataset versus what must be engineered for production:

```
┌──────────────────────────┬─────────────────────────────┬────────────────────────────────────────────────────────┐
│ Field Name (Brief C1)    │ Simulated Sheet 05 Status   │ Production Requirement (Proposed)                     │
├──────────────────────────┼─────────────────────────────┼────────────────────────────────────────────────────────┤
│ 1. task_id               │ Column: task_id (80 values) │ Retain string format; add versioning (task_id_v2)      │
│ 2. task_type             │ Column: task_category (8)   │ Retain 8 categories; add subcategory mapping           │
│ 3. feature               │ ABSENT                      │ Capture application route from client router (SRC-002) │
│ 4. user_id               │ Column: user_id (984 values)│ Enforce stable UUID/int join key across all tables     │
│ 5. start_time            │ Column: task_started_at     │ Enforce ISO-8601 UTC microsecond precision             │
│ 6. completion_time       │ Column: task_completed_at   │ Enforce nullability for uncompleted tasks              │
│ 7. status                │ Column: task_status (4)     │ Enforce formal state machine transitions               │
│ 8. reward_amount         │ ABSENT                      │ MANDATORY ADDITION: Decimal(18,4) virtual credit value │
│ 9. reward_unit           │ ABSENT                      │ MANDATORY ADDITION: Enum (VEs, XP, Gems, Tokens, etc.) │
│ 10. validation_status    │ ABSENT (only failure string)│ MANDATORY ADDITION: Explicit validation outcome enum   │
│ 11. source_info          │ Columns: device, session_id │ Bundle into structured telemetry context + provider_id │
└──────────────────────────┴─────────────────────────────┴────────────────────────────────────────────────────────┘
```

---

## 5. C2 — Failed Activity & Friction Modeling

When earning activity fails, recording a generic failure corrupts product funnel diagnostics. Work Package C2 requires a structured failure classification model.

### 5.1 Synthesis of Failure Categories (Detailed in Companion Artifact SE1)

The complete classification taxonomy, detection evidence, proposed production codes, and metric impacts are established in **Supporting Artifact SE1 (`se1_failed_activity_classification.md`)**. A summary of the five mandatory categories is presented below:

1. **`task_failed` (Category 1):** User attempted the task but failed objective rules (e.g., ran out of game lives, wrong trivia answer, puzzle timer expired). Indicates task difficulty friction.
2. **`tracking_failed` (Category 2):** Activity occurred, but telemetry, network packets, or third-party ad SDK postbacks were dropped, blocked by ad-blockers, or timed out. Indicates SDK/client telemetry infrastructure issues.
3. **`validation_failed` (Category 3):** Activity completion payload arrived, but anti-fraud algorithms or business rules rejected it (e.g., speed-run duration anomaly, proxy/VPN detected, duplicate claim). Protects currency economy from illicit inflation.
4. **`user_abandoned` (Category 4):** User voluntarily exited the task screen, dismissed the modal, or went inactive before completion. Indicates user experience friction or boring/intrusive content.
5. **`system_error` (Category 5):** Internal platform failure (HTTP 5xx API crashes, database write locks) or third-party partner inventory exhaustion ("No Ads Available"). Indicates engineering SLA degradation.

### 5.2 Summary of Simulated Dataset Failure Profiling

Empirical analysis of the 3,571 unrewarded records in simulated sheet `05_Task_Activity` reveals:
- **`Validation failed`:** 732 rows (431 Abandoned, 301 Failed) ➔ Maps to Category 3 (`validation_failed`).
- **`Task unavailable`:** 722 rows (409 Abandoned, 313 Failed) ➔ Maps to Category 5 (`system_error`).
- **`Timeout`:** 710 rows (425 Abandoned, 285 Failed) ➔ Maps to Category 2 (`tracking_failed`) or Category 4 (`user_abandoned`).
- **`Incomplete action`:** 706 rows (404 Abandoned, 302 Failed) ➔ Maps to Category 1 (`task_failed`).
- **`User exited`:** 701 rows (382 Abandoned, 319 Failed) ➔ Maps to Category 4 (`user_abandoned`).

*Refer to [SE1 §3–§4](file:///c:/Users/Abhishek%20pal/OneDrive/Documents/VEloop%20Internship/submission/05_earning_reward_analytics/se1_failed_activity_classification.md#L180-L245) for the complete empirical cross-mapping matrix and production disambiguation decision tree.*

---

## 6. C3 — Reward Events & Separation of Activity from Reward

### 6.1 The Core Decoupling Principle

Work Package C3 mandates that the analytics architecture must strictly distinguish:
$$\text{Activity Occurred} \quad \neq \quad \text{Reward Was Actually Credited}$$

This addresses **GAP-002** (Critical), where public documentation acknowledges ad tracking delays and task validation rules (`SRC-007`), but provides no defined lifecycle stages. Naive tracking that treats `task_completed` as an immediate balance increment exposes the platform to catastrophic fraud and accounting misstatements.

### 6.2 Synthesis of Reward Events (Detailed in Companion Artifact SE2)

The detailed event schemas, payload definitions, state transitions, and idempotency keys are established in **Supporting Artifact SE2 (`se2_reward_event_requirements.md`)**. The four mandatory reward events are:

1. **`reward_credited`:** Emitted when validation succeeds and virtual credits are posted to the user's available wallet balance.
2. **`reward_pending`:** Emitted when task completion requires asynchronous third-party postback verification, batch audit, or fraud review hold.
3. **`reward_reversed`:** Emitted when previously credited virtual currency is revoked due to retrospective partner chargebacks or post-hoc anti-fraud audits.
4. **`reward_corrected`:** Emitted when an administrative balance adjustment or system error compensation is applied per platform terms (`SRC-006`, `SRC-007`).

### 6.3 Seamless Integration with D06 Unified Wallet Ledger

To guarantee cross-deliverable consistency, all reward events connect directly to the **Unified Wallet Transaction Ledger Schema (D1 Master Model)** defined in D06 Section 4.4:
- `reward_credited` posts a ledger entry with `transaction_type = 'reward_credit'`, balance direction `Credit (+)`, referencing `activity_id`.
- `reward_reversed` posts an offsetting ledger entry with `transaction_type = 'reversal'`, balance direction `Debit (-)`, pointing `reversal_ref_id` to the original credit `transaction_id`.
- `reward_corrected` posts an offsetting ledger entry with `transaction_type = 'system_correction'`, balance direction `Credit (+)` or `Debit (-)`, pointing `reversal_ref_id` to the prior transaction.

*Refer to [SE2 §3](file:///c:/Users/Abhishek%20pal/OneDrive/Documents/VEloop%20Internship/submission/05_earning_reward_analytics/se2_reward_event_requirements.md#L75-L185) for full payload schemas and [D06 §4.4](file:///c:/Users/Abhishek%20pal/OneDrive/Documents/VEloop%20Internship/submission/06_wallet_withdrawal_analytics/wallet_withdrawal_analytics_specification.md#L138-L174) for the unified ledger schema.*

---

## 7. C4 — Third-Party Dependencies & Tracking Limitations

Work Package C4 requires the analyst to account for external systems (ad networks, surveys, offerwalls, games) and avoid designing analytics as though VELOOP controls every outcome.

### 7.1 Analysis of Public Documentation Evidence (SRC-002 & SRC-007)

The public **Advertising & Offerwall Policy (`SRC-002`)** contains explicit disclosures regarding external dependencies:
1. **Third-Party Control:** Rewarded ads, external offers, and surveys are powered by external SDKs and ad mediation networks. VELOOP does not control ad inventory, survey eligibility screeners, or external partner tracking servers.
2. **Documented "Tracking Limitations":** The policy explicitly states that tracking delays, network dropouts, or third-party attribution failures may prevent an offer from being recorded.
3. **FAQ Disclosures (SRC-007):** Published FAQ item 14 acknowledges "ad tracking delays, invalid completion, or third-party network issues" as reasons why rewards may not appear immediately.

### 7.2 Analytical Governance for External Dependencies

To prevent external vendor failures from corrupting internal product health reporting, the analytics layer must enforce four architectural boundaries:

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                    THIRD-PARTY RISK ISOLATION FRAMEWORK                         │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│  [1. Partner Identity Binding]                                                  │
│     Every external task event MUST record `provider_id` (e.g. ADMOB, UNITY,    │
│     TAPJOY, BITLABS) and `external_placement_id`.                               │
│                                                                                 │
│  [2. Asynchronous SLA Timeout Watchdog]                                         │
│     Tasks awaiting partner postbacks are placed in `reward_pending`. If no     │
│     callback arrives within SLA (e.g. 24 hours), the state auto-transitions to │
│     `tracking_failed` (TRK_SDK_POSTBACK_TIMEOUT) rather than hanging forever.   │
│                                                                                 │
│  [3. Metric Segregation (Core vs. Partner Health)]                              │
│     Product completion KPIs MUST separate first-party native tasks (Captcha,    │
│     Daily Bonus, Tapping) from third-party mediated tasks (Ads, Offerwalls).    │
│                                                                                 │
│  [4. Retrospective Reconciliation Handling]                                     │
│     Clawbacks from external ad networks are handled exclusively via             │
│     `reward_reversed` with reason `PARTNER_CHARGEBACK`, preserving ledger       │
│     immutability.                                                               │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

## 8. Simulated Data Profiling & Empirical Findings

To ensure our analytical specifications are tested against concrete data distributions, we perform a deep profile of `source datasets\VELOOP_Simulated_User_Behavior_1000.xlsx` sheet `05_Task_Activity`.

### 8.1 Dataset Dimensions & Entity Cardinality
- **Total Records:** Exactly **9,846 data rows** (excluding 1 header row).
- **Columns (12 in sheet):** `activity_id`, `user_id`, `task_id`, `task_category`, `task_viewed_at`, `task_started_at`, `task_completed_at`, `task_status`, `failure_reason`, `reward_status`, `device`, `session_id`.
- **Unique Users:** 984 unique `user_id` values (average $\approx 10.0$ task attempts per user).
- **Unique Tasks:** 80 unique `task_id` values across the platform.
- **Unique Sessions:** 4,612 unique `session_id` values (average $\approx 2.13$ task attempts per session).

### 8.2 Task Category Distribution
Activity is distributed across 8 distinct task categories in the simulated workbook:

| Task Category | Record Count | % of Total Activity | Observed Status Distribution |
|---|---|---|---|
| **`Advertisement`** | 2,203 | 22.38% | Completed: 1,284 \| Abandoned: 445 \| Failed: 326 \| Pending: 148 |
| **`App Task`** | 1,327 | 13.48% | Completed: 757 \| Abandoned: 279 \| Failed: 202 \| Pending: 89 |
| **`Survey`** | 1,259 | 12.79% | Completed: 712 \| Abandoned: 261 \| Failed: 202 \| Pending: 84 |
| **`CAPTCHA`** | 1,143 | 11.61% | Completed: 651 \| Abandoned: 236 \| Failed: 184 \| Pending: 72 |
| **`Social Activity`** | 1,020 | 10.36% | Completed: 588 \| Abandoned: 213 \| Failed: 153 \| Pending: 66 |
| **`Game`** | 1,008 | 10.24% | Completed: 579 \| Abandoned: 216 \| Failed: 148 \| Pending: 65 |
| **`Mission`** | 985 | 10.00% | Completed: 564 \| Abandoned: 202 \| Failed: 153 \| Pending: 66 |
| **`Promotional Task`** | 901 | 9.15% | Completed: 492 \| Abandoned: 199 \| Failed: 152 \| Pending: 58 |
| **Total** | **9,846** | **100.00%** | **Completed: 5,627 \| Abandoned: 2,051 \| Failed: 1,520 \| Pending: 648** |

### 8.3 Task Status & Reward Status Cross-Tabulation

| `task_status` | Rows | % Total | `reward_status = Credited` | `reward_status = Not Credited` | `reward_status = Pending` |
|---|---|---|---|---|---|
| **`Completed`** | 5,627 | 57.15% | 5,627 (100.0%) | 0 (0.0%) | 0 (0.0%) |
| **`Abandoned`** | 2,051 | 20.83% | 0 (0.0%) | 2,051 (100.0%) | 0 (0.0%) |
| **`Failed`** | 1,520 | 15.44% | 0 (0.0%) | 1,520 (100.0%) | 0 (0.0%) |
| **`Pending`** | 648 | 6.58% | 0 (0.0%) | 0 (0.0%) | 648 (100.0%) |
| **Total** | **9,846** | **100.00%** | **5,627 (57.15%)** | **3,571 (36.27%)** | **648 (6.58%)** |

### 8.4 Client Device Platform Distribution
- **Android:** 6,656 rows (67.60%) — dominant operating platform.
- **Windows:** 1,431 rows (14.53%) — desktop web usage.
- **iOS:** 1,254 rows (12.74%) — Apple mobile ecosystem.
- **macOS:** 505 rows (5.13%) — Apple desktop ecosystem.

### 8.5 Critical Analytical Deficiencies in Simulated Dataset
1. **Unrealistic 1:1 Conversion:** In the simulated workbook, exactly 100% of `Completed` tasks are credited, and exactly 100% of `Abandoned` and `Failed` tasks are not credited. Real production data experiences post-completion validation rejections, partial credits, and retrospective clawbacks (`GAP-002`, `GAP-004`).
2. **Missing Currency Fields:** The sheet contains no `reward_amount` or `reward_unit`. It is impossible to compute reward volume, average reward per ad, or economy inflation from this sheet without external assumptions.
3. **Missing Validation Audit Fields:** There is no explicit column indicating which validation checks ran or passed.
4. **Blank Timestamps:** All 4,219 uncompleted/pending records have blank `task_completed_at` timestamps, preventing duration analysis on abandoned attempts.

---

## 9. Earning & Reward KPI Framework

Per Work Package I (KPI Catalogue, Brief pages 18–20), each KPI must be specified using the formal 11-attribute standard:

---

### KPI-E01: Task Start-to-Completion Rate (Gross Completion Rate)
- **Definition:** The percentage of initiated task engagements that reach user-claimed completion.
- **Formula:** 
  $$\text{Task Completion Rate} = \frac{\text{Count}(\text{tasks where } \text{status} = \text{'Completed'})}{\text{Count}(\text{tasks where } \text{status} \in \{\text{'Completed'}, \text{'Abandoned'}, \text{'Failed'}, \text{'Pending'}\})} \times 100$$
- **Required Fields:** `activity_id`, `task_status`.
- **Data Source:** Task Activity log (`05_Task_Activity` / `task_completed` event).
- **Frequency:** Daily / Weekly.
- **Stakeholder:** Product Manager (Engagement), Game Economy Designer.
- **Business Purpose:** Measures user persistence and usability across task types.
- **Interpretation:** High completion rate indicates intuitive task instructions and balanced difficulty. A sudden drop signals broken video players or confusing steps.
- **Limitation:** Measures completion claim only, not validation validity or reward crediting.
- **Implementation Feasibility:** **Computable today from simulated data** (Observed baseline: $5,627 / 9,846 = 57.15\%$).

---

### KPI-E02: Task Validation Pass Rate
- **Definition:** The proportion of completed task submissions that satisfy business rules, duration thresholds, and anti-fraud checks.
- **Formula:**
  $$\text{Validation Pass Rate} = \frac{\text{Count}(\text{tasks where } \text{validation\_status} = \text{'VALIDATED'})}{\text{Count}(\text{tasks where } \text{status} = \text{'Completed'})} \times 100$$
- **Required Fields:** `activity_id`, `status`, `validation_status`.
- **Data Source:** Validation Engine service log / `task_validated` event.
- **Frequency:** Daily / Real-time monitoring.
- **Stakeholder:** Fraud & Risk Operations, Engineering.
- **Business Purpose:** Detects automated bot attacks, emulator abuse, or overly aggressive validation thresholds.
- **Interpretation:** A sharp decline indicates an active bot exploit wave or false-positive validation errors blocking legitimate users.
- **Limitation:** In simulated data, validation status is not an explicit column; can only be estimated inversely from failure reasons.
- **Implementation Feasibility:** **Requires Proposed Production Instrumentation** (Field `validation_status` must be logged).

---

### KPI-E03: End-to-End Earning Conversion Rate (Discovery-to-Credit)
- **Definition:** The percentage of task impressions that successfully result in credited virtual currency rewards.
- **Formula:**
  $$\text{Earning Conversion Rate} = \frac{\text{Count}(\text{unique activities with } \text{reward\_credited})}{\text{Count}(\text{unique activities with } \text{task\_viewed})} \times 100$$
- **Required Fields:** `task_viewed_at`, `reward_status`, `activity_id`.
- **Data Source:** Client impression telemetry and Unified Wallet Ledger.
- **Frequency:** Weekly.
- **Stakeholder:** Chief Executive Officer, Head of Product.
- **Business Purpose:** Holistic efficiency metric for the entire earning economy.
- **Interpretation:** Indicates how effectively catalog impressions convert into rewarded user value.
- **Limitation:** Viewport impression logging must be active and standardized across web and mobile apps.
- **Implementation Feasibility:** **Partially computable** from simulated data assuming every row represents a viewed task ($5,627 / 9,846 = 57.15\%$).

---

### KPI-E04: Reward Credit Latency (Lag Duration)
- **Definition:** The elapsed time in seconds between user task completion and wallet ledger credit posting.
- **Formula:**
  $$\text{Credit Latency} = \text{timestamp}(\text{reward\_credited}) - \text{timestamp}(\text{task\_completed})$$
- **Required Fields:** `task_completed_at`, `ledger_timestamp` / `event_datetime`.
- **Data Source:** Event stream (`task_completed` joined with `reward_credited`).
- **Frequency:** Hourly / Daily.
- **Stakeholder:** Backend Engineering, Partner Integrations Lead.
- **Business Purpose:** Tracks asynchronous processing delay and partner postback health.
- **Interpretation:** Low latency (<2 seconds) delivers immediate gamified dopamine. High latency (>300 seconds) triggers user frustration and support tickets.
- **Limitation:** Cannot be computed from simulated data because credit timestamps are absent.
- **Implementation Feasibility:** **Requires Proposed Production Instrumentation** (`reward_credited` timestamp).

---

### KPI-E05: Gross vs. Net Credited Reward Volume
- **Definition:** Total virtual currency credited to users minus total virtual currency reversed or clawed back within a reporting period.
- **Formula:**
  $$\text{Net Reward Volume} = \sum \text{amount}(\text{reward\_credited}) - \sum \text{amount}(\text{reward\_reversed}) \pm \sum \text{amount}(\text{reward\_corrected})$$
- **Required Fields:** `transaction_type`, `amount`, `unit`, `timestamp` (D06 Master Ledger).
- **Data Source:** Unified Wallet Transaction Ledger (`D06 §4.4`).
- **Frequency:** Daily / Monthly.
- **Stakeholder:** Finance, Economy Designer.
- **Business Purpose:** Tracks net currency supply expansion across VEs, XP, and Gems.
- **Interpretation:** Prevents economy hyperinflation. Highlights gross-to-net leakage from ad fraud or partner chargebacks.
- **Limitation:** Fictional simulated workbook contains zero reward amounts and zero reversals.
- **Implementation Feasibility:** **Requires Proposed Production Instrumentation** (D06 Unified Ledger + SE2 events).

---

### KPI-E06: Third-Party Partner Drop-Off & Postback Failure Rate
- **Definition:** The percentage of third-party mediated task starts that fail due to partner SDK timeouts, tracking errors, or inventory depletion.
- **Formula:**
  $$\text{Partner Failure Rate} = \frac{\text{Count}(\text{external tasks with } \text{failure\_category} \in \{\text{'tracking\_failed'}, \text{'system\_error'}\})}{\text{Count}(\text{external tasks started})} \times 100$$
- **Required Fields:** `task_started_at`, `provider_id`, `failure_category`.
- **Data Source:** Client SDK error pings + Ingest dead-letter logs.
- **Frequency:** Daily per partner provider.
- **Stakeholder:** Ad Operations, Vendor Partnerships.
- **Business Purpose:** Benchmarks external ad networks (AdMob vs Unity vs Tapjoy) to enforce vendor SLAs and optimize mediation waterfall.
- **Interpretation:** A provider with >10% failure rate should be deprioritized in the mediation waterfall.
- **Limitation:** Partner IDs do not exist in the simulated sheet.
- **Implementation Feasibility:** **Requires Proposed Production Instrumentation** (`provider_id` + SE1 failure schema).

---

### KPI-E07: Reward Reversal Rate (Clawback Rate)
- **Definition:** The ratio of reversed reward transactions to total credited reward transactions.
- **Formula:**
  $$\text{Reversal Rate} = \frac{\text{Count}(\text{reward\_reversed events})}{\text{Count}(\text{reward\_credited events})} \times 100$$
- **Required Fields:** `reward_event_type`, `activity_id`, `user_id`.
- **Data Source:** Reward event stream (SE2) / Wallet Ledger (D06).
- **Frequency:** Weekly / Monthly.
- **Stakeholder:** Risk & Compliance, Fraud Operations.
- **Business Purpose:** Measures post-credit audit discovery rate and partner reconciliation exposure.
- **Interpretation:** Spikes indicate retroactive ad fraud detection by external ad networks or coordinated user abuse.
- **Limitation:** Reversals are completely absent from the simulated dataset.
- **Implementation Feasibility:** **Requires Proposed Production Instrumentation** (`reward_reversed` event).

---

### KPI-E08: Daily Reward Velocity per Active User
- **Definition:** Average virtual credits (VEs) earned per active user within a 24-hour window.
- **Formula:**
  $$\text{Daily Reward Velocity} = \frac{\sum \text{reward\_amount}(\text{credited VEs on day } D)}{\text{Count}(\text{distinct } \text{user\_id}\text{ active on day } D)}$$
- **Required Fields:** `user_id`, `reward_amount`, `reward_unit`, `event_datetime`.
- **Data Source:** Unified Wallet Ledger joined with User Session table.
- **Frequency:** Daily.
- **Stakeholder:** Game Economy Designer, Executive Leadership.
- **Business Purpose:** Ensures earning pace matches target progression models without accelerating payout liability too rapidly.
- **Interpretation:** Steady velocity reflects stable engagement; extreme outlier velocity indicates automated exploitation.
- **Limitation:** Lacks reward amounts in simulated data.
- **Implementation Feasibility:** **Requires Proposed Production Instrumentation**.

---

## 10. Open Questions & Engineering Verification Backlog

To advance this specification from `DRAFT v0.1` to final production handoff, the following open technical questions are logged in `registers\assumption_and_verification_register.csv`:

| ID | Open Question / Technical Unknown | Why It Matters | Verification Owner | Status |
|---|---|---|---|---|
| **OQ-E1** | What is the maximum timeout threshold for asynchronous partner postbacks before a `Pending` task is classified as `tracking_failed`? | Avoids leaving pending rewards in user UI indefinitely while allowing sufficient time for slow survey/offerwall postbacks (`GAP-008`). | Mobile Engineering / Ad Ops | To Be Verified |
| **OQ-E2** | How should the platform handle partial task completion on multi-milestone offerwall tasks (e.g., reach level 5, 10, 15)? | Determines whether `activity_id` represents the entire campaign or individual milestone reward events. | Product / Offerwall Operations | To Be Verified |
| **OQ-E3** | What is the contractual clawback lookback window for ad network post-audit chargebacks? | Determines how long ledger transactions remain subject to potential `reward_reversed` events (`GAP-004`). | Finance & Legal | To Be Verified |
| **OQ-E4** | How should multi-currency rewards (e.g., mission granting VEs + XP + Gems) be structured in the reward event stream? | Determines whether to emit one parent reward event with an array payload or separate discrete reward events per currency unit. | Backend Architecture | To Be Verified |
| **OQ-E5** | Are daily bonuses and streak rewards governed by UTC calendar days or the user's localized device timezone? | Prevents double-claiming exploits across timezone boundaries and ensures streak continuity. | Product / Backend Engineering | To Be Verified |
| **OQ-E6** | Does the platform permit offline task caching (e.g. solving captchas or tap-and-earn while disconnected) with delayed synchronization? | Dictates replay attack protections and cryptographic timestamp verification on delayed uploads. | Security & Mobile Engineering | To Be Verified |

---

## 11. Acceptance Criteria & Cross-Deliverable Traceability

### 11.1 Verification Against Brief Work Package C
- [x] **C1 Task-Level Analytics:** All 11 required fields defined with types, nullability, analytical purpose, and simulated vs. proposed classification (Section 4).
- [x] **C2 Failed Activity:** Structured 5-category failure model synthesized in Section 5 and fully operationalized in companion artifact SE1 (`se1_failed_activity_classification.md`).
- [x] **C3 Reward Events & Separation Principle:** Explicit decoupling of activity completion from reward crediting synthesized in Section 6, operationalized in companion artifact SE2 (`se2_reward_event_requirements.md`), and mapped to D06 Unified Ledger.
- [x] **C4 Third-Party Dependencies:** Dedicated governance framework incorporating public policy evidence (`SRC-002`, `SRC-007`) and isolating external vendor risk (Section 7).
- [x] **Simulated Data Profiling:** Exact empirical audit of all 9,846 records, 8 categories, 4 statuses, 5 failure reasons, and missing attributes (Section 8).
- [x] **KPI Framework:** 8 core metrics specified using the formal 11-attribute standard (Section 9).
- [x] **Actionable Open Questions:** OQ-E1 through OQ-E6 recorded with owners and rationales (Section 10).

### 11.2 Traceability to Other Deliverables
- **Deliverable 02 (Product Data Audit):** Directly aligns with earning feature inventory (§5, rows 5–16) and system outcomes (§7).
- **Deliverable 03 (Data Coverage Matrix):** Resolves requirements for DCM-005…DCM-017, DCM-029…DCM-031; directly addresses Critical gaps **GAP-002**, **GAP-004**, and **GAP-008**.
- **Deliverable 04 (User Analytics):** Adheres to user identity semantics (`user_id`, `session_id`) and device dimensions.
- **Deliverable 06 (Wallet & Withdrawal):** Synchronizes reward credits, clawbacks, and adjustments directly with the Unified Wallet Ledger Schema (D1 Master Model, §4.4).
- **Deliverables 08, 09, 10, 11 (Downstream):** Directly feeds the Event Tracking Plan (D08), Data Dictionary (D09), Logical Data Model (D10), and KPI Catalogue (D11).

---

## 12. Revision History

| Version | Date | Author | Description of Changes | Status |
|---|---|---|---|---|
| **v0.1** | 2026-11-16 | Data Analyst Intern | Initial complete authoring of Deliverable 05 (Earning & Reward Analytics Specification). Formalized 5-stage analytical lifecycle, specified all 11 C1 task-level fields, synthesized C2 failure modeling (citing SE1) and C3 reward events (citing SE2), established C4 third-party dependency governance, documented empirical profiling of 9,846 rows in `05_Task_Activity`, defined 8 core KPIs, and logged open questions OQ-E1 through OQ-E6. | DRAFT v0.1 — in review |
