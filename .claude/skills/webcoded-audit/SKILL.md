---
name: webcoded-audit
description: Audit AI-built web apps for security and quality issues covering the 14 most common vulnerabilities (RLS, IDOR, secrets, auth, webhooks, input validation). Use when the user wants a security audit, pre-launch checklist, accessibility check, or performance review of a web application.
---

# Webcoded App Audit Skill

A comprehensive audit skill for AI-built web apps, based on the Webcoded App Playbook.

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

---

## Phase: security

Run a comprehensive security audit covering the 14 most common vulnerabilities in AI-coded apps.

### Instructions

Act as a senior application security engineer. Audit this codebase for the following vulnerability classes, in priority order:

1. **Hardcoded secrets and client-bundled secrets**
   - Search for API keys, tokens, passwords in code
   - Check for secrets behind `NEXT_PUBLIC_`, `VITE_`, `PUBLIC_`, `REACT_APP_`, `EXPO_PUBLIC_`
   - Verify `.env` files are gitignored

2. **Row Level Security misconfigurations** (if using Supabase/Firebase)
   - Tables with RLS disabled
   - Policies using `USING (true)` or `WITH CHECK (true)` on user data
   - Service role key used in client code

3. **IDOR / Broken Object Level Authorization**
   - API routes that check authentication but not resource ownership
   - Endpoints returning data based on user-supplied IDs without ownership verification
   - Missing `WHERE user_id = $auth_uid` checks

4. **Webhook signature verification**
   - Stripe, Clerk, Resend, Twilio webhooks must verify signatures
   - Check for signature verification before any business logic

5. **Input validation gaps**
   - Server-side validation with Zod/Valibot/Yup required
   - Client-side validation is UX only, not security

6. **Injection vulnerabilities**
   - SQL injection via string concatenation
   - XSS via `dangerouslySetInnerHTML`, `v-html`, `[innerHTML]`
   - Command injection

7. **Rate limiting**
   - Auth endpoints (login, signup, password reset)
   - Payment endpoints
   - LLM-backed endpoints

8. **Client-trusted data**
   - Prices, amounts, roles, user_ids accepted from client
   - Admin endpoints protected by UI hiding only

9. **Verbose error messages**
   - Stack traces, SQL queries, filesystem paths leaked in production

10. **Dependency risks**
    - Typosquatted or hallucinated packages
    - Unmaintained dependencies with known vulnerabilities

For each finding, provide:
- File and line number
- Severity (Critical/High/Medium/Low)
- Exploit scenario
- Concrete fix

---

## Phase: init

Generate a CLAUDE.md file for this repository.

### Instructions

Read every file in this repo. Generate a `CLAUDE.md` at the root covering:

1. **Project overview** - What it is, who uses it, success metric
2. **Tech stack** - Framework, runtime, DB, auth, payments, hosting with versions
3. **Folder structure** - Where business logic, API routes, components, tests live
4. **Commands** - Every npm/pnpm script with description
5. **Code style** - Language, formatter, naming conventions, file-size limits
6. **Testing** - Framework, location, coverage requirements
7. **Security rules** - Non-negotiable security requirements
8. **Never do** - Explicit anti-patterns for this codebase

Keep under 180 lines. Output as one markdown file.

Security rules to include:
```
- Never put secrets in client-bundled code
- Never use service_role key outside server-only code
- Every new table must have RLS enabled with explicit policies
- Every API route must check ownership, not just authentication
- Every webhook must verify provider signatures
- Validate all input server-side with a schema library
- Use parameterized queries only
```

---

## Phase: rls

Audit Row Level Security policies for Supabase/Postgres.

### Instructions

1. List all tables and their RLS status:
   ```sql
   SELECT tablename, rowsecurity FROM pg_tables WHERE schemaname = 'public';
   ```

