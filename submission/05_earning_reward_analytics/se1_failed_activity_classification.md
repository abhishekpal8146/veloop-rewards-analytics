# VELOOP Rewards — Supporting Artifact SE1: Failed-Activity Classification

## 1. Document Overview

**Artifact ID:** SE1 — Failed-Activity Classification  
**Parent Deliverable:** Deliverable 05 — Earning & Reward Analytics Specification (`earning_reward_analytics_specification.md`)  
**Work Package:** C — Earning & Reward Analytics (Brief pages 8–9, Section C2)  
**Status:** DRAFT v0.1 — in review  
**Enables:** Deliverable 05 (Earning & Reward Analytics), Deliverable 08 (Event Tracking Plan), Deliverable 13 (Data Quality Audit), Deliverable 18 (Analytics Readiness Assessment), Deliverable 20 (Implementation Backlog)  
**Scheduled Window:** Days 7–8 (per `registers\progress_tracker.csv`)  

### 1.1 Purpose

In a gamified rewards ecosystem like VELOOP Rewards, user earning journeys frequently fail to reach completion or reward crediting. When an activity does not result in a credited reward, treating the outcome as a simple binary flag (`is_success = FALSE`) destroys critical diagnostic information. Business stakeholders and engineering teams need to distinguish between:
1. A user who voluntarily lost interest and navigated away (funnel friction or engagement failure).
2. A client device that lost internet connectivity or an ad SDK callback that timed out (tracking and telemetry failure).
3. A user whose activity completed but was rejected by an anti-fraud heuristic or bot-check rule (integrity and validation failure).
4. A partner offerwall, ad network, or survey engine that failed or ran out of inventory (third-party dependency failure).
5. A backend database dead-lock, API timeout, or ledger service error (platform technical failure).

This supporting artifact establishes the official **Failed-Activity Classification Taxonomy** for VELOOP Rewards. It defines operational criteria, identification evidence, data capture requirements, and analytical impact for each of the five mandatory failure categories specified in Work Package C (Section C2, page 9) of the master brief.

### 1.2 Evidence Policy & Classification Standards

All statements, structures, and schemas in this document follow the evidence governance standards set in `docs\requirements_and_deliverable_register.md`:

| Label | Meaning in this Artifact |
|---|---|
| **Verified (public website)** | Explicitly documented on official VELOOP public surfaces (`SRC-001` through `SRC-010`), such as the Advertising & Offerwall Policy (`SRC-002`) and the published FAQ items on ad tracking delays and task validation (`SRC-007`). |
| **Supplied data** | Observed directly in the supplied simulated assignment workbook `source datasets\VELOOP_Simulated_User_Behavior_1000.xlsx` sheet `05_Task_Activity`. Represents synthetic testing patterns; never actual VELOOP company performance. |
| **Proposed** | Designed in this specification as a required production standard; requires engineering implementation. |
| **To Be Verified** | Open technical question requiring Engineering or Product confirmation (see Section 6). |
| **Assumption** | Documented in `registers\assumption_and_verification_register.csv` (`ASM-xxx`). |

> [!IMPORTANT]
> **Integrity Rule (Brief Page 9, Section C2 & Page 38, Section 30):**  
> "Do not invent internal failure codes if they do not exist. Instead, propose a structured classification and mark it **Proposed**."  
> All sub-reasons, error codes, and detection logic proposed in this document are explicitly marked **Proposed** to prevent unverified assumptions from being treated as production reality.

---

## 2. The 5 Mandatory Failure Categories

Work Package C2 of the official internship brief defines five mandatory failure categories. The table below outlines the high-level taxonomy:

| Category Code | Failure Category Name | Primary Locus of Failure | Measurable Impact on Product Funnel |
|---|---|---|---|
| `CAT-01` | **`task_failed`** | Task Rule / Objective | User attempted the action but did not meet objective completion criteria (e.g., failed game level, incorrect quiz answer). |
| `CAT-02` | **`tracking_failed`** | Telemetry / Network / SDK | Action may have occurred on client or third-party, but the tracking signal was lost, dropped, blocked, or timed out. |
| `CAT-03` | **`validation_failed`** | Business Rules / Anti-Fraud | Activity was recorded, but server-side validation or partner verification rejected it (e.g., speed-run anomaly, VPN, duplicate claim). |
| `CAT-04` | **`user_abandoned`** | User Choice / Behavioral Drop-off | User initiated the task but navigated away, closed the modal, or went inactive before meeting completion conditions. |
| `CAT-05` | **`system_error`** | Platform / Infrastructure | Internal VELOOP backend crash, database timeout, partner API HTTP 5xx outage, or service dependency breakdown. |

