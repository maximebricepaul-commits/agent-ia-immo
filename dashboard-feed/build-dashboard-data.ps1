<#
  ALEX - Pipeline dashboard ROI : Retell (vrais appels) -> dashboard-data.json -> push GitHub Pages
  ---------------------------------------------------------------------------------------------
  - Lit la clé API Retell dans retell.config.json (JAMAIS committé, voir .gitignore).
  - Appelle l'API Retell (list-calls), agrège sur 7/30/90 jours, anonymise (aucune donnee perso
    dans le JSON public : ni numero, ni nom, ni transcript - uniquement des agregats + libelles generiques).
  - Ecrit dashboard-data.json a la racine du repo, puis git add/commit/push.
  - En cas d'echec API : n'ecrase RIEN (le dashboard garde soit le dernier flux, soit la demo).

  Lancement manuel :  powershell -ExecutionPolicy Bypass -File build-dashboard-data.ps1
  (Sinon exécuté par la tâche planifiée "dashboard-retell-sync".)
#>

$ErrorActionPreference = "Stop"
$root       = Split-Path -Parent $PSScriptRoot           # ...\agent-ia-immo
$configPath = Join-Path $PSScriptRoot "retell.config.json"
$outPath    = Join-Path $root "dashboard-data.json"

function Log($m){ Write-Host ("[{0}] {1}" -f (Get-Date -Format "HH:mm:ss"), $m) }

# --- 1. Config -------------------------------------------------------------
if (-not (Test-Path $configPath)) {
  Log "Config absente ($configPath). Copie retell.config.example.json -> retell.config.json et ajoute ta cle. Abandon (le dashboard garde la demo)."
  exit 0
}
$cfg = Get-Content $configPath -Raw | ConvertFrom-Json
if (-not $cfg.apiKey -or $cfg.apiKey -like "*COLLE_TA_CLE*") {
  Log "Cle Retell non renseignee dans retell.config.json. Abandon (le dashboard garde la demo)."
  exit 0
}

$panier   = if ($cfg.panierMoyenEuros)   { [double]$cfg.panierMoyenEuros }   else { 200 }   # € par RDV/reservation
$aboMois  = if ($cfg.abonnementMensuel)  { [double]$cfg.abonnementMensuel }  else { 490 }   # € / mois
$openH    = if ($cfg.heureOuverture -ne $null) { [int]$cfg.heureOuverture } else { 9 }
$closeH   = if ($cfg.heureFermeture -ne $null) { [int]$cfg.heureFermeture } else { 20 }
$clientLabel = if ($cfg.clientLabel) { [string]$cfg.clientLabel } else { "ALEX - vos appels en direct" }
$langField= if ($cfg.champLangue)  { [string]$cfg.champLangue }  else { "language" }
$rdvField = if ($cfg.champRdv)     { [string]$cfg.champRdv }     else { "appointment_booked" }

# --- 2. Recuperation des appels (API Retell) -------------------------------
$headers = @{ "Authorization" = "Bearer $($cfg.apiKey)"; "Content-Type" = "application/json" }
$body    = @{ sort_order = "descending"; limit = 1000 } | ConvertTo-Json
try {
  $resp = Invoke-RestMethod -Method Post -Uri "https://api.retellai.com/v2/list-calls" -Headers $headers -Body $body -TimeoutSec 40
} catch {
  Log "Echec API Retell : $($_.Exception.Message). Abandon (aucun ecrasement)."
  exit 0
}
# Retell renvoie soit un tableau, soit un objet { calls: [...] }
$calls = if ($resp -is [System.Array]) { $resp } elseif ($resp.calls) { $resp.calls } else { @($resp) }
if (-not $calls -or $calls.Count -eq 0) {
  Log "0 appel renvoye par Retell. Abandon (le dashboard garde la demo)."
  exit 0
}
Log "$($calls.Count) appels recuperes."

# --- 3. Helpers ------------------------------------------------------------
function Get-Lang($c){
  $v = $null
  try { $v = $c.call_analysis.custom_analysis_data.$langField } catch {}
  if ([string]::IsNullOrWhiteSpace($v)) { return "FR" }
  $v = ($v.ToString()).ToUpper()
  if ($v -like "ES*" -or $v -like "*SPANISH*" -or $v -like "*ESPA*") { return "ES" }
  if ($v -like "CA*" -or $v -like "*CATAL*") { return "CA" }
  if ($v -like "EN*" -or $v -like "*ENGLISH*" -or $v -like "*ANGL*") { return "EN" }
  return "FR"
}
function Is-Rdv($c){
  # 1) champ d'analyse booleen si configure dans Retell
  try {
    $b = $c.call_analysis.custom_analysis_data.$rdvField
    if ($b -is [bool]) { return $b }
    if ($b -ne $null -and ("$b" -match "^(true|1|oui|si|yes)$")) { return $true }
  } catch {}
  # 2) heuristique sur le resume (pas de transcript dans le JSON de sortie)
  $s = ""
  try { $s = "$($c.call_analysis.call_summary)".ToLower() } catch {}
  return ($s -match "rendez-vous|rendez vous|rdv|réserv|reserv|booked|cita|reserva")
}
function Hour-Local($ms){
  $dt = [DateTimeOffset]::FromUnixTimeMilliseconds([int64]$ms).LocalDateTime
  return $dt
}

