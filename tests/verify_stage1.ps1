$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$requiredDirs = @(
  'submission\01_executive_summary',
  'submission\02_product_data_audit',
  'submission\03_data_coverage_matrix',
  'submission\04_user_analytics_specification',
  'submission\05_earning_reward_analytics',
  'submission\06_wallet_withdrawal_analytics',
  'submission\07_referral_engagement_analytics',
  'submission\08_event_tracking_plan',
  'submission\09_data_dictionary',
  'submission\10_logical_data_model',
  'submission\11_kpi_catalogue',
  'submission\12_simulated_data_profiling',
  'submission\13_data_quality_audit',
  'submission\14_dashboard_blueprint',
  'submission\15_developer_handoff',
  'submission\16_data_pipeline_proposal',
  'submission\17_privacy_governance',
  'submission\18_analytics_readiness',
  'submission\19_assumption_register',
  'submission\20_implementation_backlog',
  'submission\21_final_report',
  'data\raw',
  'data\interim',
  'data\generated_simulated',
  'src',
  'notebooks',
  'outputs\profiles',
  'outputs\relationship_tests',
  'outputs\kpi_tests',
  'outputs\quality_findings',
  'outputs\diagrams',
  'outputs\evidence',
  'registers',
  'tests',
  'docs\plans'
)
$requiredFiles = @(
  'README.md',
  'docs\requirements_and_deliverable_register.md',
  'registers\source_and_verification_register.csv',
  'registers\assumption_and_verification_register.csv',
  'registers\progress_tracker.csv'
)

$missingDirs = $requiredDirs | Where-Object { -not (Test-Path -LiteralPath (Join-Path $root $_)) }
$missingFiles = $requiredFiles | Where-Object { -not (Test-Path -LiteralPath (Join-Path $root $_)) }

$requirements = Get-Content -LiteralPath (Join-Path $root 'docs\requirements_and_deliverable_register.md') -Raw
$deliverableCount = ([regex]::Matches($requirements, '(?m)^\| 0[1-9] \|') + [regex]::Matches($requirements, '(?m)^\| [12][0-9] \|')).Count
$sourceRows = @(Import-Csv -LiteralPath (Join-Path $root 'registers\source_and_verification_register.csv'))
$assumptionRows = @(Import-Csv -LiteralPath (Join-Path $root 'registers\assumption_and_verification_register.csv'))
$progressRows = @(Import-Csv -LiteralPath (Join-Path $root 'registers\progress_tracker.csv'))
$forbiddenFiles = @(Get-ChildItem -LiteralPath $root -Recurse -File |
  Where-Object { $_.Name -match '(?i)(business_result|actual_metric|company_statistic)' })

$failures = @()
if ($missingDirs.Count) { $failures += "Missing directories: $($missingDirs -join ', ')" }
if ($missingFiles.Count) { $failures += "Missing files: $($missingFiles -join ', ')" }
if ($deliverableCount -ne 21) { $failures += "Expected 21 deliverable rows; found $deliverableCount" }
if ($sourceRows.Count -lt 1) { $failures += "Source register must contain at least one row; found $($sourceRows.Count)" }
if ($assumptionRows.Count -lt 1) { $failures += "Assumption register must contain at least one row; found $($assumptionRows.Count)" }
if ($progressRows.Count -ne 25) { $failures += "Progress tracker must contain 25 days; found $($progressRows.Count)" }
if ($progressRows[0].day -ne '1' -or $progressRows[24].day -ne '25') { $failures += 'Progress tracker day sequence is invalid' }
if ($forbiddenFiles.Count) { $failures += "Unexpected result files: $($forbiddenFiles.Name -join ', ')" }

if ($failures.Count) {
  $failures | ForEach-Object { Write-Output "FAIL: $_" }
  exit 1
}

Write-Output "PASS: $($requiredDirs.Count) required directories exist"
Write-Output "PASS: $($requiredFiles.Count) required files exist"
Write-Output "PASS: $deliverableCount final deliverables registered"
Write-Output "PASS: Source register rows=$($sourceRows.Count) (>=1)"
Write-Output "PASS: Assumption register rows=$($assumptionRows.Count) (>=1)"
Write-Output "PASS: Progress days=$($progressRows.Count)"
Write-Output 'PASS: No synthetic business-result file detected'
exit 0