---

### 2.1 Category 1: `task_failed`

#### Operational Definition
The user actively engaged with the task and reached an evaluation point, but failed to satisfy the intrinsic success criteria defined by that specific task or game. The infrastructure operated normally, telemetry functioned, and the user did not drop out voluntarily; rather, the user did not achieve the required performance score or task milestone.

#### Identification Evidence & Triggers
- Client-side game engine reports a "Game Over" or "Lives Depleted" state before the target level/score is reached.
- Interactive quiz or math/knowledge challenge evaluates the submitted answer as incorrect.
- Timed challenge timer reaches zero before the user inputs the final required step.
- Task workflow returns a deterministic negative result based on user input (not platform failure).

#### Proposed Production Taxonomy (Sub-Reasons) — *Proposed*
- `TF_OBJECTIVE_NOT_MET`: User finished interaction but scored below passing threshold.
- `TF_LIVES_EXHAUSTED`: User ran out of allowed attempts or lives within the gamified mini-app.
- `TF_TIMER_EXPIRED`: Intrinsic countdown timer of the task reached zero during active play.
- `TF_INCORRECT_INPUT`: User submitted an incorrect solution (e.g., failed puzzle, wrong trivia choice).

#### Required Data Fields
```json
{
  "failure_category": "task_failed",
  "failure_reason_code": "TF_OBJECTIVE_NOT_MET",
  "score_achieved": 450,
  "score_required": 1000,
  "time_spent_seconds": 128,
  "attempts_used": 3,
  "max_attempts": 3
}
```

#### Analytical Treatment & Metric Impact
- **Drop-off vs. Ineligibility:** Counted as an active task engagement (`task_started = TRUE`), but excluded from successful task completions (`task_completed = FALSE`).
- **Difficulty Tuning:** High frequencies of `task_failed` in specific tasks signal that task difficulty or instruction clarity needs product rebalancing rather than technical bug triage.

---

### 2.2 Category 2: `tracking_failed`

#### Operational Definition
The user may have fulfilled the requirements of the task, but the analytical or attribution telemetry failed to reach VELOOP servers, was dropped in transit, or was blocked by client-side browser/device protections. This category also covers third-party postbacks and ad SDK callbacks that never arrived.

#### Identification Evidence & Triggers
- Rewarded ad SDK begins playback (`ad_started`), but no `ad_reward_callback` or `ad_completed` postback is received within the maximum SLA timeout window (e.g., 300 seconds).
- Ad-blocker or privacy extension blocks analytical heartbeat pings or network beacons.
- Device enters airplane mode, drops mobile data connection, or experiences socket termination before the completion event payload is transmitted.
- Third-party offerwall postback fails signature validation or is dropped due to network routing failure between partner and VELOOP servers (SRC-002, GAP-008).

#### Proposed Production Taxonomy (Sub-Reasons) — *Proposed*
- `TRK_SDK_POSTBACK_TIMEOUT`: Client SDK initiated third-party flow, but partner postback was never received within allowable window.
- `TRK_NETWORK_DISCONNECTION`: Client socket dropped or analytical ping queue failed to flush before app termination.
- `TRK_CLIENT_ADBLOCK_INTERFERENCE`: Telemetry endpoint or third-party tracking pixel blocked by client environment.
- `TRK_SIGNATURE_MISMATCH`: Incoming webhook failed cryptographic validation, indicating potential payload corruption or man-in-the-middle dropping.

#### Required Data Fields
```json
{
  "failure_category": "tracking_failed",
  "failure_reason_code": "TRK_SDK_POSTBACK_TIMEOUT",
  "provider_id": "ADMOB_SDK_V9",
  "external_placement_id": "rewarded_video_earn_01",
  "client_sdk_version": "v2.1.0",
  "network_type": "4G",
  "ping_latency_ms": null,
  "timeout_threshold_seconds": 300
}
```

#### Analytical Treatment & Metric Impact
- **Funnel Distortion:** Inflates the apparent gap between `task_started` and `task_completed`.
- **Customer Support Load:** High `tracking_failed` rates directly correlate with user support tickets regarding "uncredited rewards" (FAQ item 14, SRC-007).
- **Attribution Isolation:** Must be isolated from core product completion metrics so engineering can benchmark SDK vendor reliability independently.

---

### 2.3 Category 3: `validation_failed`

