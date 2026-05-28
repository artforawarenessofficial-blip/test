# Project Init Skill

Automatically initialize a new project with spec-driven development, knowledge graphs, and security best practices.

## Usage

Invoke with: `/project-init` or `/project-init [options]`

Options:
- `--full` - Complete setup (default)
- `--openspec-only` - Only initialize OpenSpec
- `--graphify-only` - Only initialize Graphify
- `--audit-only` - Only set up security audit rules

---

## What This Skill Does

When invoked, this skill sets up three critical workflows for any AI-coded project:

### 1. OpenSpec - Spec-Driven Development
Ensures you agree on WHAT to build before writing code.

### 2. Graphify - Knowledge Graph
Maps your entire codebase into a queryable knowledge graph.

### 3. Webcoded Audit - Security & Quality
Applies the 14-point security checklist for AI-built apps.

---

## Instructions

### Step 1: Check Prerequisites

First, verify the tools are installed:

```bash
# Check OpenSpec
openspec --version || echo "OpenSpec not installed"

# Check Graphify  
graphify --version || echo "Graphify not installed"
```

If not installed, provide installation commands:

```bash
# Install OpenSpec (requires Node.js 20.19+)
npm install -g @fission-ai/openspec@latest

# Install Graphify (requires Python 3.10+)
uv tool install graphifyy
# or: pipx install graphifyy
# or: pip install graphifyy
```

### Step 2: Initialize OpenSpec

Run OpenSpec initialization:

```bash
openspec init
```

This creates the `openspec/` directory structure for spec-driven development.

After initialization, the project gains these workflows:
- `/opsx:propose "feature"` - Create a change proposal with specs, design, and tasks
- `/opsx:apply` - Implement the tasks from a proposal
- `/opsx:archive` - Archive completed changes
- `/opsx:verify` - Verify implementation matches specs

### Step 3: Initialize Graphify

Install the Graphify skill and build the initial knowledge graph:

```bash
# Install skill for your AI assistant
graphify install

# Build the initial graph
graphify .
```

This creates `graphify-out/` with:
- `graph.html` - Interactive visualization
- `GRAPH_REPORT.md` - Key concepts and connections
- `graph.json` - Queryable graph data

After initialization, the project gains these commands:
- `/graphify .` - Rebuild the knowledge graph
- `/graphify query "question"` - Query the codebase
- `/graphify path "A" "B"` - Find connections between concepts
- `/graphify explain "concept"` - Explain a component

### Step 4: Set Up Security Hooks

Create or update CLAUDE.md with security rules:

```markdown
## Security Rules — Non-Negotiable

- Never put secrets in client-bundled code (`NEXT_PUBLIC_*`, `VITE_*`, etc.)
- Never use Supabase `service_role` key outside server-only code
- Every new table must have Row Level Security enabled with explicit policies
- Every API route must check BOTH authentication AND authorization for the specific resource
- Every webhook must verify provider signatures before any logic
- Validate all input server-side with a schema library (Zod/Valibot/Yup)
- Use parameterized queries only — never string-concatenate SQL
- No `dangerouslySetInnerHTML` unless sanitized with DOMPurify

## Never Do

- Never commit `.env*` files (only `.env.example`)
- Never trust prices, IDs, roles, or user_ids from the client
- Never disable RLS to "fix" a permission error
- Never add dependencies without verifying they exist on npm and are maintained
- Never skip webhook signature verification
```

### Step 5: Create Pre-Commit Hook (Optional)

Set up automatic graph rebuilding and secret scanning:

```bash
# Install graphify hooks (auto-rebuild on commit)
graphify hook install

# Add secret scanning (requires gitleaks)
# brew install gitleaks  # macOS
# or download from https://github.com/gitleaks/gitleaks
```

### Step 6: Verify Setup

Run verification:

```bash
# Verify OpenSpec
ls openspec/ 2>/dev/null && echo "✓ OpenSpec initialized" || echo "✗ OpenSpec not found"

# Verify Graphify
ls graphify-out/ 2>/dev/null && echo "✓ Graphify initialized" || echo "✗ Graphify not found"

# Verify CLAUDE.md has security rules
grep -q "Security Rules" CLAUDE.md 2>/dev/null && echo "✓ Security rules in CLAUDE.md" || echo "✗ Security rules not found"
```

