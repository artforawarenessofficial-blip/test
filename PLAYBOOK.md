# Claude Code Project Auto-Init Playbook

**Complete setup guide for automated project initialization with OpenSpec, Graphify, Caveman, and security checklists.**

Last updated: 2026-05-29

---

## Table of Contents

1. [What This Is](#what-this-is)
2. [Prerequisites](#prerequisites)
3. [Quick Install (Online)](#quick-install-online)
4. [Manual Install (Offline)](#manual-install-offline)
5. [File Contents](#file-contents)
6. [How It Works](#how-it-works)
7. [Usage](#usage)
8. [Web vs Local](#web-vs-local)
9. [Troubleshooting](#troubleshooting)

---

## What This Is

A set of Claude Code skills and hooks that automatically:

| Component | What It Does |
|-----------|--------------|
| **OpenSpec** | Spec-driven development. Agree on WHAT before coding. |
| **Graphify** | Knowledge graph of your codebase. Query instead of grep. |
| **Caveman** | Compresses AI responses ~65%. Same accuracy, fewer tokens. |
| **Auto-init hook** | Runs every session. Creates CLAUDE.md, checks setup. |
| **Checklists** | Website creation + deployment security checklists. |

**Result:** Open any project → everything auto-configures → Claude knows your codebase, remembers decisions, follows security rules.

---

## Prerequisites

| Tool | Version | Check | Install |
|------|---------|-------|---------|
| Node.js | ≥18 | `node --version` | https://nodejs.org |
| Python | ≥3.10 | `python3 --version` | https://python.org |
| Claude Code | Latest | `claude --version` | `npm install -g @anthropic-ai/claude-code` |

---

## Quick Install (Online)

Run these commands once. Works on Mac/Linux. Windows: use WSL or adapt paths.

### Step 1: Install the three tools

```bash
# OpenSpec (spec-driven development)
npm install -g @fission-ai/openspec@latest

# Graphify (knowledge graph)
pip install graphifyy
# or: uv tool install graphifyy
# or: pipx install graphifyy

# Caveman (token compression)
curl -fsSL https://raw.githubusercontent.com/JuliusBrussee/caveman/main/install.sh | bash
```

### Step 2: Create skill directories

```bash
mkdir -p ~/.claude/skills/project-init
mkdir -p ~/.claude/skills/webcoded-audit
mkdir -p ~/.claude/hooks
```

### Step 3: Create the skill files

Copy each file below into the correct location.

### Step 4: Register the hook

The installer script (in File Contents below) handles this, or manually add to `~/.claude/settings.json`:

```json
{
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
```

### Step 5: Restart Claude Code

```bash
claude
```

Commands available: `/project-init`, `/webcoded-audit`, `/graphify`, `/opsx:propose`

---

## Manual Install (Offline)

For machines without internet access.

### Step 1: On a machine WITH internet

1. Copy all files from [File Contents](#file-contents) section below
2. Save them with exact filenames and paths
3. Transfer entire `offline-skill/` folder to offline machine (USB, network share, etc.)

### Step 2: On the offline machine

```bash
cd offline-skill
./install.sh
```

Windows:
```powershell
cd offline-skill
.\install.ps1
```

---

## File Contents

### Directory Structure

```
~/.claude/
├── hooks/
│   └── project-auto-init.sh      ← SessionStart hook
├── skills/
│   ├── project-init/
│   │   └── SKILL.md              ← /project-init command
│   └── webcoded-audit/
│       └── SKILL.md              ← /webcoded-audit command
└── settings.json                  ← hook registration
```

---

### FILE: ~/.claude/hooks/project-auto-init.sh

```bash
#!/bin/bash
set -euo pipefail

# Runs everywhere: local CLI, desktop, and Claude Code on the web.
# Ensure user-local tool dirs are on PATH (openspec, graphify, etc.)
export PATH="$HOME/.local/bin:$HOME/.npm-global/bin:$PATH"

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
cd "$PROJECT_DIR"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 PROJECT AUTO-INIT"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ============================================================
# PART 1: AUTO-INSTALL SKILLS (user-level, once)
# ============================================================

SKILLS_DIR="$HOME/.claude/skills"
BRANCH="claude/slack-session-qZF0H"

if [ ! -f "$SKILLS_DIR/project-init/SKILL.md" ]; then
  echo "📦 Installing project-init skill..."
  mkdir -p "$SKILLS_DIR/project-init"
  curl -fsSL "https://raw.githubusercontent.com/artforawarenessofficial-blip/test/$BRANCH/.claude/skills/project-init/SKILL.md" \
    -o "$SKILLS_DIR/project-init/SKILL.md" 2>/dev/null && echo "  ✓ Installed" || echo "  ⚠ Failed (offline?)"
fi

if [ ! -f "$SKILLS_DIR/webcoded-audit/SKILL.md" ]; then
  echo "📦 Installing webcoded-audit skill..."
  mkdir -p "$SKILLS_DIR/webcoded-audit"
  curl -fsSL "https://raw.githubusercontent.com/artforawarenessofficial-blip/test/$BRANCH/.claude/skills/webcoded-audit/SKILL.md" \
    -o "$SKILLS_DIR/webcoded-audit/SKILL.md" 2>/dev/null && echo "  ✓ Installed" || echo "  ⚠ Failed (offline?)"
fi

# ============================================================
# PART 2: AUTO-INITIALIZE PROJECT TOOLS
# ============================================================

echo ""
echo "📁 Project: $PROJECT_DIR"
echo ""

# --- OpenSpec ---
if [ ! -d "openspec" ]; then
  if command -v openspec &>/dev/null; then
    echo "🔧 Initializing OpenSpec..."
    openspec init 2>/dev/null && echo "  ✓ OpenSpec initialized" || echo "  ⚠ OpenSpec init failed"
  else
    echo "⚠ OpenSpec not installed (npm install -g @fission-ai/openspec@latest)"
  fi
else
  echo "✓ OpenSpec ready"
fi

# --- Graphify ---
if [ ! -f "graphify-out/graph.json" ]; then
  if command -v graphify &>/dev/null; then
    echo "🔧 Building knowledge graph..."
    graphify install --project 2>/dev/null || true
    graphify . 2>/dev/null && echo "  ✓ Graphify initialized" || echo "  ⚠ Graphify build failed"
  else
    echo "⚠ Graphify not installed (uv tool install graphifyy)"
  fi
else
  echo "✓ Graphify ready (graph.json exists)"
fi

# --- CLAUDE.md with Security Rules ---
if [ ! -f "CLAUDE.md" ]; then
  echo "🔧 Creating CLAUDE.md with security rules..."
  cat > CLAUDE.md << 'CLAUDEMD'
# Project Context

## Overview
<!-- Describe what this project does -->

## Tech Stack
<!-- List frameworks, languages, databases -->

## Security Rules — Non-Negotiable

- Never put secrets in client-bundled code (`NEXT_PUBLIC_*`, `VITE_*`, `PUBLIC_*`, `REACT_APP_*`)
- Never use Supabase `service_role` key outside server-only code
- Every new table must have Row Level Security enabled with explicit policies
- Every API route must check BOTH authentication AND authorization for the specific resource
- Every webhook must verify provider signatures before any logic
- Validate all input server-side with a schema library (Zod/Valibot/Yup)
- Use parameterized queries only — never string-concatenate SQL
- No `dangerouslySetInnerHTML` unless sanitized with DOMPurify
- Hash passwords with bcrypt (cost ≥10), argon2id, or scrypt

## Never Do

- Never commit `.env*` files (only `.env.example`)
- Never trust prices, IDs, roles, or user_ids from the client
- Never disable RLS to "fix" a permission error
- Never add dependencies without verifying they exist and are maintained
- Never skip webhook signature verification
- Never expose stack traces or SQL errors in production

## Commands
<!-- List your npm/pnpm scripts here -->
CLAUDEMD
  echo "  ✓ CLAUDE.md created"
elif ! grep -q "Security Rules" CLAUDE.md 2>/dev/null; then
  echo "⚠ CLAUDE.md exists but missing security rules — consider adding them"
else
  echo "✓ CLAUDE.md ready"
fi

# --- Caveman ---
if [ -d "$HOME/.claude/plugins/marketplaces/caveman" ] || [ -f "$HOME/.claude/hooks/caveman-activate.js" ]; then
  echo "✓ Caveman ready (65% token savings)"
else
  echo "⚠ Caveman not installed — run: curl -fsSL https://raw.githubusercontent.com/JuliusBrussee/caveman/main/install.sh | bash"
fi

# ============================================================
# PART 3: WEBSITE CREATION CHECKLIST
# ============================================================

# Detect if this is a web project
IS_WEB_PROJECT=false
if [ -f "package.json" ]; then
  if grep -qE '"next"|"react"|"vue"|"svelte"|"astro"|"nuxt"|"remix"' package.json 2>/dev/null; then
    IS_WEB_PROJECT=true
  fi
fi
if [ -f "index.html" ] || [ -d "src" ] || [ -f "vite.config.ts" ] || [ -f "next.config.js" ]; then
  IS_WEB_PROJECT=true
fi

if [ "$IS_WEB_PROJECT" = true ]; then
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "🌐 WEBSITE CREATION CHECKLIST"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  # Check each item
  [ -f ".env.example" ] && echo "✓ .env.example exists" || echo "☐ Create .env.example (no secrets, just variable names)"
  [ -f ".gitignore" ] && grep -q "\.env" .gitignore 2>/dev/null && echo "✓ .env in .gitignore" || echo "☐ Add .env* to .gitignore"
  [ -f "README.md" ] && echo "✓ README.md exists" || echo "☐ Create README.md"

  # Auth check
  if grep -rq "supabase\|clerk\|auth0\|nextauth\|firebase" . --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" 2>/dev/null; then
    echo "✓ Auth provider detected"
  else
    echo "☐ Set up authentication (Clerk/Supabase Auth/NextAuth)"
  fi

  # RLS check for Supabase
  if grep -rq "supabase" . --include="*.ts" --include="*.tsx" --include="*.js" 2>/dev/null; then
    echo "⚠ Supabase detected — verify RLS is enabled on ALL tables"
  fi

  # Input validation
  if grep -rq "zod\|yup\|valibot\|joi" . --include="*.ts" --include="*.tsx" --include="*.js" 2>/dev/null; then
    echo "✓ Input validation library detected"
  else
    echo "☐ Add server-side validation (Zod recommended)"
  fi

  # Error tracking
  if grep -rq "sentry\|rollbar\|bugsnag" . --include="*.ts" --include="*.tsx" --include="*.js" 2>/dev/null; then
    echo "✓ Error tracking detected"
  else
    echo "☐ Add error tracking (Sentry recommended)"
  fi

  # Security headers
  if [ -f "next.config.js" ] || [ -f "next.config.mjs" ] || [ -f "next.config.ts" ]; then
    if grep -q "headers" next.config.* 2>/dev/null; then
      echo "✓ Security headers configured"
    else
      echo "☐ Add security headers (CSP, HSTS, X-Frame-Options)"
    fi
  fi
fi

# ============================================================
# PART 4: DEPLOYMENT CHECKLIST
# ============================================================

# Detect if deployment config exists
HAS_DEPLOY_CONFIG=false
[ -f "vercel.json" ] || [ -f "netlify.toml" ] || [ -f "fly.toml" ] || [ -f "railway.json" ] || [ -f "render.yaml" ] || [ -d ".github/workflows" ] && HAS_DEPLOY_CONFIG=true

if [ "$HAS_DEPLOY_CONFIG" = true ] || [ "$IS_WEB_PROJECT" = true ]; then
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "🚀 DEPLOYMENT CHECKLIST"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  # Environment
  echo ""
  echo "Environment:"
  [ -f ".env.example" ] && echo "  ✓ .env.example for required vars" || echo "  ☐ Create .env.example"
  if [ -f ".env" ] || [ -f ".env.local" ]; then
    echo "  ⚠ .env file exists — ensure it's gitignored"
  fi

  # Security scan
  echo ""
  echo "Security (run before deploy):"
  echo "  ☐ npm audit / pnpm audit (fix critical/high)"
  echo "  ☐ Check for exposed secrets: git log --all -p | grep -iE 'api.?key|secret|token'"
  echo "  ☐ Verify no secrets in NEXT_PUBLIC_* / VITE_* vars"
  echo "  ☐ Test IDOR: Can user A access user B's data?"

  # Database
  if grep -rq "prisma\|drizzle\|supabase\|postgres\|mysql\|mongo" . --include="*.ts" --include="*.js" --include="*.json" 2>/dev/null; then
    echo ""
    echo "Database:"
    echo "  ☐ Migrations versioned and tested"
    echo "  ☐ Backup configured"
    echo "  ☐ RLS policies on all user tables (if Supabase)"
  fi

  # Webhooks
  if grep -rq "webhook\|stripe\|clerk\|resend" . --include="*.ts" --include="*.tsx" --include="*.js" 2>/dev/null; then
    echo ""
    echo "Webhooks:"
    echo "  ☐ Signature verification on ALL webhook endpoints"
    echo "  ☐ Idempotency (replaying same event = no double-effect)"
  fi

  # Performance
  echo ""
  echo "Performance:"
  echo "  ☐ Lighthouse score ≥90 on mobile"
  echo "  ☐ Core Web Vitals: LCP ≤2.5s, INP ≤200ms, CLS ≤0.1"
  echo "  ☐ Images optimized (WebP/AVIF, lazy loading)"

  # Legal
  echo ""
  echo "Legal & Ops:"
  echo "  ☐ Privacy policy page"
  echo "  ☐ Terms of service page"
  echo "  ☐ Cookie consent (if using cookies)"
  echo "  ☐ Contact/support email configured"
fi

# ============================================================
# PART 5: SUMMARY
# ============================================================

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 AVAILABLE COMMANDS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  /project-init        Full project setup"
echo "  /webcoded-audit      Security audit"
echo "  /graphify .          Rebuild knowledge graph"
echo "  /graphify query ...  Query your codebase"
echo "  /opsx:propose ...    Start spec-driven feature"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
```

**Make executable:** `chmod +x ~/.claude/hooks/project-auto-init.sh`

---

### FILE: ~/.claude/skills/project-init/SKILL.md

```markdown
---
name: project-init
description: Initialize a new project with spec-driven development (OpenSpec), knowledge graph (Graphify), security audit rules (Webcoded Audit), and token optimization (Caveman). Use when starting a new project, setting up a repository, or when the user asks to initialize project tooling, scaffolding, or standards.
---

# Project Init Skill

Automatically initialize a new project with spec-driven development, knowledge graphs, and security best practices.

## Usage

Invoke with: `/project-init` or `/project-init [options]`

Options:
- `--full` - Complete setup (default)
- `--openspec-only` - Only initialize OpenSpec
- `--graphify-only` - Only initialize Graphify
- `--audit-only` - Only set up security audit rules
- `--caveman` - Install Caveman for token optimization

## Auto-Trigger on Session Start

This skill includes a **SessionStart hook** that automatically checks project setup when you open Claude Code. If any tools are missing, it prompts you to run `/project-init`.

The hook checks:
- OpenSpec initialized (`openspec/` exists)
- Graphify initialized (`graphify-out/graph.json` exists)
- Security rules in CLAUDE.md
- Caveman installed (for token savings)

## What This Skill Does

When invoked, this skill sets up four critical workflows for any AI-coded project:

### 1. OpenSpec - Spec-Driven Development
Ensures you agree on WHAT to build before writing code.

### 2. Graphify - Knowledge Graph
Maps your entire codebase into a queryable knowledge graph.

### 3. Webcoded Audit - Security & Quality
Applies the 14-point security checklist for AI-built apps.

### 4. Caveman - Token Optimization
Reduces output tokens by ~65% while maintaining full technical accuracy.

## Instructions

### Step 1: Check Prerequisites

```bash
# Check OpenSpec
openspec --version || echo "OpenSpec not installed"

# Check Graphify  
graphify --version || echo "Graphify not installed"
```

If not installed:

```bash
# Install OpenSpec (requires Node.js 20.19+)
npm install -g @fission-ai/openspec@latest

# Install Graphify (requires Python 3.10+)
uv tool install graphifyy

# Install Caveman (token optimization, requires Node 18+)
curl -fsSL https://raw.githubusercontent.com/JuliusBrussee/caveman/main/install.sh | bash
```

### Step 2: Initialize OpenSpec

```bash
openspec init
```

Creates `openspec/` directory. Workflows:
- `/opsx:propose "feature"` - Create change proposal
- `/opsx:apply` - Implement tasks
- `/opsx:archive` - Archive completed changes

### Step 3: Initialize Graphify

```bash
graphify install
graphify .
```

Creates `graphify-out/` with:
- `graph.html` - Interactive visualization
- `GRAPH_REPORT.md` - Key concepts and connections
- `graph.json` - Queryable graph data

### Step 4: Set Up Security Rules in CLAUDE.md

Add these to your CLAUDE.md:

```markdown
## Security Rules — Non-Negotiable

- Never put secrets in client-bundled code
- Never use Supabase `service_role` key outside server-only code
- Every new table must have Row Level Security enabled with explicit policies
- Every API route must check BOTH authentication AND authorization
- Every webhook must verify provider signatures before any logic
- Validate all input server-side with a schema library (Zod/Valibot/Yup)
- Use parameterized queries only — never string-concatenate SQL
- No `dangerouslySetInnerHTML` unless sanitized with DOMPurify

## Never Do

- Never commit `.env*` files (only `.env.example`)
- Never trust prices, IDs, roles, or user_ids from the client
- Never disable RLS to "fix" a permission error
- Never add dependencies without verifying they exist and are maintained
- Never skip webhook signature verification
```

### Step 5: Install Caveman

```bash
curl -fsSL https://raw.githubusercontent.com/JuliusBrussee/caveman/main/install.sh | bash
```

Commands:
- `/ug` - Toggle caveman mode
- `/ug:lite` - Light compression
- `/ug:full` - Full compression (default)
- `/ug:ultra` - Maximum compression
- `/ug:stats` - Show token savings

## The Four Pillars

| Pillar | Tool | Purpose |
|--------|------|---------|
| **Plan** | OpenSpec | Agree on WHAT before coding |
| **Understand** | Graphify | Query the codebase, find connections |
| **Verify** | Webcoded Audit | Security & quality checks |
| **Optimize** | Caveman | Reduce output tokens by ~65% |

## Why This Matters

AI coding assistants optimize for "code that runs", not "code that's safe to ship". This skill ensures:

1. **You agree before you build** — OpenSpec specs prevent scope creep
2. **You can query, not grep** — Graphify lets you ask questions about your codebase
3. **You catch the 14 common vulnerabilities** — Webcoded Audit covers what AI-coded apps get wrong
4. **You save ~65% on output tokens** — Caveman keeps responses concise

Ship boldly. Audit ruthlessly. Save tokens.
```

---

### FILE: ~/.claude/skills/webcoded-audit/SKILL.md

```markdown
---
name: webcoded-audit
description: Audit AI-built web apps for security and quality issues covering the 14 most common vulnerabilities (RLS, IDOR, secrets, auth, webhooks, input validation). Use when the user wants a security audit, pre-launch checklist, accessibility check, or performance review of a web application.
---

# Webcoded App Audit Skill

Comprehensive audit skill for AI-built web apps.

## Usage

Invoke with: `/webcoded-audit [phase]`

Phases:
- `security` - Full security audit (default)
- `init` - Generate CLAUDE.md
- `rls` - Row Level Security audit
- `secrets` - Secrets scan
- `auth` - Authentication & authorization audit
- `pre-launch` - Pre-launch checklist
- `a11y` - Accessibility audit
- `perf` - Performance audit

## Phase: security

Audit for the 14 most common vulnerabilities in AI-coded apps:

1. **Hardcoded secrets and client-bundled secrets**
   - Search for API keys, tokens, passwords in code
   - Check for secrets behind `NEXT_PUBLIC_*`, `VITE_*`, `PUBLIC_*`

2. **Row Level Security misconfigurations** (Supabase/Firebase)
   - Tables with RLS disabled
   - Policies using `USING (true)` on user data
   - Service role key in client code

3. **IDOR / Broken Object Level Authorization**
   - API routes that check auth but not resource ownership
   - Missing `WHERE user_id = $auth_uid` checks

4. **Webhook signature verification**
   - Stripe, Clerk, Resend webhooks must verify signatures

5. **Input validation gaps**
   - Server-side validation with Zod/Valibot/Yup required

6. **Injection vulnerabilities**
   - SQL injection, XSS, command injection

7. **Rate limiting**
   - Auth, payment, LLM endpoints

8. **Client-trusted data**
   - Prices, amounts, roles accepted from client

9. **Verbose error messages**
   - Stack traces leaked in production

10. **Dependency risks**
    - Typosquatted or hallucinated packages

For each finding, provide: file:line, severity, exploit scenario, fix.

## Phase: pre-launch

Pre-launch audit checklist:

**Security (24 hours before):**
- SAST scan (Semgrep)
- Dependency scan (npm audit)
- Secrets scan (gitleaks)
- Manual IDOR walkthrough
- Bundle inspection
- 30 minutes adversarial testing

**Functionality:**
- Every homepage CTA works
- Full user journey works
- Payment works
- Account deletion works
- Email delivery works
- Error states render gracefully
- Works on mobile Safari and Chrome Android

**Legal & Ops:**
- Privacy policy live
- Terms of service live
- Cookie consent if needed
- GDPR process exists
- Support email monitored
- Database backup scheduled
- Incident response plan documented

## The 14 Most Common Vulnerabilities

1. RLS disabled or `USING (true)` on user tables
2. Hardcoded API keys or keys behind `NEXT_PUBLIC_*`
3. IDOR - auth checked but not ownership
4. Service-role key in client code
5. Webhooks without signature verification
6. Client-trusted prices/amounts
7. No rate limiting on auth/payment/LLM endpoints
8. Verbose error messages in production
9. Missing server-side input validation
10. Open redirects via unvalidated parameters
11. Admin endpoints with UI-only protection
12. No soft deletes (GDPR exposure)
13. Hallucinated/typosquatted dependencies
14. Missing security headers (CSP, HSTS)
```

---

### FILE: ~/.claude/settings.json

If file doesn't exist, create it. If it exists, merge the `SessionStart` hook.

```json
{
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
```

---

### FILE: install.sh (Offline Installer)

Save as `install.sh` in bundle root:

```bash
#!/bin/bash
# Offline installer — no network. Copies bundled skills + hook, registers SessionStart.
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
T="$HOME/.claude"
mkdir -p "$T/skills/project-init" "$T/skills/webcoded-audit" "$T/hooks"

cp "$DIR/skills/project-init/SKILL.md"   "$T/skills/project-init/"
cp "$DIR/skills/webcoded-audit/SKILL.md" "$T/skills/webcoded-audit/"
cp "$DIR/hooks/project-auto-init.sh"     "$T/hooks/"
chmod +x "$T/hooks/project-auto-init.sh"

# Merge SessionStart hook into settings.json
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
```

---

### FILE: install.ps1 (Windows Offline Installer)

```powershell
# Offline installer (Windows)
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
```

---

## How It Works

### Session Start Flow

```
1. Open any project in Claude Code
          ↓
2. SessionStart hook triggers
          ↓
3. project-auto-init.sh runs:
   - Checks/installs skills (if online)
   - Checks OpenSpec → inits if missing
   - Checks Graphify → builds if missing
   - Checks CLAUDE.md → creates if missing
   - Detects web project → shows checklist
   - Shows deployment checklist
          ↓
4. Claude Code ready with full context
```

### What Gets Created Per Project

```
your-project/
├── openspec/                ← spec-driven development
│   ├── changes/             ← feature proposals
│   └── config.yaml
├── graphify-out/            ← knowledge graph
│   ├── graph.json           ← queryable
│   ├── graph.html           ← visual
│   └── GRAPH_REPORT.md      ← insights
└── CLAUDE.md                ← project context + security rules
```

---

## Usage

### Available Commands

| Command | What It Does |
|---------|--------------|
| `/project-init` | Full project setup |
| `/webcoded-audit` | Security audit |
| `/webcoded-audit pre-launch` | Pre-launch checklist |
| `/graphify .` | Build/rebuild knowledge graph |
| `/graphify query "..."` | Query your codebase |
| `/opsx:propose "feature"` | Start spec-driven feature |
| `/opsx:apply` | Implement tasks from proposal |
| `/ug` | Toggle Caveman mode (65% token savings) |

### Typical Workflow

1. **Start new feature:**
   ```
   /opsx:propose "add user authentication"
   ```

2. **Review proposal** in `openspec/changes/add-user-authentication/`

3. **Implement** when specs approved:
   ```
   /opsx:apply
   ```

4. **Query codebase:**
   ```
   /graphify query "how does auth connect to database?"
   ```

5. **Before deploy:**
   ```
   /webcoded-audit pre-launch
   ```

---

## Web vs Local

| | Local CLI | Web (claude.ai/code) |
|--|-----------|----------------------|
| `~/.claude/` | **Persists** on disk | **Wiped** every session |
| Solution | Install once → works forever | Commit `.claude/` to repo |

### For Web Sessions

Commit these to your repo:

```
your-repo/
└── .claude/
    ├── hooks/
    │   └── project-auto-init.sh
    ├── skills/
    │   ├── project-init/SKILL.md
    │   └── webcoded-audit/SKILL.md
    └── settings.json
```

Then every web session of that repo auto-inits.

---

## Troubleshooting

### "openspec: command not found"
```bash
npm install -g @fission-ai/openspec@latest
```

### "graphify: command not found"
```bash
pip install graphifyy
# Add to PATH: export PATH="$HOME/.local/bin:$PATH"
```

### Hook not running
Check settings.json has SessionStart registered:
```bash
cat ~/.claude/settings.json | grep SessionStart
```

### Skills not showing up
Restart Claude Code after installing. Skills load at startup.

### Web session doesn't have tools
Web containers are ephemeral. Commit `.claude/` folder to your repo so it survives the fresh clone each session.

### Graphify build fails
Usually means no code files to index. Add some code first, then run:
```bash
graphify .
```

---

## Links

- OpenSpec: https://github.com/Fission-AI/OpenSpec
- Graphify: https://github.com/safishamsi/graphify
- Caveman: https://github.com/JuliusBrussee/caveman
- Webcoded Playbook: Based on OWASP Top 10, WCAG 2.2 AA, Core Web Vitals

---

## Summary

1. **Install tools** (one time, needs internet):
   ```bash
   npm install -g @fission-ai/openspec@latest
   pip install graphifyy
   curl -fsSL https://raw.githubusercontent.com/JuliusBrussee/caveman/main/install.sh | bash
   ```

2. **Install skills** (offline bundle or copy files manually)

3. **Open any project** → hook auto-runs → everything configured

4. **Use commands:**
   - `/project-init` - setup
   - `/webcoded-audit` - security
   - `/graphify query` - knowledge
   - `/opsx:propose` - specs

Done.