#### Operational Definition
The task completion signal was received by VELOOP servers, but the business validation engine, fraud detection heuristic, or compliance rule rejected the submission as invalid, fraudulent, suspicious, or ineligible.

#### Identification Evidence & Triggers
- **Duration Anomaly (Speed-Running):** A task requiring an estimated 60 seconds (e.g., 30-second video ad + 30-second interaction) was submitted with a completion timestamp only 3 seconds after start time (`elapsed_seconds < min_valid_duration`).
- **Captcha Verification Failure:** User failed image recognition challenge, OCR prompt, or exceeded allowed captcha attempts (`/captcha-tasks`).
- **Device & Location Fraud:** Request IP originated from an unauthorized proxy, data center, or known VPN range violating platform rules (SRC-007, "multiple-accounts-and-vpn").
- **Automation / Bot Detection:** Client telemetry lacks valid human touch interaction entropy (e.g., auto-clicker, emulator footprint, headless browser per SRC-007).
- **Daily Quota / Frequency Capping:** User attempted to claim an earning activity beyond the platform-enforced limit per calendar day.

#### Proposed Production Taxonomy (Sub-Reasons) — *Proposed*
- `VAL_SPEED_RUN_ANOMALY`: Interaction completed faster than mathematically or humanly possible.
- `VAL_CAPTCHA_FAILED`: User input did not match verification challenge token.
- `VAL_PROXY_OR_VPN_DETECTED`: Connection flagged by IP reputation / proxy-detection layer.
- `VAL_BOT_OR_EMULATOR_DETECTED`: Environment flagged as automated script, emulator, or auto-clicker.
- `VAL_DUPLICATE_CLAIM`: Completion hash already processed for this user/session.
- `VAL_DAILY_LIMIT_EXCEEDED`: User already consumed platform cap for this task type.

#### Required Data Fields
```json
{
  "failure_category": "validation_failed",
  "failure_reason_code": "VAL_SPEED_RUN_ANOMALY",
  "task_duration_seconds": 2.8,
  "min_acceptable_duration_seconds": 30.0,
  "client_ip_risk_score": 12,
  "vpn_detected": false,
  "validation_engine_rule_id": "RULE_DUR_MIN_01"
}
```

#### Analytical Treatment & Metric Impact
- **Clean vs. Dirty Activity:** Excluded from legitimate reward queues; prevents illicit wallet balance expansion.
- **Fraud Risk Score:** Feeds user-level risk profiles and anti-fraud monitoring (Work Package P / Deliverable 17).
- **Separation of Activity from Reward:** Provides the primary operational justification for why `task_completed` must not trigger automatic `reward_credited` (GAP-002).

---

### 2.4 Category 4: `user_abandoned`

#### Operational Definition
The user voluntarily initiated the task but deliberately navigated away, closed the task container, minimized the application, or allowed the session to expire through inactivity before completing the required actions.

#### Identification Evidence & Triggers
- User clicks the explicit "Close", "Back", or "Cancel" button on a task modal or offer screen.
- Browser/app lifecycle event `visibilitychange` detects document hidden or app sent to background, followed by session termination without completion.
- Client inactivity watchdog detects no touch, scroll, or input events for longer than the abandonment threshold (e.g., 180 seconds).
- Route transition event: User navigates away from `/watch-Ads`, `/tap-n-earn`, or `/spin-wheel` to another platform page while a task state is active.

#### Proposed Production Taxonomy (Sub-Reasons) — *Proposed*
- `ABN_USER_EXITED`: User explicitly dismissed the modal, clicked back, or closed the task view.
- `ABN_NAVIGATED_AWAY`: User clicked an internal navigation link before completing the task.
- `ABN_SESSION_INACTIVITY`: User became completely inactive during task workflow until session timeout.
- `ABN_APP_BACKGROUNDED`: Mobile application sent to background and destroyed by operating system memory management.

#### Required Data Fields
```json
{
  "failure_category": "user_abandoned",
  "failure_reason_code": "ABN_USER_EXITED",
  "interaction_step_reached": 2,
  "total_steps_in_task": 5,
  "time_elapsed_before_exit_seconds": 18.4,
  "exit_trigger": "modal_close_button_clicked",
  "next_route": "/daily-bonus"
}
```

#### Analytical Treatment & Metric Impact
- **Friction & Usability Indicator:** Identifies complex, boring, intrusive, or confusing tasks.
- **Conversion Funnel Step-Loss:** Mapped in step-by-step funnel drop-off analytics to identify the exact screen or step where users lose interest.
- **Engagement Health:** High abandonment on specific partner offers signals poor ad relevance or low reward-to-effort ratio.

