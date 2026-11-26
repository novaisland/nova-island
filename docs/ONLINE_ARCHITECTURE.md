# NOVA ISLAND — Online MMORPG foundation

## Product direction
NOVA ISLAND is an original tropical pixel-art life-simulation adventure. It can take inspiration from broad genre systems (farming, gathering, crafting, quests, land ownership, social play and trading), but uses original code, art, maps, names, UI and game economy.

## Current implementation status
- The playable Alpha 0.1 is still a static browser game.
- GitHub Pages serves the client; it does not provide authentication, a database or multiplayer servers.
- This commit adds the first Supabase database foundation for player profiles and private cloud saves.
- No account flow is connected to the game yet. No live multiplayer, player trading, payments, NFTs or token rewards are active.
- Existing localStorage saves are not automatically uploaded or migrated by this schema.

## Target architecture
- Client: responsive browser game; later split into maintainable modules and original asset packs.
- Identity and database: Supabase Auth + PostgreSQL with Row Level Security.
- Realtime: Supabase Realtime for presence, chat and room updates after the account flow is tested.
- Trusted game logic: Supabase Edge Functions / PostgreSQL RPCs for energy costs, gathering, crafting, harvesting, quest rewards and trades. The browser must not be trusted to mint currency or items.
- Hosting: GitHub Pages can continue to host the static client; a separate backend handles online state.
- Later: moderation, reporting, rate limits, backups, observability and anti-bot controls before public multiplayer.

## Database setup
1. Create a Supabase project.
2. Open SQL Editor in the project dashboard.
3. Paste and run supabase/schema.sql.
4. In Project Settings → API, copy the Project URL and the publishable/anon key.
5. Never expose or send the service_role secret. It must only be used in a trusted server environment.
6. The client integration will be enabled only after the project URL and publishable key are configured.

## Security notes
- Row Level Security is enabled on both initial tables.
- Players can read/update only their own cloud save.
- Public profile fields are readable; a player can update only their own display name/avatar key.
- A cloud save is a backup/synchronization payload, not an authoritative economy record. Never award tradable items or currency based only on client-submitted JSON.
- Public trading and persistent shared-world features require server-authoritative functions and abuse controls before release.

## Delivery phases
1. Backend project + schema + auth integration.
2. Account UI, cloud-save sync and safe local-save migration.
3. Server-authoritative inventory, energy, crafting, farming and quest progression.
4. Shared island rooms, presence, player profiles and chat with moderation.
5. Player-owned plots, visits, market listings and atomic trade settlement.
6. Content expansion, mobile performance, accessibility, automated tests and release hardening.

A phase is not considered complete until it is deployed and tested in a real browser/device.
