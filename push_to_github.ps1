# Push script for Abhishek Chauhan's 3D GitHub Profile Repository
param (
    [string]$GitHubToken = ""
)

$ErrorActionPreference = "Stop"
$repoPath = $PSScriptRoot
Set-Location $repoPath

$mingitCmd = "$env:LOCALAPPDATA\MinGit\cmd"
if (Test-Path $mingitCmd) {
    $env:Path = "$env:Path;$mingitCmd"
}

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   Deploying 3D Azure Landing Zone to GitHub Profile      " -ForegroundColor Yellow
Write-Host "   Repository: abhishekchauhan11323-star/abhishekchauhan11323-star" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. Initialize Git repository if not already done
if (-not (Test-Path "$repoPath\.git")) {
    git init -b main
    Write-Host "[✓] Initialized local git repository on branch main" -ForegroundColor Green
} else {
    git branch -M main
}

# 2. Set Git config identity
git config user.name "abhishekchauhan11323-star"
git config user.email "abhishekchauhan11323@users.noreply.github.com"

# 3. Stage and commit all files
git add .
$status = git status --porcelain
if ($status) {
    git commit -m "feat(profile): Initial 3D Enterprise Azure Landing Zone & Zero-Trust Architecture"
    Write-Host "[✓] Committed all production files and 3D architectural assets" -ForegroundColor Green
} else {
    Write-Host "[i] No new changes to commit" -ForegroundColor DarkGray
}

# 4. Configure Remote URL
$remoteUrl = "https://github.com/abhishekchauhan11323-star/abhishekchauhan11323-star.git"
if ($GitHubToken -ne "") {
    $remoteUrl = "https://$GitHubToken@github.com/abhishekchauhan11323-star/abhishekchauhan11323-star.git"
}

$existingRemote = git remote
if ($existingRemote -contains "origin") {
    git remote set-url origin $remoteUrl
} else {
    git remote add origin $remoteUrl
}

Write-Host "[✓] Configured remote origin: $remoteUrl" -ForegroundColor Green

# 5. Push to GitHub
Write-Host "[→] Pushing to GitHub main branch..." -ForegroundColor Cyan
try {
    git push -u origin main --force
    Write-Host "[SUCCESS] Successfully pushed to GitHub!" -ForegroundColor Green
    Write-Host "Check your GitHub Profile at: https://github.com/abhishekchauhan11323-star" -ForegroundColor Yellow
} catch {
    Write-Host "[!] Push encountered an authentication or remote repository requirement." -ForegroundColor Red
    Write-Host "Make sure the repository 'abhishekchauhan11323-star' exists on GitHub at https://github.com/new" -ForegroundColor Yellow
    Write-Host "Run: .\push_to_github.ps1 -GitHubToken 'YOUR_GITHUB_PAT'" -ForegroundColor Yellow
}
