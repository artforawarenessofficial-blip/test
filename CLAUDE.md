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
