# Offline installer (Windows) — no network. Copies bundled skills + hook.
# Usage: .\install.ps1
$Dir = Split-Path -Parent $MyInvocation.MyCommand.Path
$T = Join-Path $HOME ".claude"
New-Item -ItemType Directory -Force -Path "$T\skills\project-init","$T\skills\webcoded-audit","$T\hooks" | Out-Null

Copy-Item -Force "$Dir\skills\project-init\SKILL.md"   "$T\skills\project-init\"
Copy-Item -Force "$Dir\skills\webcoded-audit\SKILL.md" "$T\skills\webcoded-audit\"
Copy-Item -Force "$Dir\hooks\project-auto-init.sh"     "$T\hooks\"

$sf = "$T\settings.json"
if (Test-Path $sf) { $d = Get-Content $sf -Raw | ConvertFrom-Json } else { $d = [PSCustomObject]@{} }
if (-not $d.hooks) { $d | Add-Member hooks ([PSCustomObject]@{}) -Force }
if (-not $d.hooks.SessionStart) { $d.hooks | Add-Member SessionStart @() -Force }
$cmd = "~/.claude/hooks/project-auto-init.sh"
$has = $false
foreach ($g in $d.hooks.SessionStart) { foreach ($h in $g.hooks) { if ($h.command -eq $cmd) { $has = $true } } }
if (-not $has) {
  $d.hooks.SessionStart += [PSCustomObject]@{ matcher=""; hooks=@([PSCustomObject]@{ type="command"; command=$cmd }) }
}
$d | ConvertTo-Json -Depth 20 | Out-File -FilePath $sf -Encoding utf8

Write-Host "Installed -> $T"
Write-Host "Restart Claude Code. Commands: /project-init  /webcoded-audit"
