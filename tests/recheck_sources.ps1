$ErrorActionPreference = 'Continue'
$urls = @(
  'https://www.velooprewards.in/',
  'https://veloop-rewards-landing-page-kappa.vercel.app/',
  'https://github.com/Ilma-gulzar21/VELOop-Rewards',
  'https://velooprewards.in/payout',
  'https://velooprewards.in/withdrawal-verification-policy'
)
$rows = foreach ($u in $urls) {
  try {
    $r = Invoke-WebRequest -Uri $u -UseBasicParsing -MaximumRedirection 5 -TimeoutSec 25
    [pscustomobject]@{ url = $u; status = [string]$r.StatusCode; content_length = [string]$r.RawContentLength; checked_on = '2026-11-11' }
  }
  catch {
    [pscustomobject]@{ url = $u; status = "ERROR"; detail = $PSItem.Exception.Message; content_length = '0'; checked_on = '2026-11-11' }
  }
}
$rows | Format-Table -AutoSize | Out-String -Width 200
$rows | Export-Csv -NoTypeInformation -LiteralPath (Join-Path (Get-Location).Path 'outputs\evidence\source_http_verification_2026-11-11.csv')
Write-Output 'verification log written'
