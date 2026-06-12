#!/bin/bash
# Offline installer — no network. Copies bundled skills + hook, registers SessionStart.
# Usage: ./install.sh
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
T="$HOME/.claude"
mkdir -p "$T/skills/project-init" "$T/skills/webcoded-audit" "$T/hooks"

cp "$DIR/skills/project-init/SKILL.md"   "$T/skills/project-init/"
cp "$DIR/skills/webcoded-audit/SKILL.md" "$T/skills/webcoded-audit/"
cp "$DIR/hooks/project-auto-init.sh"     "$T/hooks/"
chmod +x "$T/hooks/project-auto-init.sh"

# Merge SessionStart hook into settings.json (no overwrite of existing hooks)
python3 - "$T/settings.json" <<'PY'
import json,os,sys
p=sys.argv[1]
d=json.load(open(p)) if os.path.exists(p) else {}
d.setdefault("hooks",{}).setdefault("SessionStart",[])
cmd="~/.claude/hooks/project-auto-init.sh"
exists=any(h.get("command")==cmd for g in d["hooks"]["SessionStart"] for h in g.get("hooks",[]))
if not exists:
    d["hooks"]["SessionStart"].append({"matcher":"","hooks":[{"type":"command","command":cmd}]})
json.dump(d,open(p,"w"),indent=2)
print("settings.json updated" if not exists else "already registered")
PY

echo ""
echo "Installed -> $T"
echo "  skills/project-init/SKILL.md"
echo "  skills/webcoded-audit/SKILL.md"
echo "  hooks/project-auto-init.sh"
echo "Restart Claude Code. Commands: /project-init  /webcoded-audit"
