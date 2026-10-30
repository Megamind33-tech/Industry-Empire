# Transport Empire roadmap

The engine stays OpenTTD 14.1 (Android). The game's look and identity are replaced. Each phase lands as its own commit.

| Phase | Work | Status |
| --- | --- | --- |
| 1. Identity | Rename to Transport Empire, remove OpenTTD branding from the UI, give the app a new package ID (`com.transportempire.game`), rename subsidies to contracts | Done (English strings only) |
| 2. Economy | Start with 20,000 cash, 50,000 loan limit | Done |
| 2b. Economy | Start with one free car, a government and business contract board, and a spending breakdown on the HUD | Planned |
| 3. Art pipeline | Blender and Unreal (headless, offline) rendered to 32bpp isometric sprites, tiered by phone. See `docs/VISUAL_PIPELINE.md` | Planned |
| 4. World life | Animated pedestrians, traffic, smoke, water, a day and night tint | Planned |
| 5. UI and HUD | A new skin, a mobile-first toolbar, a money and contracts HUD | Planned |
| 6. Modes | PvP lobby and PvAI presets built on the existing multiplayer and AI | Planned |

Notes:
- The About window keeps "Based on OpenTTD (c) The OpenTTD team". GPL-2.0 requires that copyright notice.
- The Coastal Valley scenario was saved with the old loan settings. It will be regenerated in phase 2b.
- Translations other than English still say OpenTTD.
