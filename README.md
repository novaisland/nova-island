# NOVA ISLAND

A tropical pixel-art island adventure and life-simulation browser game.

## Run
Open `index.html` in a browser. To publish with GitHub Pages: Settings → Pages → Deploy from a branch → select `nova-island-development` → `/ (root)`.

## Alpha 0.1 features
- Responsive pixel-art island canvas.
- Keyboard (WASD/arrows) and mobile touch joystick.
- Gathering wood, stone, berries and fiber.
- Fishing pond and NPC interaction with welcome gift.
- Day/night clock, energy and health HUD.
- Inventory, quests, coin rewards and XP/level progression.
- Crafting recipes, house/camp/farm building.
- Planting and harvesting crops.
- Local autosave and manual save with browser localStorage.

## Controls
Move: WASD / arrow keys / joystick. Interact: E / AKSI. Gather: Space / AMBIL. Menus: bottom navigation.

## Scope
The current playable build remains an offline alpha. Online MMORPG systems are being developed in phases. The first Supabase database schema for player profiles and private cloud saves is in supabase/schema.sql; setup and security notes are in docs/ONLINE_ARCHITECTURE.md. Accounts are not connected to the game yet, and live multiplayer, server-authoritative economy, trading, payments and blockchain features are not implemented. Existing saves remain local until a tested migration is added.
