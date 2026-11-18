# VELOOP Rewards — Product Analytics, Data Readiness & Data Management Blueprint

Documentation-and-specification repository for the VELOOP Rewards Data Analyst internship (Task 01).
The deliverables are reports, spreadsheets, and engineering-handoff documents — this repository does
not host or deploy a running application.

- **Repository:** [`abhishekpal8146/veloop-rewards-analytics`](https://github.com/abhishekpal8146/veloop-rewards-analytics)
- **Analyst:** Abhishek Pal
- **Working schedule:** 25 development days (brief header states 22–24 days; the inconsistency is retained for transparency)

---

## 1. Business context

VELOOP Rewards is a promotional rewards and gamified engagement platform (explicitly *not* a bank,
investment service, gambling platform, betting service, or financial institution). Users earn virtual
credits — VEs, XP, Gems, Tokens, Spins, Badges — through activities such as watching advertisements,
completing tasks, playing the wheel, and referring friends, and can redeem eligible credits through
payout methods such as UPI, Amazon Pay, and Google Play.

The internship brief asks for a full analytics foundation for this platform: auditing the product,
defining what can be measured, specifying events, fields, and KPIs, profiling the supplied simulated
datasets, and handing off implementation-ready specifications to engineering — under strict evidence
and data-integrity rules.

## 2. Objectives and scope

The internship task requires **21 deliverables across a 25-day working schedule**, including:

- a product data audit and an analytics coverage/gap matrix;
- analytics specifications for user, earning & reward, wallet & withdrawal, and referral & engagement areas;
- an event tracking plan, a data dictionary, a logical data model, and a KPI catalogue;
- profiling and quality-auditing of a supplied simulated dataset;
- a dashboard blueprint, a developer handoff, and governance/readiness documents; and
- a final consolidated report.

All work to date is built from **public VELOOP website evidence** and **two supplied simulated
workbooks**; no production VELOOP data is available to the project.

## 3. Current status (verified)

| Work package | Deliverables | Status |
|---|---|---|
| Intake & evidence controls (Days 1–2) | Registers, classifications | ✅ Complete (2026-11-09/10) |
| Product audit (Days 3–4) | D02, D03 | ✅ Complete (2026-11-10/11) |
| User analytics (Days 5–6) | D04 (+ SD1) | ✅ Complete (2026-11-13) |
| Earning & reward analytics (Days 7–8) | D05 (+ SE1, SE2) | ✅ Authored — **awaiting review** (2026-11-16) |
| Wallet & withdrawal analytics (Days 9–10) | D06 (+ SF1) | ✅ Authored — **awaiting review** (2026-11-16) |
| Referral & engagement (Day 11) | D07 | ⬜ Not started |
| Event tracking / dictionary / model / KPIs (Days 12–19) | D08–D11 | ⬜ Not started |
| Simulated data profiling & DQ audit (Days 20–21) | D12, D13 | ⛔ **Blocked: dataset not supplied** |
| Dashboard blueprint (Day 22) | D14 | ⬜ Not started |
| Developer handoff (Day 23) | D15 | ⬜ Not started |
| Governance & readiness (Day 24) | D16–D18 | ⛔ Partially blocked: data |
| Final consolidation (Day 25) | D01, D19–D21 | ⬜ Not started |

**Review status:** all completed deliverables are **drafts awaiting independent review**.
No deliverable has been marked approved by the company, and no company sign-off is recorded in
the project registers.

**Data note:** the two supplied workbooks are self-declared simulated/fictional datasets
("Actual VELOOP production data: NO"). They contain **no** wallet, withdrawal, payout, ledger, or
transaction records. Accordingly, **no withdrawal KPI defined in D06 is currently computable**, and
no performance, success-rate, revenue, or retention figure may be derived from them.

## 4. Completed deliverables & supporting documents

| ID | Title | Path |
|---|---|---|
| D02 | Product Data Audit | [`submission/02_product_data_audit/product_data_audit.md`](submission/02_product_data_audit/product_data_audit.md) |
| D03 | Data Coverage Matrix (12 analytics gaps) | [`submission/03_data_coverage_matrix/data_coverage_matrix.csv`](submission/03_data_coverage_matrix/data_coverage_matrix.csv) · [`analytics_gaps.csv`](submission/03_data_coverage_matrix/analytics_gaps.csv) |
| D04 | User Analytics Specification (+ SD1 Identity Requirements) | [`submission/04_user_analytics_specification/user_analytics_specification.md.txt`](submission/04_user_analytics_specification/user_analytics_specification.md.txt) |
| D05 | Earning & Reward Analytics Specification | [`submission/05_earning_reward_analytics/earning_reward_analytics_specification.md`](submission/05_earning_reward_analytics/earning_reward_analytics_specification.md) |
| SE1 | Failed-Activity Classification (supports D05) | [`submission/05_earning_reward_analytics/se1_failed_activity_classification.md`](submission/05_earning_reward_analytics/se1_failed_activity_classification.md) |
| SE2 | Reward-Event Requirements (supports D05) | [`submission/05_earning_reward_analytics/se2_reward_event_requirements.md`](submission/05_earning_reward_analytics/se2_reward_event_requirements.md) |
| D06 | Wallet & Withdrawal Analytics Specification | [`submission/06_wallet_withdrawal_analytics/wallet_withdrawal_analytics_specification.md`](submission/06_wallet_withdrawal_analytics/wallet_withdrawal_analytics_specification.md) |
| SF1 | Withdrawal Lifecycle (supports D06) | [`submission/06_wallet_withdrawal_analytics/sf1_withdrawal_lifecycle.md`](submission/06_wallet_withdrawal_analytics/sf1_withdrawal_lifecycle.md) |

Supporting project documents:

- Review-day submission summary: [`docs/review_day_submission_summary.md`](docs/review_day_submission_summary.md)
- Stage-1 scaffolding plan: [`docs/plans/2026-11-10-stage-1-scaffolding-plan.md`](docs/plans/2026-11-10-stage-1-scaffolding-plan.md)
- Source HTTP verification evidence: [`outputs/evidence/source_http_verification_2026-11-10.md`](outputs/evidence/source_http_verification_2026-11-10.md) and [`.csv`](outputs/evidence/source_http_verification_2026-11-11.csv)

## 5. Upcoming and pending deliverables

Scheduled (not started): D01 Executive Summary (Days 24–25) · D07 Referral & Engagement Analytics ·
D08 Event Tracking Plan · D09 Data Dictionary · D10 Logical Data Model · D11 KPI Catalogue ·
D14 Dashboard Blueprint · D15 Developer Analytics Handoff · D16 Data Pipeline Proposal ·
D17 Privacy & Governance Proposal · D18 Analytics Readiness Assessment (partially blocked) ·
D19 Assumption & Verification Register (template exists) · D20 Implementation Backlog ·
D21 Final Consolidated Report.

Blocked pending the supplied dataset: **D12 Simulated Data Profiling**, **D13 Data Quality Audit**
(tracker Days 20–21, status "Blocked: data"), with partial impact on D18 and D24 governance outputs.

## 6. Repository structure

```
├── submission/          # the 21 required deliverables + supporting artifacts (D01–D21 folders)
├── docs/                # requirements & deliverable register, plans, review summary, index.html
├── registers/           # source, assumption & progress control registers
├── outputs/evidence/    # HTTP verification evidence for public sources
├── data/interim/        # evidence artifacts (index.js snapshot); backups are local-only
├── src/ · notebooks/    # reserved for future analysis code (not yet created)
├── tests/               # QA validation scripts
└── source datasets/     # ⛔ PRIVATE — gitignored, never published
```

## 7. Control documents

- Requirements & deliverable register: [`docs/requirements_and_deliverable_register.md`](docs/requirements_and_deliverable_register.md)
- Source & verification register: [`registers/source_and_verification_register.csv`](registers/source_and_verification_register.csv)
- Assumption & verification register: [`registers/assumption_and_verification_register.csv`](registers/assumption_and_verification_register.csv)
- Progress tracker: [`registers/progress_tracker.csv`](registers/progress_tracker.csv)

## 8. Evidence labels & data integrity

Every analytical statement in the deliverables uses one of these labels:

| Label | Meaning |
|---|---|
| **Verified** | Supported by an identified official public source (proves the product *describes* it, not that it is live for all users/regions) |
| **Supplied data** | Observed only in the simulated assignment workbooks — never actual VELOOP users or performance |
| **Proposed** | A design in a specification; not confirmed to exist in VELOOP today |
| **To Be Verified** | Open question requiring Product / Payments / Engineering confirmation |
| **Assumption** | Recorded in the Assumption & Verification Register (ASM-xxx) |
| **Illustrative** | Marketing/demo content included only to demonstrate format; excluded from analysis |

Integrity rules enforced across the project: simulated results are never presented as actual VELOOP
statistics; proposed events/fields are never described as existing; no currency conversion, target,
forecast, or success-rate is invented; open questions (OQ-1…OQ-10 in D06, OQ-E1…OQ-E6 in D05) are
tracked with owners until resolved.

## 9. Data privacy & handling

- The original internship datasets (`source datasets/*.xlsx`) are **private** and excluded from Git
  via `.gitignore`; they exist only in the local workspace and are never uploaded.
- Pre-correction snapshots under `data/interim/backups/` are local-only and likewise excluded.
- No credentials, tokens, or personal user data are stored in this repository.
- Published analysis uses only aggregated summaries of the simulated workbooks, always labelled as
  simulated.

## 10. Quality assurance & validation

Run from the repository root:

```powershell
# Markdown link validation (all relative links/anchors in D05/SE1/SE2/D06/SF1)
python tests/check_links.py

# Full D05/D06 QA suite (deliverable structure, KPI attributes, lifecycle tables)
powershell -NoProfile -ExecutionPolicy Bypass -File tests/verify_d05_d06.ps1
```

Latest verified results are recorded in this repository's QA history. **Known manual-review item:**
logical legality of SF1 lifecycle transitions at runtime (e.g. blocking illegal transitions such as
`withdrawal_rejected → withdrawal_completed`) cannot be validated from Markdown and is deferred to
Stage-3 engineering review.

## 11. Limitations & assumptions

- Public policy text may be stale or change without notice; thresholds and methods are cited as
  "documented current model values" only (ASM-002, ASM-007).
- Payout-method information is contradictory across public sources; the dimension is frozen
  **To Be Verified** until Product confirms (ASM-003 / GAP-009).
- No internal engineering documentation is available; every proposed event/field/state is labelled
  as such (ASM-008).
- The simulated workbooks include one anomalous `xp_balance` value (`-0.1`), logged for D13 rather
  than silently corrected.
- Deliverable dates reflect the tracker; no approval dates are recorded because none exist.

## 12. Navigation for reviewers

1. Start with the [review-day summary](docs/review_day_submission_summary.md) for cycle context.
2. Read [D02](submission/02_product_data_audit/product_data_audit.md) → [D03](submission/03_data_coverage_matrix/data_coverage_matrix.csv) for the product and gap baseline.
3. Review the analytics specifications: [D04](submission/04_user_analytics_specification/user_analytics_specification.md.txt) → [D05](submission/05_earning_reward_analytics/earning_reward_analytics_specification.md) → [D06](submission/06_wallet_withdrawal_analytics/wallet_withdrawal_analytics_specification.md), with supporting artifacts [SE1](submission/05_earning_reward_analytics/se1_failed_activity_classification.md), [SE2](submission/05_earning_reward_analytics/se2_reward_event_requirements.md), [SF1](submission/06_wallet_withdrawal_analytics/sf1_withdrawal_lifecycle.md).
4. Check live status in the [progress tracker](registers/progress_tracker.csv) and open questions in each deliverable's §12 (OQ tables).