---

### 2.5 Category 5: `system_error`

#### Operational Definition
The failure occurred due to internal VELOOP technical faults, infrastructure instability, database transaction failures, third-party partner service downtime (HTTP 5xx), or inventory exhaustion that prevented the user from finishing or receiving validation for their activity.

#### Identification Evidence & Triggers
- Internal API returns HTTP status `500 Internal Server Error`, `502 Bad Gateway`, or `504 Gateway Timeout`.
- Partner offerwall or survey provider API returns HTTP `503 Service Unavailable` or error payload `no_inventory_available`.
- Relational database transaction rollback or deadlock during task state transition recording.
- Task configuration missing in database (e.g., task expired on backend while still displayed on client).

#### Proposed Production Taxonomy (Sub-Reasons) — *Proposed*
- `SYS_INTERNAL_API_ERROR`: VELOOP application service threw an unhandled exception.
- `SYS_DB_TIMEOUT_OR_DEADLOCK`: Database write operation failed during task state capture.
- `SYS_PARTNER_API_OUTAGE`: External third-party server returned HTTP 5xx or connection refused.
- `SYS_TASK_UNAVAILABLE_OR_EXPIRED`: Task was depleted or deactivated concurrently while user was starting it.
- `SYS_INSUFFICIENT_INVENTORY`: Ad exchange or survey provider had no eligible inventory to serve.

#### Required Data Fields
```json
{
  "failure_category": "system_error",
  "failure_reason_code": "SYS_TASK_UNAVAILABLE_OR_EXPIRED",
  "http_status_code": 503,
  "error_trace_id": "err_c05_98124a",
  "failing_service": "partner_ad_bridge_svc",
  "upstream_provider_error": "INVENTORY_EXHAUSTED"
}
```

#### Analytical Treatment & Metric Impact
- **Platform Stability SLA:** Directly impacts technical availability metrics, engineering alerts, and backend uptime dashboards.
- **No User Penalty:** System errors must never penalize user streak counters, trust scores, or daily eligibility limits.
- **Automated Fallback:** Should trigger user-facing recovery messaging ("Task currently unavailable, please try again later") rather than silent failure.

---

## 3. Empirical Grounding: Profiling the Simulated Dataset

To test the applicability and coverage of this classification framework against real data distributions, we analyze the supplied simulated workbook: `source datasets\VELOOP_Simulated_User_Behavior_1000.xlsx` sheet `05_Task_Activity`.

### 3.1 Overview of Unrewarded Records

Across the 9,846 total activity records in `05_Task_Activity`:
- **Credited Records:** 5,627 rows (57.15%) — all have `task_status = 'Completed'`, non-null `task_completed_at`, and `reward_status = 'Credited'`.
- **Pending Records:** 648 rows (6.58%) — all have `task_status = 'Pending'`, blank `task_completed_at`, and `reward_status = 'Pending'`.
- **Unrewarded Records (Failures & Drop-offs):** **3,571 rows (36.27%)** — all have `reward_status = 'Not Credited'` and blank `task_completed_at`.

The 3,571 unrewarded records split across two recorded task statuses:
- `task_status = 'Abandoned'`: 2,051 records (57.43% of unrewarded)
- `task_status = 'Failed'`: 1,520 records (42.57% of unrewarded)

### 3.2 Analysis of Observed Synthetic Failure Reasons

The simulated workbook populates `failure_reason` exclusively for the 3,571 unrewarded records. Exactly five distinct string values appear in the dataset:

| Observed `failure_reason` in Simulated Sheet | Rows in `task_status = Abandoned` | Rows in `task_status = Failed` | Total Rows | % of Unrewarded (3,571) | % of Total Dataset (9,846) |
|---|---|---|---|---|---|
| **`Validation failed`** | 431 | 301 | **732** | 20.50% | 7.43% |
| **`Task unavailable`** | 409 | 313 | **722** | 20.22% | 7.33% |
| **`Timeout`** | 425 | 285 | **710** | 19.88% | 7.21% |
| **`Incomplete action`** | 404 | 302 | **706** | 19.77% | 7.17% |
| **`User exited`** | 382 | 319 | **701** | 19.63% | 7.12% |
| **Total Unrewarded Records** | **2,051** | **1,520** | **3,571** | **100.00%** | **36.27%** |