2. For each table with user data, verify:
   - RLS is enabled (`rowsecurity = true`)
   - At least one policy exists
   - No policy uses `USING (true)` unless genuinely public data
   - UPDATE policies have `WITH CHECK` preventing ownership changes
   - No inverted policies (anonymous can read, authenticated can't)

3. Check that `service_role` key is server-only:
   - Grep client bundles for "service_role"
   - Verify it's not in any `NEXT_PUBLIC_*` or `VITE_*` variable

4. Verify storage bucket policies are private by default

Report findings with severity and fix recommendations.

---

## Phase: secrets

Scan for exposed secrets.

### Instructions

1. **Check git history:**
   ```bash
   git log --all -p | grep -iE "(api[_-]?key|secret|token|password|bearer|sk_live|sk_test)"
   ```

2. **Check environment variable prefixes:**
   - Grep for `NEXT_PUBLIC_`, `VITE_`, `PUBLIC_`, `REACT_APP_`, `EXPO_PUBLIC_`
   - Verify none contain: API keys, Stripe secrets, Supabase service_role, database URLs

3. **Verify .env handling:**
   - `.env*` in `.gitignore` (except `.env.example`)
   - `.env.example` has names only, no values

4. **Check for hardcoded values:**
   - Strings matching key patterns (sk_, pk_, Bearer, API)
   - Database connection strings
   - AWS/GCP/Azure credentials

If any secrets found in history: **ROTATE THE KEY** - deleting the commit is not enough.

---

## Phase: auth

Audit authentication and authorization.

### Instructions

**Authentication checks:**
- [ ] Using managed auth provider (Clerk, Supabase Auth, Auth0, NextAuth)
- [ ] Passwords hashed with bcrypt (cost >= 10), argon2id, or scrypt
- [ ] Session cookies are HttpOnly, Secure, SameSite=Lax
- [ ] JWT expiration <= 1 hour, refresh tokens rotated
- [ ] Rate limiting on auth endpoints (5 attempts per 15 min)
- [ ] No account enumeration (same response for "no user" and "wrong password")
- [ ] Logout destroys session server-side

**Authorization checks (where AI fails most):**
- [ ] Every API route checks BOTH authenticated AND authorized for specific resource
- [ ] Ownership verified: `WHERE id = $1 AND user_id = $auth_uid`
- [ ] Admin routes have server-side role check, not just hidden UI
- [ ] IDs are UUIDs/nanoIDs, not sequential integers
- [ ] Role fields (is_admin, role, plan) cannot be set via user endpoints

**Manual IDOR test:**
1. Log in as user A
2. Copy a URL with a resource ID
3. Open as user B
4. Confirm 403 or 404, not the resource

---

## Phase: pre-launch

Pre-launch audit checklist.

### Instructions

Run through this checklist before launching:

**Security (24 hours before):**
- [ ] SAST scan (Semgrep `--config=auto`) - review all findings
- [ ] Dependency scan (`npm audit`) - fix critical/high
- [ ] Secrets scan over git history (`gitleaks detect --log-opts="--all"`)
- [ ] Manual IDOR walkthrough with two test users
- [ ] Bundle inspection for leaked secrets
- [ ] 30 minutes of adversarial testing

**Functionality:**
- [ ] Every homepage CTA works
- [ ] Full user journey: signup -> onboarding -> main action -> logout
- [ ] Payment works (test mode, then live mode)
- [ ] Account deletion really deletes
- [ ] Email delivery works (check Gmail, Outlook, iCloud)
- [ ] Error states render gracefully (404, 500, offline)
- [ ] Works on mobile Safari and Chrome Android

**Legal & Ops:**
- [ ] Privacy policy live and linked
- [ ] Terms of service live and linked
- [ ] Cookie banner if needed
- [ ] GDPR data access/deletion process exists
- [ ] Support email monitored
- [ ] Database backup scheduled
- [ ] Incident response plan documented

---

## Phase: a11y

Accessibility audit for WCAG 2.2 AA compliance.

### Instructions

Audit against WCAG 2.2 AA requirements:

- [ ] Semantic HTML (`<button>`, `<a>`, `<nav>`, `<main>`, proper heading hierarchy)
- [ ] Tab navigation reaches all interactive elements in logical order
- [ ] Focus visible on all elements (contrast >= 3:1)
- [ ] Touch targets >= 24x24px (44x44px recommended)
- [ ] Text contrast >= 4.5:1 normal, >= 3:1 large text
- [ ] Form inputs have programmatic `<label>` associations
- [ ] Errors announced via `aria-invalid`, `aria-describedby`
- [ ] Images have `alt` text (decorative images use `alt=""`)
- [ ] No drag-only interactions (single-pointer alternatives exist)
- [ ] No color-only indicators (icons or text accompany color)
- [ ] Works at 200% zoom without horizontal scroll
- [ ] Keyboard-only navigation works for all critical journeys
- [ ] Skip-to-content link at page top

For each violation report: file:line, WCAG criterion, and minimal fix.

---

## Phase: perf

Performance audit for Core Web Vitals.

### Instructions

Check against 2026 Core Web Vitals thresholds:

| Metric | Good | 
|--------|------|
| LCP (Largest Contentful Paint) | <= 2.5s |
| INP (Interaction to Next Paint) | <= 200ms |
| CLS (Cumulative Layout Shift) | <= 0.1 |
| TTFB | <= 0.8s |

**Checklist:**
- [ ] Lighthouse >= 90 on mobile for homepage and top 3 routes
- [ ] JS bundle <= 400KB gzipped
- [ ] Images: AVIF/WebP, sized correctly, width/height set, lazy-loaded below fold
- [ ] Fonts: `font-display: swap`, preloaded if critical, <= 2 weights
- [ ] Third-party scripts loaded async/deferred
- [ ] No N+1 database queries in list views
- [ ] Database queries indexed for access patterns
- [ ] Static content CDN-cached

Run `EXPLAIN` on the 5 most-hit queries and verify indexes exist.

---

## The 14 Most Common Vulnerabilities

Quick reference for what to look for:

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
