#!/bin/bash
set -euo pipefail

# Only run in Claude Code on the web (remote environment)
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

echo "🚀 Project Auto-Init: Checking setup..."

# ============================================================
# PART 1: Ensure skills are installed at user level
# ============================================================

SKILLS_DIR="$HOME/.claude/skills"
REPO_URL="https://github.com/artforawarenessofficial-blip/test"
BRANCH="claude/slack-session-qZF0H"

install_skills() {
  echo "📦 Installing skills..."

  mkdir -p "$SKILLS_DIR/project-init"
  mkdir -p "$SKILLS_DIR/webcoded-audit"

  # Download skills from the repo
  curl -fsSL "https://raw.githubusercontent.com/artforawarenessofficial-blip/test/$BRANCH/.claude/skills/project-init/SKILL.md" \
    -o "$SKILLS_DIR/project-init/SKILL.md" 2>/dev/null || true

  curl -fsSL "https://raw.githubusercontent.com/artforawarenessofficial-blip/test/$BRANCH/.claude/skills/webcoded-audit/SKILL.md" \
    -o "$SKILLS_DIR/webcoded-audit/SKILL.md" 2>/dev/null || true

  echo "✓ Skills installed"
}

# Check if skills exist, install if missing
if [ ! -f "$SKILLS_DIR/project-init/SKILL.md" ] || [ ! -f "$SKILLS_DIR/webcoded-audit/SKILL.md" ]; then
  install_skills
else
  echo "✓ Skills already installed"
fi

# ============================================================
# PART 2: Project-level checks (runs in current project dir)
# ============================================================

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
cd "$PROJECT_DIR"

NEEDS_SETUP=()

# Check OpenSpec
if [ ! -d "openspec" ] && [ ! -f "openspec/config.yaml" ]; then
  NEEDS_SETUP+=("openspec")
  echo "⚠ OpenSpec not initialized"
else
  echo "✓ OpenSpec found"
fi

# Check Graphify
if [ ! -d "graphify-out" ] || [ ! -f "graphify-out/graph.json" ]; then
  NEEDS_SETUP+=("graphify")
  echo "⚠ Graphify not initialized"
else
  echo "✓ Graphify found"
fi

# Check CLAUDE.md security rules
if [ -f "CLAUDE.md" ]; then
  if grep -q "Security Rules\|security rules\|Security rules" CLAUDE.md 2>/dev/null; then
    echo "✓ Security rules in CLAUDE.md"
  else
    NEEDS_SETUP+=("security")
    echo "⚠ Security rules missing from CLAUDE.md"
  fi
else
  NEEDS_SETUP+=("claude-md")
  echo "⚠ CLAUDE.md not found"
fi

# Check Caveman
if [ -d "$HOME/.claude/skills/caveman" ] || command -v caveman &>/dev/null; then
  echo "✓ Caveman available"
else
  NEEDS_SETUP+=("caveman")
  echo "⚠ Caveman not installed (saves ~65% output tokens)"
fi

# ============================================================
# PART 3: Summary
# ============================================================

echo ""
if [ ${#NEEDS_SETUP[@]} -eq 0 ]; then
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "✅ Project fully configured!"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
else
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "📋 Setup needed: ${NEEDS_SETUP[*]}"
  echo ""
  echo "Run /project-init to set up, or manually:"
  for item in "${NEEDS_SETUP[@]}"; do
    case $item in
      openspec)
        echo "  • openspec init"
        ;;
      graphify)
        echo "  • graphify install && graphify ."
        ;;
      security|claude-md)
        echo "  • Add security rules to CLAUDE.md"
        ;;
      caveman)
        echo "  • curl -fsSL https://raw.githubusercontent.com/JuliusBrussee/caveman/main/install.sh | bash"
        ;;
    esac
  done
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
fi

echo ""
echo "Available skills: /project-init, /webcoded-audit"
