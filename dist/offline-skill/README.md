# Offline Skill Bundle

Self-contained. No internet needed to install.

## Contents
- `skills/project-init/SKILL.md` — `/project-init` command
- `skills/webcoded-audit/SKILL.md` — `/webcoded-audit` command
- `hooks/project-auto-init.sh` — auto-runs every session
- `install.sh` / `install.ps1` — offline installers

## Install

**Mac/Linux:**
```bash
./install.sh
```

**Windows:**
```powershell
.\install.ps1
```

Installs to `~/.claude/`. Restart Claude Code.

## Scope
- **Local CLI:** `~/.claude/` persists → works all projects, forever.
- **Web:** `~/.claude/` wiped each session. For web, commit `.claude/` into each repo instead.

## Tools still need separate install (need network, one time)
The skills/checklists work offline. But OpenSpec/Graphify/Caveman themselves need install when online:
```bash
npm install -g @fission-ai/openspec@latest
uv tool install graphifyy
curl -fsSL https://raw.githubusercontent.com/JuliusBrussee/caveman/main/install.sh | bash
```
