<#
---------------------------------------------------------------------------------
 Client Branch Bootstrap Script (Windows PowerShell)
 Purpose : Minimal sequential steps for non-technical operator setup
 Prereqs : PowerShell 5+ / 7+, Git, Node.js installed, network access to repo
---------------------------------------------------------------------------------
 USAGE (example):
  PS> $env:CLIENT_ID = 'alpha-corp'
  PS> $env:GIT_REPO_URL = 'https://github.com/company/db-deployments.git'
  PS> $env:GIT_BRANCH = "client-$($env:CLIENT_ID)/production"
  PS> .\scripts\client-bootstrap.ps1
---------------------------------------------------------------------------------
#>
[CmdletBinding()]
param(
    [string]$ClientId = $env:CLIENT_ID,
    [string]$GitRepo  = $env:GIT_REPO_URL,
    [string]$GitBranch = $env:GIT_BRANCH,
    [string]$RootDir = 'C:\Deployment'
)

function Step($msg){ Write-Host "`n[STEP] $msg" -ForegroundColor Cyan }
function Info($msg){ Write-Host "[OK] $msg" -ForegroundColor Green }
function Warn($msg){ Write-Host "[WARN] $msg" -ForegroundColor Yellow }
function Err($msg){ Write-Host "[ERROR] $msg" -ForegroundColor Red }

if(-not $ClientId){ Err 'CLIENT_ID not provided (set env var or pass -ClientId).'; exit 1 }
if(-not $GitRepo){ Err 'GIT_REPO_URL not provided.'; exit 1 }
if(-not $GitBranch){ Err 'GIT_BRANCH not provided.'; exit 1 }

# Optional network binding HOST & port selection
$HostBind = if($env:HOST){ $env:HOST } else { '127.0.0.1' }
$RequestedPort = $env:HEALTH_CHECK_PORT

function Test-PortInUse([int]$Port){
    try {
        $listener = New-Object System.Net.Sockets.TcpListener([System.Net.IPAddress]::Loopback, $Port)
        $listener.Start(); $listener.Stop(); return $false
    } catch { return $true }
}

function Find-FreePort([int]$Start){
    for($p=$Start; $p -lt ($Start+50); $p++){
        if(-not (Test-PortInUse $p)){ return $p }
    }
    return $null
}

if($RequestedPort){
    if(Test-PortInUse ([int]$RequestedPort)){
        Warn "Requested HEALTH_CHECK_PORT=$RequestedPort in use. Searching next free..."
        $Free = Find-FreePort ([int]$RequestedPort + 1)
        if($Free){ $env:HEALTH_CHECK_PORT = $Free } else { $env:HEALTH_CHECK_PORT = 9090 }
    } else { $env:HEALTH_CHECK_PORT = $RequestedPort }
} else {
    $Free = Find-FreePort 9090
    if($Free){ $env:HEALTH_CHECK_PORT = $Free } else { $env:HEALTH_CHECK_PORT = 9090 }
}
$env:HOST = $HostBind
Info "Using HOST=$($env:HOST) HEALTH_CHECK_PORT=$($env:HEALTH_CHECK_PORT)"

$GitToken = $env:GIT_TOKEN
$CloneMethod = $env:CLONE_METHOD
if(-not $CloneMethod -and $env:USE_SSH){ $CloneMethod = 'ssh' }
if(-not $CloneMethod){
    if($GitRepo -match '^git@'){ $CloneMethod = 'ssh' } else { $CloneMethod = 'https' }
}

$EffectiveCloneUrl = $GitRepo
if($CloneMethod -eq 'https'){
    if(-not $GitToken){
        Warn '(HTTPS mode) GIT_TOKEN not set. Private repo clone may prompt or fail.'
        Warn 'Set fine-grained PAT (Contents:Read, Metadata:Read):  $env:GIT_TOKEN = "ghp_xxx"'
    }
    if($GitToken -and $GitRepo -match '^https://'){
        $repoNoProto = $GitRepo.Substring(8)
        if($repoNoProto.Contains('@')){ $repoNoProto = $repoNoProto.Split('@')[-1] }
        $EffectiveCloneUrl = "https://$GitToken@$repoNoProto"
    } elseif($GitToken) {
        Warn 'GIT_TOKEN provided but URL not https:// - skipping token injection.'
    }
} elseif($CloneMethod -eq 'ssh') {
    Info 'SSH clone mode selected (CLONE_METHOD=ssh). Ensure your SSH key is loaded (ssh-add -l).'
} else {
    Warn "Unknown CLONE_METHOD=$CloneMethod (expected ssh or https). Defaulting to https."; $CloneMethod = 'https'
}

