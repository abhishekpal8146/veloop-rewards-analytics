# VELOOP Rewards — Data Analytics Internship Project

Data Analyst Internship, Task 01: a product analytics, data readiness, and data management blueprint for the VELOOP Rewards platform. This repository holds the project's documentation, analytics specifications, control registers, verified source evidence, and verification scripts.

> **What this is:** a documentation and specification project. The deliverables are reports, spreadsheets, and engineering handoff documents. This repository does **not** host or deploy a running application.

## Project context

The internship task requires 21 deliverables across a 25-day working schedule covering: a product data audit, analytics specifications (user, earning & reward, wallet & withdrawal, referral & engagement), an event tracking plan, a data dictionary, a logical data model, a KPI catalogue, profiling of a supplied simulated dataset, a data quality audit, a dashboard blueprint, a developer handoff, governance documents, and a final report.

### Current progress

| Work package | Status |
|---|---|
| Stage 1 — project scaffolding and control registers | Complete |
| Deliverable 02 — Product Data Audit | Complete |
| Deliverable 03 — Data Coverage Matrix + 12 analytics gaps | Complete |
| **Deliverable 04 — User Analytics Specification** | **Next (in progress)** |
| Deliverables 05–11, 14–21 | Not started (scheduled per the register) |
| Deliverables 12–13 — dataset profiling and quality audit | Blocked: the supplied simulated dataset has not been delivered |

Progress for all 25 scheduled days is tracked in `registers/progress_tracker.csv`.

## Repository structure

```
├── README.md
├── docs/
│   ├── requirements_and_deliverable_register.md   # all 21 deliverables, dependencies, status
│   └── plans/                                     # stage implementation plans
├── registers/
│   ├── source_and_verification_register.csv       # SRC-001…SRC-011, every cited source
│   ├── assumption_and_verification_register.csv   # ASM-001…ASM-008, open questions
│   └── progress_tracker.csv                       # 25-day working schedule
├── submission/
│   ├── 01_executive_summary/ … 21_final_report/   # one folder per deliverable
│   ├── 02_product_data_audit/product_data_audit.md
│   └── 03_data_coverage_matrix/
│       ├── data_coverage_matrix.csv               # 36-row product coverage matrix
│       └── analytics_gaps.csv                     # 12 prioritized analytics gaps
├── data/
│   ├── raw/                                       # supplied dataset (pending delivery)
│   └── interim/evidence/velooprewards_in_index.js # raw public-website bundle, preserved as-is
├── outputs/evidence/                              # HTTP source verification logs
├── tests/                                         # verification scripts (PowerShell 5.1)
└── docs/ → see also: docs/index.html (static documentation landing page)
```

## Key documents

- `docs/requirements_and_deliverable_register.md` — the master register of all 21 deliverables, required formats, dependencies, and status.
- `submission/02_product_data_audit/product_data_audit.md` — Deliverable 02: product area mapping, user action inventory, system outcome taxonomy, source contradictions, and analytics gaps summary.
- `submission/03_data_coverage_matrix/data_coverage_matrix.csv` — Deliverable 03: 36 rows across 14 columns (product area, feature, user/system actions, data required, proposed events, source, business question, status, priority).
- `submission/03_data_coverage_matrix/analytics_gaps.csv` — 12 prioritized analytics gaps (4 Critical, 5 High, 3 Medium).
- `registers/source_and_verification_register.csv` — every source used, its classification, verification date, limitations, and evidence label.

## Evidence and integrity policy

- Every product claim in the deliverables traces to a registered source (`SRC-xxx`). Public website content is classified as **Public Website Source** — it documents the product publicly and is not independently verified internal engineering documentation.
- Every feature is labelled **Confirmed (Public Documentation)**, **Proposed**, or **To Be Verified**. "Confirmed" never means "verified in production."
- No business metrics are fabricated, and no simulated data is presented as actual VELOOP user, earnings, withdrawal, revenue, retention, or conversion statistics.
- Marketing-page figures are treated as illustrative and excluded from all analysis.
- A public student portfolio repository (`Ilma-gulzar21/VELOop-Rewards`) was examined during research and is registered as **EXCLUDED** (SRC-011); no fact from it appears in any deliverable.

## Verification

Verification scripts (Windows PowerShell 5.1):

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\tests\verify_stage1.ps1"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\tests\verify_stage2.ps1"
```

Both scripts currently pass (7/7 checks each): directory and register structure, the 21-deliverable register, the source/assumption registers, progress tracker days 1–4, and the existence and structure of Deliverables 02 and 03.

## Notes

- Pre-correction file snapshots (`data/interim/backups/`) are retained in the local working workspace and are intentionally **not** part of this repository.
- The 2026-11-10 source verification log was originally saved as a Markdown table; it is kept in that format (`outputs/evidence/source_http_verification_2026-11-10.md`) to preserve the evidence exactly as produced.
- The raw JavaScript evidence bundle is preserved byte-for-byte as collected. It is a public website asset, not readable documentation; its human-readable extract is the source register (SRC-002).