---

## Complete Initialization Script

For a one-shot full initialization, run:

```bash
#!/bin/bash
set -e

echo "=== Project Init: Setting up spec-driven development ==="

# 1. Initialize OpenSpec
if command -v openspec &> /dev/null; then
    echo "Initializing OpenSpec..."
    openspec init
    echo "✓ OpenSpec initialized"
else
    echo "⚠ OpenSpec not installed. Run: npm install -g @fission-ai/openspec@latest"
fi

# 2. Initialize Graphify
if command -v graphify &> /dev/null; then
    echo "Installing Graphify skill..."
    graphify install
    echo "Building knowledge graph..."
    graphify .
    echo "Installing git hooks..."
    graphify hook install
    echo "✓ Graphify initialized"
else
    echo "⚠ Graphify not installed. Run: uv tool install graphifyy"
fi

# 3. Update .gitignore
if [ -f .gitignore ]; then
    grep -q "graphify-out/manifest.json" .gitignore || echo -e "\n# Graphify\ngraphify-out/manifest.json\ngraphify-out/cost.json" >> .gitignore
fi

echo "=== Project Init Complete ==="
echo ""
echo "Available workflows:"
echo "  /opsx:propose \"feature\" - Start spec-driven development"
echo "  /graphify .              - Rebuild knowledge graph"
echo "  /graphify query \"...\"   - Query the codebase"
echo "  /webcoded-audit security - Run security audit"
```

---

## Recommended Workflow After Init

1. **Start with a spec** (OpenSpec):
   ```
   /opsx:propose "add user authentication"
   ```

2. **Review the proposal** in `openspec/changes/add-user-authentication/`

3. **Implement** when specs are approved:
   ```
   /opsx:apply
   ```

4. **Query the codebase** (Graphify):
   ```
   /graphify query "how does auth connect to the database?"
   ```

5. **Before shipping**, run security audit:
   ```
   /webcoded-audit pre-launch
   ```

6. **Archive** completed changes:
   ```
   /opsx:archive
   ```

---

## Project Structure After Init

```
your-project/
├── .claude/
│   └── skills/
│       └── webcoded-audit.md    # Security audit skill
├── openspec/
│   ├── changes/                 # Active change proposals
│   │   └── archive/             # Completed changes
│   └── config.yaml              # OpenSpec configuration
├── graphify-out/
│   ├── graph.html               # Interactive visualization
│   ├── graph.json               # Queryable graph
│   └── GRAPH_REPORT.md          # Key insights
├── CLAUDE.md                    # AI assistant instructions
├── .env.example                 # Environment template
└── .gitignore                   # Updated with tool outputs
```

---

## The Three Pillars

| Pillar | Tool | Purpose |
|--------|------|---------|
| **Plan** | OpenSpec | Agree on WHAT before coding |
| **Understand** | Graphify | Query the codebase, find connections |
| **Verify** | Webcoded Audit | Security & quality checks |

---

## Quick Reference

### OpenSpec Commands
| Command | Description |
|---------|-------------|
| `/opsx:propose "idea"` | Create change proposal |
| `/opsx:apply` | Implement tasks |
| `/opsx:verify` | Check implementation |
| `/opsx:archive` | Archive completed change |
| `/opsx:onboard` | Generate onboarding docs |

### Graphify Commands
| Command | Description |
|---------|-------------|
| `/graphify .` | Build/rebuild graph |
| `/graphify query "..."` | Query the codebase |
| `/graphify path "A" "B"` | Find connections |
| `/graphify explain "X"` | Explain a concept |
| `/graphify . --update` | Update changed files only |

### Webcoded Audit Phases
| Phase | Description |
|-------|-------------|
| `security` | Full security audit |
| `rls` | Row Level Security check |
| `secrets` | Secrets scan |
| `auth` | Auth/authz verification |
| `pre-launch` | Launch checklist |

---

## Why This Matters

AI coding assistants optimize for "code that runs", not "code that's safe to ship". This skill ensures:

1. **You agree before you build** — OpenSpec specs prevent scope creep and miscommunication
2. **You can query, not grep** — Graphify lets you ask questions about your codebase
3. **You catch the 14 common vulnerabilities** — Webcoded Audit covers what AI-coded apps get wrong

Ship boldly. Audit ruthlessly.