Step "0. Preflight repository access ($CloneMethod)"
if(Get-Command git -ErrorAction SilentlyContinue){
    if($CloneMethod -eq 'https'){
        git ls-remote --heads $EffectiveCloneUrl $GitBranch *> $null
        if($LASTEXITCODE -ne 0){
            if(-not $GitToken){ Err "Cannot access $GitBranch via HTTPS at $GitRepo. Set GIT_TOKEN or switch to SSH (CLONE_METHOD=ssh)."; exit 1 }
            else { Err 'Access denied even with provided GIT_TOKEN. Check token permissions (Contents: Read).'; exit 1 }
        } else { Info 'Preflight access OK (HTTPS).' }
    } else {
        git ls-remote --heads $GitRepo $GitBranch *> $null
        if($LASTEXITCODE -ne 0){ Err "SSH access failed for $GitBranch at $GitRepo. Ensure your SSH key has repo read access."; exit 1 }
        else { Info 'Preflight access OK (SSH).' }
    }
} else { Err 'git command not found in PATH.'; exit 1 }

$RepoDir = Join-Path $RootDir 'repo'

# Reuse current directory if already suitable
try {
    $isGit = (git rev-parse --is-inside-work-tree 2>$null)
    if($LASTEXITCODE -eq 0){
        $currentBranch = (git rev-parse --abbrev-ref HEAD 2>$null)
        $remoteUrl = (git config --get remote.origin.url 2>$null)
        if($currentBranch -eq $GitBranch -and $remoteUrl){
            # Simple suffix match to allow token variations
            if($GitRepo -and ($remoteUrl.EndsWith((Split-Path $GitRepo -Leaf)) -or $GitRepo.EndsWith((Split-Path $remoteUrl -Leaf)))){
                Info 'Detected existing matching repository. Reusing current directory.'
                $RepoDir = (Get-Location).Path
                $Reuse = $true
            }
        }
    }
} catch {}

Step '1. Creating base directory'
if(-not (Test-Path $RootDir)){ New-Item -ItemType Directory -Path $RootDir | Out-Null }
Info "Base directory: $RootDir"

if($Reuse){
    Step "2. Using existing repository ($GitBranch)"
    try { git fetch --all 2>$null } catch { Warn 'Fetch failed.' }
    try { git checkout $GitBranch 2>$null } catch { Err "Failed to checkout $GitBranch"; exit 1 }
    try { git pull origin $GitBranch 2>$null } catch { Warn 'Pull failed; continuing.' }
} else {
    Step "2. Cloning or updating branch $GitBranch"
    if(Test-Path (Join-Path $RepoDir '.git')){
            Warn 'Repository exists. Pulling updates.'
            git -C $RepoDir fetch --all 2>$null
            git -C $RepoDir checkout $GitBranch 2>$null
            git -C $RepoDir pull origin $GitBranch 2>$null
    }else{
            git clone --branch $GitBranch --single-branch $EffectiveCloneUrl $RepoDir | Out-Null
    }
    if($LASTEXITCODE -ne 0){ Err 'Git operation failed.'; exit 1 }
    Info 'Repository ready.'
    Set-Location $RepoDir
}

Step '3. Installing Node dependencies'
if(Get-Command npm -ErrorAction SilentlyContinue){
    npm install --no-audit --no-fund | Out-Null
    if($LASTEXITCODE -ne 0){ Err 'npm install failed.'; exit 1 }
    Info 'Dependencies installed.'
}else{ Err 'npm not found. Install Node.js first.'; exit 1 }

Step '4. Generating local configuration (if available)'
if(Test-Path 'scripts/generate-local-config.js'){
    node scripts/generate-local-config.js load --client-id $ClientId
    if($LASTEXITCODE -ne 0){ Warn 'Config generation failed or partial.' }
}else{ Warn 'Config generation script not present. Continuing.' }

Step '5. Basic validation'
if(Test-Path 'scripts/test-database-connection.js'){
    node scripts/test-database-connection.js
    if($LASTEXITCODE -ne 0){ Warn 'Database connectivity test failed (DB down or creds missing?).' }
}else{ Warn 'Database test script not found.' }

Step '6. Starting agent (background)'
if(Test-Path 'client-agent/deployment-agent.js'){
    Start-Process -FilePath 'node' -ArgumentList 'client-agent/deployment-agent.js' -WorkingDirectory $RepoDir -WindowStyle Hidden
    Info 'Agent process launched.'
}else{ Err 'Agent file missing: client-agent/deployment-agent.js'; exit 1 }

Start-Sleep -Seconds 5

Step '7. Health check'
$HealthPort = $env:HEALTH_CHECK_PORT; if(-not $HealthPort){ $HealthPort = 9090 }
try{
    $resp = Invoke-WebRequest -Uri "http://localhost:$HealthPort/health" -UseBasicParsing -TimeoutSec 5
    if($resp.StatusCode -eq 200){ Info 'Health endpoint responding.' } else { Warn 'Health endpoint returned non-200.' }
}catch{ Warn 'Health endpoint not responding yet.' }

Step '8. Summary'
@"
------------------------------------------------------------------
Client ID        : $ClientId
Branch           : $GitBranch
Repo Directory   : $RepoDir
Health Endpoint  : http://$($env:HOST):$HealthPort/health
Status Endpoint  : http://$($env:HOST):$HealthPort/status
Logs (PowerShell): Get-Content $RepoDir\logs\agent.log -Tail 100 -Wait
Restart (manual) : Stop existing node process then: node client-agent/deployment-agent.js
------------------------------------------------------------------
"@ | Write-Host

Info 'Bootstrap complete.'