# Offline installer for project-init + webcoded-audit skills (Windows PowerShell)
# Usage:
#   .\install.ps1            install for current user ($HOME\.claude)  -> all projects
#   .\install.ps1 -Project   install into this repo (.\.claude)        -> this project only

param([switch]$Project)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

if ($Project) {
    $Target = ".claude"
    $Scope  = "this project"
} else {
    $Target = Join-Path $HOME ".claude"
    $Scope  = "current user (all projects)"
}

Write-Host "Installing Claude skills into: $Target  ($Scope)"

New-Item -ItemType Directory -Force -Path "$Target\skills" | Out-Null
New-Item -ItemType Directory -Force -Path "$Target\hooks"  | Out-Null

Copy-Item -Recurse -Force "$ScriptDir\project-init"   "$Target\skills\"
Copy-Item -Recurse -Force "$ScriptDir\webcoded-audit" "$Target\skills\"
Copy-Item -Force "$ScriptDir\hooks\session-start.sh"  "$Target\hooks\"

Write-Host ""
Write-Host "Installed:"
Write-Host "  $Target\skills\project-init\SKILL.md"
Write-Host "  $Target\skills\webcoded-audit\SKILL.md"
Write-Host "  $Target\hooks\session-start.sh"
Write-Host ""
Write-Host "Restart Claude Code, then use /project-init and /webcoded-audit"
