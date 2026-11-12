# Requirements and Deliverable Register

## Document control

- Project: VELOOP Rewards — Data Analyst Internship, Task 01
- Register version: Stage 1 draft
- Created: 2026-11-10
- Status: Approved structure; content development not started
- Source: Assignment brief supplied by the user on 2026-11-10

## Evidence policy

| Label | Meaning |
|---|---|
| Verified | Supported by an identified official, internal, or supplied source |
| Supplied data | Derived only from the fictional/simulated assignment dataset |
| Proposed | Recommended but not confirmed as existing in VELOOP |
| Assumption | Unknown recorded in the Assumption & Verification Register |
| Illustrative | Format example only; not a VELOOP result |

Simulated data must never be described as actual VELOOP users, earnings, withdrawals, revenue, retention, conversion rates, performance, or company statistics.

## Schedule note

The brief header states 22–24 days, while its explicit working schedule runs through Day 25. The approved plan retains 25 days as the working schedule and records this inconsistency without silently resolving it.

## Required final deliverables

| ID | Deliverable | Required format | Primary dependency | Scheduled window | Status |
|---|---|---|---|---|---|
| 01 | Executive Summary | 2–4 page document | Evidence, findings, risks, and priorities from 02–20 | Days 24–25 | Not started |
| 02 | Product Data Audit | Detailed report | Product review and Work Package A | Days 3–4 | Complete (2026-11-10) |
| 03 | Data Coverage Matrix | Spreadsheet | 02 plus at least 10 analytics gaps | Days 3–4 | Complete (2026-11-10) — 12 gaps in `analytics_gaps.csv` |
| 04 | User Analytics Specification | Document/spreadsheet | Product review and Work Package B | Days 5–6 | Not started |
| 05 | Earning & Reward Analytics Specification | Document | Product review and Work Package C | Days 7–8 | Not started |
| 06 | Wallet & Withdrawal Analytics Specification | Document | Product review and Work Package D | Days 9–10 | Not started |
| 07 | Referral & Engagement Analytics | Document | Product review and Work Package E | Day 11 | Not started |
| 08 | Event Tracking Plan | Spreadsheet | 04–07, naming standard, 25+ meaningful events | Days 12–14 | Not started |
| 09 | Data Dictionary | Spreadsheet | 08, 75+ meaningful fields | Days 15–16 | Not started |
| 10 | Logical Data Model | ER diagram and explanation | 09 and relationships | Days 17–18 | Not started |
| 11 | KPI Catalogue | Spreadsheet | 08–10; 30+ reproducible KPI definitions | Day 19 | Not started |
| 12 | Simulated Data Profiling | Workbook and findings | Supplied fictional dataset | Day 20 | Blocked: data |
| 13 | Data Quality Audit | Workbook and report | Supplied Messy Data sheet and 12 | Day 21 | Blocked: data |
| 14 | Dashboard Blueprint | Wireframes and specifications | 11–13 | Day 22 | Not started |
| 15 | Developer Analytics Handoff | Engineering specification | 08 and event payload requirements | Day 23 | Not started |
| 16 | Data Pipeline Proposal | Architecture diagram and documentation | 10, 13, controls, governance | Day 24 | Not started |
| 17 | Privacy & Governance Proposal | Document | Source register and access requirements | Day 24 | Not started |
| 18 | Analytics Readiness Assessment | Scorecard and evidence | 12, 13, gap assessment, KPI feasibility | Day 24 | Partially blocked: data |
| 19 | Assumption & Verification Register | Spreadsheet | Ongoing assumption capture | Days 1–25 | Template created |
| 20 | Implementation Backlog | Prioritized backlog | 17–19 and evidence-based gaps | Day 25 | Not started |
| 21 | Final Consolidated Report | Professional document | 01–20 with cross-references | Day 25 | Not started |

## Supporting artifacts

| ID | Supporting artifact | Enables |
|---|---|---|
| SA | Source & Verification Register | 02, 17, 18, 19, 21 |
| SB1 | Product Area Mapping | 02 |
| SB2 | User Action Inventory | 02, 08 |
| SB3 | System Outcome Inventory | 02, 08 |
| SC1 | Analytics Gap List | 03, 18, 20 |
| SD1 | Identity Requirements | 04, 09, 10 |
| SE1 | Failed-Activity Classification | 05, 08 |
| SE2 | Reward-Event Requirements | 05, 08 |
| SF1 | Withdrawal Lifecycle | 06, 08 |
| SG1 | Referral Lifecycle | 07, 08 |
| SH1 | Event Naming Standard | 08 |
| SI1 | Primary-Key Register | 10 |
| SJ1 | Foreign-Key Register | 10 |
| SK1 | Relationship Documentation | 10 |
| SL1 | Dataset Profile Results | 12 |
| SL2 | Relationship Test Results | 12 |
| SL3 | KPI Feasibility Tests | 11, 12, 18, 20 |
| SM1 | Data Quality Findings | 13 |
| SN1 | Data Quality Rule Placement | 13, 18 |
| SO1 | Dashboard 1: Executive Overview | 14 |
| SO2 | Dashboard 2: User Analytics | 14 |
| SO3 | Dashboard 3: Engagement | 14 |
| SO4 | Dashboard 4: Rewards | 14 |
| SO5 | Dashboard 5: Wallet | 14 |
| SO6 | Dashboard 6: Withdrawals | 14 |
| SO7 | Dashboard 7: Referrals | 14 |
| SP1 | Critical-Event Payload Specifications | 15 |
| SQ1 | Pipeline Component Register | 16 |
| SR1 | Access Matrix | 17 |
| SS1 | Metric/Event Change Log | 17, 21 |
| ST1 | Evidence-Based Scorecard | 18 |
| SU1 | Backlog Dependencies | 20 |

## Dataset-dependent versus startable work

### Dataset-dependent

- Simulated dataset profiling and relationship tests for 12.
- Messy Data detection and issue counts for 13.
- KPI feasibility testing for parts of 11, 12, 18, and 20.
- Evidence-based scoring in 18.
- Data-specific findings in 21.

### Startable before dataset delivery

- Source and product-evidence review.
- Work Packages A–I and deliverables 02–11.
- Event naming and engineering specifications.
- Pipeline, governance, dashboards, assumption capture, and change controls for 14–19.
- Structure and prioritization framework for 20.

### Proposed-specification work

Product features, events, fields, entities, KPIs, controls, dashboards, pipelines, and priorities are marked Proposed until verified. No proposal is presented as an existing VELOOP implementation.

## Integrity constraints

1. Do not fabricate production data or company statistics.
2. Do not represent simulated findings as actual VELOOP performance.
3. Do not invent confidential security mechanisms or credentials.
4. Do not claim proposed events or fields already exist.
5. Do not hide uncertainty or convert assumptions into facts.
6. Do not add unnecessary personal-data fields.
7. Keep generated simulated data explicitly labelled and method-documented.
8. Keep supplied raw data unchanged.

## Stage 1 status

- Approved folder structure: complete.
- Requirements and deliverable register: complete.
- Source & Verification Register template: complete.
- Assumption & Verification Register template: complete.
- Progress tracker: complete.
- Product analysis and deliverables 02–21: not started.
