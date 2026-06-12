# Local installer for project-init skills + auto-init hook (Windows)
# Run: .\install.ps1

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$Target = Join-Path $HOME ".claude"

Write-Host "Installing to: $Target"

# Create directories
New-Item -ItemType Directory -Force -Path "$Target\hooks" | Out-Null
New-Item -ItemType Directory -Force -Path "$Target\skills\project-init" | Out-Null
New-Item -ItemType Directory -Force -Path "$Target\skills\webcoded-audit" | Out-Null

# Copy skills
Copy-Item -Force "$ScriptDir\skills\project-init\SKILL.md" "$Target\skills\project-init\"
Copy-Item -Force "$ScriptDir\skills\webcoded-audit\SKILL.md" "$Target\skills\webcoded-audit\"

# Copy hook
Copy-Item -Force "$ScriptDir\hooks\project-auto-init.sh" "$Target\hooks\"

# Create settings.json if it doesn't exist
$SettingsFile = "$Target\settings.json"

if (-not (Test-Path $SettingsFile)) {
    $settings = @'
{
    "$schema": "https://json.schemastore.org/claude-code-settings.json",
    "hooks": {
        "SessionStart": [
            {
                "matcher": "",
                "hooks": [
                    {
                        "type": "command",
                        "command": "~/.claude/hooks/project-auto-init.sh"
                    }
                ]
            }
        ]
    }
}
'@
    $settings | Out-File -FilePath $SettingsFile -Encoding utf8
    Write-Host "Created settings.json with SessionStart hook"
} else {
    Write-Host "settings.json exists - check that SessionStart hook is registered"
}

Write-Host ""
Write-Host "Installed:"
Write-Host "   $Target\skills\project-init\SKILL.md"
Write-Host "   $Target\skills\webcoded-audit\SKILL.md"
Write-Host "   $Target\hooks\project-auto-init.sh"
Write-Host ""
Write-Host "Restart Claude Code. The hook will auto-run on every project."
Write-Host "Skills available: /project-init, /webcoded-audit"
