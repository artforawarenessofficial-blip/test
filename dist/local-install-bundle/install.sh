#!/bin/bash
# Local installer for project-init skills + auto-init hook
# Run: ./install.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="$HOME/.claude"

echo "Installing to: $TARGET"

# Create directories
mkdir -p "$TARGET/hooks"
mkdir -p "$TARGET/skills/project-init"
mkdir -p "$TARGET/skills/webcoded-audit"

# Copy skills
cp "$SCRIPT_DIR/skills/project-init/SKILL.md" "$TARGET/skills/project-init/"
cp "$SCRIPT_DIR/skills/webcoded-audit/SKILL.md" "$TARGET/skills/webcoded-audit/"

# Copy hook
cp "$SCRIPT_DIR/hooks/project-auto-init.sh" "$TARGET/hooks/"
chmod +x "$TARGET/hooks/project-auto-init.sh"

# Update settings.json
SETTINGS_FILE="$TARGET/settings.json"

if [ -f "$SETTINGS_FILE" ]; then
  # Check if SessionStart hook already exists
  if grep -q "project-auto-init.sh" "$SETTINGS_FILE"; then
    echo "✓ Hook already registered in settings.json"
  else
    echo "⚠ Please manually add SessionStart hook to $SETTINGS_FILE"
    echo "  See settings-template.json for the format"
  fi
else
  # Create new settings.json
  cat > "$SETTINGS_FILE" << 'SETTINGS'
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
SETTINGS
  echo "✓ Created settings.json with SessionStart hook"
fi

echo ""
echo "✅ Installed:"
echo "   $TARGET/skills/project-init/SKILL.md"
echo "   $TARGET/skills/webcoded-audit/SKILL.md"
echo "   $TARGET/hooks/project-auto-init.sh"
echo ""
echo "Restart Claude Code. The hook will auto-run on every project."
echo "Skills available: /project-init, /webcoded-audit"