$now = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
$dayMs = ([int64]86400000)

function Build-Window([int]$days){
  $since = $now - ($days * $dayMs)
  $sel = @($calls | Where-Object { $_.start_timestamp -and [int64]$_.start_timestamp -ge $since })
  $recus = $sel.Count
  $rdv = 0; $manques = 0; $durSec = 0.0
  $lc = @{ FR=0; ES=0; CA=0; EN=0 }
  foreach ($c in $sel){
    if (Is-Rdv $c) { $rdv++ }
    $lc[(Get-Lang $c)]++
    if ($c.end_timestamp -and $c.start_timestamp) { $durSec += ([double]$c.end_timestamp - [double]$c.start_timestamp)/1000.0 }
    $dt = Hour-Local $c.start_timestamp
    if ($dt.Hour -lt $openH -or $dt.Hour -ge $closeH -or $dt.DayOfWeek -eq "Sunday") { $manques++ }
  }
  $ca = [int][math]::Round($rdv * $panier)
  $cost = [int][math]::Round($aboMois * $days / 30.0)
  $mult = if ($cost -gt 0) { [int][math]::Round($ca / [double]$cost) } else { 0 }
  $heures = [int][math]::Round($durSec / 3600.0)
  # pourcentages langues
  $langPct = @{}
  foreach ($k in "FR","ES","CA","EN"){ $langPct[$k] = if ($recus -gt 0) { [int][math]::Round($lc[$k]*100.0/$recus) } else { 0 } }
  # graphe : on segmente la periode en tranches
  $labels=@(); $appArr=@(); $rdvArr=@()
  $buckets = if ($days -le 7) { 7 } elseif ($days -le 30) { 4 } else { 3 }
  $span = [double]($days * $dayMs) / $buckets
  for ($i=0; $i -lt $buckets; $i++){
    $bStart = $since + ($i*$span); $bEnd = $since + (($i+1)*$span)
    $inb = @($sel | Where-Object { [int64]$_.start_timestamp -ge $bStart -and [int64]$_.start_timestamp -lt $bEnd })
    $appArr += $inb.Count
    $rdvArr += @($inb | Where-Object { Is-Rdv $_ }).Count
    if ($days -le 7)      { $labels += ([DateTimeOffset]::FromUnixTimeMilliseconds([int64]$bStart).LocalDateTime.ToString("dd/MM")) }
    elseif ($days -le 30) { $labels += ("Sem. " + ($i+1)) }
    else                  { $labels += ("Mois " + ($i+1)) }
  }
  return [ordered]@{
    recus=$recus; manques=$manques; rdv=$rdv; heures=$heures; ca=$ca; zero=0
    cost = ("{0:N0} €" -f $cost).Replace(",", " ")
    ca_s = ("{0:N0} €" -f $ca).Replace(",", " ")
    mult = ("×{0}" -f $mult)
    chart = [ordered]@{ labels=$labels; app=$appArr; rdv=$rdvArr }
    langues = [ordered]@{ FR=$langPct["FR"]; ES=$langPct["ES"]; CA=$langPct["CA"]; EN=$langPct["EN"] }
  }
}

# --- 4. Derniers appels (anonymises : heure + langue + libelle generique) --
$recent = @()
foreach ($c in ($calls | Select-Object -First 7)){
  $dt = Hour-Local $c.start_timestamp
  $isR = Is-Rdv $c
  $off = ($dt.Hour -lt $openH -or $dt.Hour -ge $closeH -or $dt.DayOfWeek -eq "Sunday")
  $recent += [ordered]@{
    time = $dt.ToString("HH:mm")
    lang = (Get-Lang $c)
    demande = if ($isR) { "Prise de rendez-vous" } else { "Demande d'information" }
    result  = if ($isR) { "Rendez-vous pris" } else { "Info donnée" }
    resultClass = if ($isR) { "rdv" } else { "info" }
    off = [bool]$off
  }
}

# --- 5. Ecriture + push ----------------------------------------------------
$feed = [ordered]@{
  client      = $clientLabel
  generatedAt = (Get-Date).ToString("s")
  source      = "retell"
  windows     = [ordered]@{ "7" = (Build-Window 7); "30" = (Build-Window 30); "90" = (Build-Window 90) }
  recent      = $recent
}
$json = $feed | ConvertTo-Json -Depth 8
[System.IO.File]::WriteAllText($outPath, $json, (New-Object System.Text.UTF8Encoding($false)))
Log "dashboard-data.json ecrit ($($feed.windows.'30'.recus) appels sur 30j)."

Push-Location $root
# git ecrit ses infos de progression sur stderr : sous ErrorActionPreference=Stop
# cela leverait une fausse erreur. On passe en Continue et on juge sur $LASTEXITCODE.
$ErrorActionPreference = "Continue"
try {
  & git add dashboard-data.json | Out-Null
  $status = & git status --porcelain dashboard-data.json
  if ([string]::IsNullOrWhiteSpace($status)) { Log "Aucun changement a pousser." }
  else {
    & git commit -q -m ("dashboard: sync donnees reelles Retell (" + (Get-Date -Format 'dd/MM HH:mm') + ")") | Out-Null
    & git push origin main 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) { Log "Push effectue." } else { Log "git push a renvoye le code $LASTEXITCODE." }
  }
} finally { Pop-Location }
exit 0
