param (
    [switch]$Force,
    [switch]$List,
    [switch]$Help
)

function Show-Usage {
    Write-Host "Usage: .\sync-branches.ps1 [-Force] [-List] [-Help]" -ForegroundColor Cyan
    Write-Host "  -Force : Force delete untracked local branches" -ForegroundColor Gray
    Write-Host "  -List  : List remote branches after sync" -ForegroundColor Gray
    Write-Host "  -Help  : Show this message" -ForegroundColor Gray
    exit
}

if ($Help) {
    Show-Usage
}

# Step 1: Fetch and prune
Write-Host "Fetching from origin and pruning deleted branches..." -ForegroundColor Yellow
git fetch --all --prune

# Step 2: Delete local branches tracking deleted remotes
Write-Host "Cleaning up local branches with no remote..." -ForegroundColor Yellow
$branches = git branch -vv | Select-String ": gone]" | ForEach-Object {
    ($_ -split "\s+")[1]
}

foreach ($branch in $branches) {
    if ($Force) {
        Write-Host "Force deleting: $branch" -ForegroundColor Red
        git branch -D $branch | Out-Null
    } else {
        Write-Host "Deleting: $branch" -ForegroundColor Green
        git branch -d $branch | Out-Null
    }
}

# Step 3: Auto-track new remote branches
Write-Host "Checking for new remote branches to track..." -ForegroundColor Yellow

# Get all remote branches (excluding HEAD)
$remoteBranches = git branch -r | ForEach-Object {
    ($_ -replace 'origin/', '').Trim()
} | Where-Object { $_ -ne 'HEAD' }

# Get all local branches
$localBranches = git branch --format='%(refname:short)'

# Determine missing branches
$missingBranches = $remoteBranches | Where-Object { $localBranches -notcontains $_ }

foreach ($branch in $missingBranches) {
    Write-Host "Tracking new branch: $branch" -ForegroundColor Cyan
    git branch --track $branch origin/$branch | Out-Null
}

# Step 4: Optionally list remotes
if ($List) {
    Write-Host "Remote branches:" -ForegroundColor Cyan
    git branch -r
}

Write-Host "✔ Sync complete." -ForegroundColor Green
