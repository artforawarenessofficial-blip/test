#!/bin/bash
# SessionStart Hook: Auto-initialize project tools
# This runs when a Claude Code session starts

set -e

echo "🔧 Checking project setup..."

# Track what needs attention
NEEDS_SETUP=()

# 1. Check OpenSpec
if [ ! -d "openspec" ] && [ ! -f "openspec/config.yaml" ]; then
    NEEDS_SETUP+=("openspec")
    echo "⚠ OpenSpec not initialized"
else
    echo "✓ OpenSpec found"
fi

# 2. Check Graphify
if [ ! -d "graphify-out" ] || [ ! -f "graphify-out/graph.json" ]; then
    NEEDS_SETUP+=("graphify")
    echo "⚠ Graphify not initialized"
else
    echo "✓ Graphify found"
fi

# 3. Check CLAUDE.md security rules
if [ -f "CLAUDE.md" ]; then
    if grep -q "Security Rules" CLAUDE.md 2>/dev/null; then
        echo "✓ Security rules in CLAUDE.md"
    else
        NEEDS_SETUP+=("security")
        echo "⚠ Security rules missing from CLAUDE.md"
    fi
else
    NEEDS_SETUP+=("claude-md")
    echo "⚠ CLAUDE.md not found"
fi

# 4. Check Caveman (token optimization)
if [ -f "$HOME/.claude/skills/caveman/SKILL.md" ] || [ -f ".claude/skills/caveman/SKILL.md" ]; then
    echo "✓ Caveman installed"
else
    NEEDS_SETUP+=("caveman")
    echo "⚠ Caveman not installed (saves ~65% output tokens)"
fi

# Output summary
if [ ${#NEEDS_SETUP[@]} -eq 0 ]; then
    echo ""
    echo "✅ Project fully configured!"
else
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Setup needed: ${NEEDS_SETUP[*]}"
    echo ""
    echo "Run /project-init to set up missing tools:"

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
                echo "  • curl -fsSL https://caveman.sh/install.sh | bash"
                ;;
        esac
    done
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
fi
