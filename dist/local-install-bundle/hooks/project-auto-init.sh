#!/bin/bash
set -euo pipefail

# Only run in Claude Code on the web (remote environment)
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

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
if [ -d "$HOME/.claude/skills/caveman" ] || command -v caveman &>/dev/null; then
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
