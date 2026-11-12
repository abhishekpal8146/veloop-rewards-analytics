$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$failures = @()

# --- Deliverable 02: Product Data Audit ---
$d02Path = Join-Path $root 'submission\02_product_data_audit\product_data_audit.md'
if (-not (Test-Path -LiteralPath $d02Path)) {
  $failures += 'D02 missing: submission\02_product_data_audit\product_data_audit.md'
} else {
  $d02 = Get-Content -LiteralPath $d02Path -Raw
  $d02Sections = @(
    'Product area mapping',
    'User action inventory',
    'System outcomes',
    'Public-source contradictions',
    'Analytics gaps',
    'Limitations',
    'Traceability'
  )
  foreach ($s in $d02Sections) {
    if ($d02 -notmatch [regex]::Escape($s)) { $failures += "D02 missing section: $s" }
  }
  foreach ($label in 'Confirmed (Public Documentation)', 'Proposed', 'To Be Verified') {
    if ($d02 -notmatch [regex]::Escape($label)) { $failures += "D02 missing status label: $label" }
  }
  $gapRefs = ([regex]::Matches($d02, 'GAP-0\d{2}')).Count
  if ($gapRefs -lt 10) { $failures += "D02 references only $gapRefs gaps; need at least 10" }
  if ($d02.Length -lt 10000) { $failures += 'D02 is shorter than 10,000 chars; not a detailed report' }
  if ($d02 -match '(?i)actual VELOOP (users|revenue|withdrawals are)') { $failures += 'D02 appears to contain actual-metric claims' }
}

# --- Deliverable 03: Data Coverage Matrix ---
$dcmPath = Join-Path $root 'submission\03_data_coverage_matrix\data_coverage_matrix.csv'
if (-not (Test-Path -LiteralPath $dcmPath)) {
  $failures += 'D03 missing: submission\03_data_coverage_matrix\data_coverage_matrix.csv'
} else {
  $dcm = @(Import-Csv -LiteralPath $dcmPath)
  if ($dcm.Count -lt 25) { $failures += "D03 matrix has $($dcm.Count) rows; need at least 25" }
  $hdr = ($dcm[0].PSObject.Properties.Name)
  foreach ($col in 'product_area','feature_module','feature_status','user_action','system_action','business_outcome','data_required','proposed_event','source','business_question','status','priority') {
    if ($hdr -notcontains $col) { $failures += "D03 matrix missing column: $col" }
  }
  if ($hdr.Count -lt 11) { $failures += "D03 matrix has $($hdr.Count) columns; need at least 11" }
  $allowedStatus = 'Confirmed (Public Documentation)', 'Proposed', 'To Be Verified'
  $badStatus = $dcm | Where-Object { $allowedStatus -notcontains $_.feature_status }
  if ($badStatus.Count) { $failures += "D03 rows with invalid feature_status: $($badStatus.row_id -join ', ')" }
  $emptyCells = @($dcm | Where-Object { [string]::IsNullOrWhiteSpace($_.product_area) -or [string]::IsNullOrWhiteSpace($_.source) -or [string]::IsNullOrWhiteSpace($_.business_question) })
  if ($emptyCells.Count) { $failures += "D03 rows with empty required cells: $($emptyCells.row_id -join ', ')" }
}