*(Note: In the remaining 6,275 rows consisting of 5,627 Completed and 648 Pending records, `failure_reason` is empty/blank.)*

### 3.3 Critical Data Quality Finding: Synthetic Distribution & Semantic Overlap

Inspection of the table above reveals two major empirical realities of the simulated dataset:
1. **Perfect Uniformity:** Each of the 5 synthetic failure reasons accounts for almost exactly 20% of the unrewarded records (ranging narrowly between 701 and 732 rows). This is a hallmark of synthetic random assignment rather than organic user behavior.
2. **Semantic Status Inconsistency:** In the simulated sheet, `Validation failed` appears in 431 rows where `task_status = 'Abandoned'`. Semantically, if a user abandoned a task before submitting it, server-side validation could not have been evaluated. Conversely, `User exited` appears in 319 rows where `task_status = 'Failed'`. 

This highlights why production systems require an unambiguous, mutually exclusive two-tier taxonomy: a high-level **Failure Category** (`failure_category`) paired with a specific **Failure Reason Code** (`failure_reason_code`).

---

## 4. Cross-Mapping: Simulated Reasons to Official Production Taxonomy

To enable backwards compatibility with simulated historical audits while establishing rigorous production standards for future engineering, we map each of the 5 observed simulated strings to the 5 official brief categories:

| Observed Simulated String (`failure_reason`) | Official Brief Category | Proposed Production Code | Mapping Logic & Justification |
|---|---|---|---|
| **`Validation failed`** | `validation_failed` | `VAL_SYNTHETIC_GENERAL` | Maps directly to Category 3. Indicates task submission was evaluated by validation logic or anti-fraud rules and rejected. |
| **`Task unavailable`** | `system_error` | `SYS_TASK_UNAVAILABLE_OR_EXPIRED` | Maps to Category 5. The task could not be delivered, was depleted of budget/inventory, or expired on backend while user initiated it. |
| **`Timeout`** | `tracking_failed` *or* `user_abandoned` | `TRK_SDK_POSTBACK_TIMEOUT` / `ABN_SESSION_INACTIVITY` | Context-dependent: If client was waiting on partner callback, maps to Category 2 (`tracking_failed`). If user remained idle on screen, maps to Category 4 (`user_abandoned`). |
| **`Incomplete action`** | `task_failed` | `TF_OBJECTIVE_NOT_MET` | Maps to Category 1. The user interacted but did not fulfill the minimum actions required to trigger task completion. |
| **`User exited`** | `user_abandoned` | `ABN_USER_EXITED` | Maps to Category 4. The user voluntarily dismissed the task view or closed the browser/app. |

### 4.1 Production Disambiguation Decision Tree

In production implementation (Deliverable 08 / Deliverable 15), client applications and backend ingest services must evaluate the following deterministic logic before assigning the category:

```
[Task Unfinished / Not Credited]
       │
       ├─► Did the user close the UI or navigate away?
       │     └─► YES: Assign `user_abandoned` (`ABN_USER_EXITED` or `ABN_NAVIGATED_AWAY`)
       │
       ├─► Did the user fail game objectives or input incorrect data?
       │     └─► YES: Assign `task_failed` (`TF_OBJECTIVE_NOT_MET` or `TF_INCORRECT_INPUT`)
       │
       ├─► Was task submitted, but server/anti-fraud rejected it?
       │     └─► YES: Assign `validation_failed` (`VAL_SPEED_RUN_ANOMALY` or `VAL_CAPTCHA_FAILED`)
       │
       ├─► Did backend crash, database fail, or partner return 5xx?
       │     └─► YES: Assign `system_error` (`SYS_INTERNAL_API_ERROR` or `SYS_PARTNER_API_OUTAGE`)
       │
       └─► Did network disconnect or partner SDK fail to send postback within SLA?
             └─► YES: Assign `tracking_failed` (`TRK_SDK_POSTBACK_TIMEOUT` or `TRK_NETWORK_DISCONNECTION`)
```

---

## 5. Unified Failure Event Schema & Properties

When any task fails, is abandoned, or fails validation, the instrumentation layer must emit a structured `task_failed` analytical event. The required schema is specified below:

