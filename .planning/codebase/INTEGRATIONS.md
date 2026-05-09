# External Integrations

**Analysis Date:** 2026-05-09

## APIs & External Services

**None detected** - This is a standalone Flutter application with no external API integrations currently implemented.

## Data Storage

**Local SQLite Database:**
- `lib/UTS.db` - SQLite database file (81,920 bytes)
- Schema includes: `systems`, `attribute_definitions`, `tags` tables
- Seeds: 6 TTRPG systems (D&D 5e, Pathfinder 2e, Call of Cthulhu, Vampire: The Masquerade, Cyberpunk Red, Warhammer Fantasy Roleplay)

**SQL Files:**
- `lib/uts_data.sql` - Base schema and seed data
- `lib/UTS.sql` - Additional schema definitions
- `lib/ttrpg_data/*.sql` - Game-specific data:
  - `call_of_cthulhu.sql`
  - `cyberpunk_red.sql`
  - `dnd5e.sql`
  - `pathfinder2e.sql`
  - `vampire_masquerade.sql`
  - `warhammer_fantasy.sql`

**ORM/Client:**
- Not detected - Likely using raw SQLite or a minimal database wrapper

## Authentication & Identity

**Auth Provider:** None
- No Firebase, Supabase, or custom auth implementation detected

## Monitoring & Observability

**Error Tracking:** None
- No Sentry, Crashlytics, or similar error tracking services

**Logs:**
- Console logging only (default Flutter debug output)

## CI/CD & Deployment

**Hosting:** None configured
- No Firebase Hosting, Vercel, or similar web hosting

**CI Pipeline:** None detected
- No GitHub Actions, CircleCI, or similar CI configuration

## Environment Configuration

**Required env vars:** None
- No environment variables currently used

**Secrets location:** N/A
- No secrets management system in use

## Webhooks & Callbacks

**Incoming:** None
**Outgoing:** None

---

*Integration audit: 2026-05-09*