# --- Deliverable 03: Analytics Gaps (SC1: at least 10) ---
$gapPath = Join-Path $root 'submission\03_data_coverage_matrix\analytics_gaps.csv'
if (-not (Test-Path -LiteralPath $gapPath)) {
  $failures += 'D03 missing: submission\03_data_coverage_matrix\analytics_gaps.csv'
} else {
  $gaps = @(Import-Csv -LiteralPath $gapPath)
  if ($gaps.Count -lt 10) { $failures += "Gap register has $($gaps.Count) gaps; requirement is at least 10" }
  foreach ($col in 'gap_id','gap','impact_on_future_reporting','priority','reason_for_priority','evidence') {
    if ($gaps[0].PSObject.Properties.Name -notcontains $col) { $failures += "Gap register missing column: $col" }
  }
  $badPriority = $gaps | Where-Object { $_.priority -notin 'Critical','High','Medium','Low' }
  if ($badPriority.Count) { $failures += "Gap rows with invalid priority: $($badPriority.gap_id -join ', ')" }
  $emptyReason = $gaps | Where-Object { [string]::IsNullOrWhiteSpace($_.reason_for_priority) }
  if ($emptyReason.Count) { $failures += "Gap rows missing reason: $($emptyReason.gap_id -join ', ')" }
}

# --- Source register: real rows, correct classification, explicit exclusion ---
$src = @(Import-Csv -LiteralPath (Join-Path $root 'registers\source_and_verification_register.csv'))
if ($src.Count -lt 5) { $failures += "Source register has $($src.Count) rows; need at least 5" }
if (@($src | Where-Object { $_.source_type -eq 'Public Website Source' }).Count -lt 3) {
  $failures += 'Source register: official site rows must be classified Public Website Source (at least 3)'
}
$gh = @($src | Where-Object { $_.source -match 'github\.com/Ilma-gulzar21' })
if ($gh.Count -ne 1) { $failures += 'Source register: GitHub student repository must be registered exactly once' }
elseif ($gh[0].status -ne 'Excluded' -and $gh[0].information -notmatch '(?i)excluded') { $failures += 'Source register: GitHub repository row must be marked Excluded' }

# --- Assumption register: real rows, unresolved questions visible ---
$asm = @(Import-Csv -LiteralPath (Join-Path $root 'registers\assumption_and_verification_register.csv'))
if ($asm.Count -lt 5) { $failures += "Assumption register has $($asm.Count) rows; need at least 5" }
if (@($asm | Where-Object { $_.status -eq 'To Be Verified' }).Count -lt 3) {
  $failures += 'Assumption register: need at least 3 unresolved To Be Verified items'
}

# --- Progress tracker: days 1-4 complete ---
$prog = @(Import-Csv -LiteralPath (Join-Path $root 'registers\progress_tracker.csv'))
foreach ($d in 1..4) {
  $row = $prog | Where-Object { $_.day -eq [string]$d }
  if (-not $row) { $failures += "Progress tracker missing day $d"; continue }
  if ($row.status -ne 'Complete') { $failures += "Progress day $d status is $($row.status); expected Complete" }
  if ([string]::IsNullOrWhiteSpace($row.completed_on)) { $failures += "Progress day $d has no completed_on date" }
}

# --- Deliverable register: 02 and 03 marked complete ---
$reg = Get-Content -LiteralPath (Join-Path $root 'docs\requirements_and_deliverable_register.md') -Raw
foreach ($id in '02','03') {
  if ($reg -notmatch "(?m)^\| $id \|.*Complete \(2026-11-1[01]\)") { $failures += "Deliverable $id not marked Complete in requirements register" }
}

if ($failures.Count) {
  $failures | ForEach-Object { Write-Output "FAIL: $_" }
  exit 1
}

Write-Output "PASS: D02 product_data_audit.md exists with all required sections, 3 status labels, >=10 gap references"
Write-Output "PASS: D03 data_coverage_matrix.csv rows=$($dcm.Count) columns=$($hdr.Count)"
Write-Output "PASS: D03 analytics_gaps.csv gaps=$($gaps.Count) (>=10) with priority and reason"
Write-Output "PASS: Source register rows=$($src.Count); official site classified Public Website Source; GitHub repo explicitly excluded"
Write-Output "PASS: Assumption register rows=$($asm.Count); unresolved items tracked"
Write-Output 'PASS: Progress tracker days 1-4 Complete with dates'
Write-Output 'PASS: Requirements register marks deliverables 02 and 03 Complete'
exit 0