| Field Name | Data Type | Required? | Category / Example | Purpose & Analytical Value | Status |
|---|---|---|---|---|---|
| `event_id` | UUID string | Yes | `evt_f781a90c-34` | Unique surrogate key for event deduplication | Proposed |
| `event_datetime` | ISO-8601 UTC | Yes | `2026-11-16T14:30:00Z` | Event occurrence timestamp | Proposed |
| `user_id` | String | Yes | `USR_000842` | Stable user identifier joining to user profile | Evidenced in Sheet |
| `session_id` | String | Yes | `SES_004128` | Session identifier for session journey reconstruction | Evidenced in Sheet |
| `activity_id` | String | Yes | `ACT_009846` | Unique transaction ID of the task attempt | Evidenced in Sheet |
| `task_id` | String | Yes | `TSK_000045` | Specific task identifier | Evidenced in Sheet |
| `task_category` | Enum string | Yes | `Advertisement`, `Survey`, etc. | High-level earning mechanism category | Evidenced in Sheet |
| `failure_category` | Enum string | Yes | `task_failed`, `tracking_failed`, `validation_failed`, `user_abandoned`, `system_error` | The 5 mandatory brief categories | Proposed |
| `failure_reason_code` | String | Yes | `VAL_SPEED_RUN_ANOMALY` | Granular proposed production reason code | Proposed |
| `failure_stage` | Enum string | Yes | `DISCOVERY`, `START`, `EXECUTION`, `VALIDATION` | Stage of lifecycle where failure occurred | Proposed |
| `elapsed_seconds` | Float | Yes | `14.2` | Seconds between `task_started_at` and failure event | Proposed |
| `device` | String | Yes | `Android`, `iOS`, `Windows`, `macOS` | Client operating platform | Evidenced in Sheet |
| `provider_id` | String | No | `ADMOB`, `TAPJOY`, `POLLFISH`, `INTERNAL` | Third-party partner identifier (if external) | Proposed |
| `error_details` | String / JSON | No | `{"http_code": 504, "timeout_ms": 10000}` | Diagnostic technical metadata (no PII/secrets) | Proposed |

---

## 6. Open Questions & Engineering Verification Backlog

To finalize this classification model for production deployment, the following technical questions are logged in `registers\assumption_and_verification_register.csv`:

| Item ID | Technical Unknown | Why It Matters | Verification Owner | Status |
|---|---|---|---|---|
| **OQ-SE1-1** | What is the maximum allowable SLA timeout for rewarded ad and offerwall postbacks before marking the attempt as `tracking_failed`? | If timeout is set too short, valid late postbacks will arrive after failure is recorded; if too long, user experience hangs indefinitely. | Mobile Engineering / Ad Operations | To Be Verified |
| **OQ-SE1-2** | Does the platform currently log client-side modal dismissals, or are drop-offs only inferred through backend session timeouts? | Required to reliably distinguish `user_abandoned` from `tracking_failed`. | Frontend Web & App Teams | To Be Verified |
| **OQ-SE1-3** | What minimum duration thresholds exist per task category to trigger `VAL_SPEED_RUN_ANOMALY`? | Thresholds must be calibrated per task type to prevent false positives on fast human users. | Fraud & Risk Operations | To Be Verified |
| **OQ-SE1-4** | When a partner offerwall returns "No Inventory", should the client suppress the task card dynamically or record a `system_error`? | Affects whether inventory exhaustion is treated as an error or normal dynamic catalog filtering. | Product Management | To Be Verified |

---

## 7. Traceability & Revision History

### 7.1 Cross-Deliverable Traceability

- **Upstream Brief Requirements:** Directly fulfills Work Package C (Section C2, page 9) of `Data_Analyst_01 (4).pdf`.
- **Parent Deliverable:** Directly cited in Section 4 of `earning_reward_analytics_specification.md` (Deliverable 05).
- **Public Evidence Base:** Aligned with `SRC-002` (Advertising & Offerwall Policy: tracking limitations) and `SRC-007` (FAQ items on ad tracking delays and task validation).
- **Downstream Deliverables:** Feeds event taxonomy in Deliverable 08 (Event Tracking Plan), data dictionary attributes in Deliverable 09, and anomaly detection rules in Deliverable 13 (Data Quality Audit).

### 7.2 Revision History

| Version | Date | Author | Description of Changes | Status |
|---|---|---|---|---|
| **v0.1** | 2026-11-16 | Data Analyst Intern | Initial authoring of Supporting Artifact SE1. Formulated definitions, detection evidence, proposed sub-taxonomies, schemas, and analytical impacts for the 5 mandatory brief categories. Profiled 3,571 unrewarded records from simulated sheet `05_Task_Activity` and constructed the cross-mapping matrix. Logged open questions OQ-SE1-1 through OQ-SE1-4. | DRAFT v0.1 — in review |
