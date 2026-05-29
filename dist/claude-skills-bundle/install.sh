#!/bin/bash
# Offline installer for project-init + webcoded-audit skills
# Usage:
#   ./install.sh            install for current user (~/.claude)  -> all projects
#   ./install.sh --project  install into this repo (./.claude)    -> this project only

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ "$1" = "--project" ]; then
    TARGET=".claude"
    SCOPE="this project"
else
    TARGET="$HOME/.claude"
    SCOPE="current user (all projects)"
fi

echo "Installing Claude skills into: $TARGET  ($SCOPE)"

mkdir -p "$TARGET/skills" "$TARGET/hooks"

# Skills (folder + SKILL.md each)
cp -r "$SCRIPT_DIR/project-init"   "$TARGET/skills/"
cp -r "$SCRIPT_DIR/webcoded-audit" "$TARGET/skills/"

# Hook
cp "$SCRIPT_DIR/hooks/session-start.sh" "$TARGET/hooks/"
chmod +x "$TARGET/hooks/session-start.sh"

echo ""
echo "Installed:"
echo "  $TARGET/skills/project-init/SKILL.md"
echo "  $TARGET/skills/webcoded-audit/SKILL.md"
echo "  $TARGET/hooks/session-start.sh"
echo ""
echo "Restart Claude Code, then use /project-init and /webcoded-audit"
