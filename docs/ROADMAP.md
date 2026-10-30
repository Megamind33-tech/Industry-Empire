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

## How we beat the competition

Competitors have bigger budgets and prettier trailers. We win on the things they don't do on a phone.

1. **A founder's story, not a sandbox.** You start as one person with one used car running taxi fares. Each step up is earned and shown: courier van, first bus line, freight trucks, rail, port and air, then offices in other countries. Each era unlocks with **reputation** as well as cash, so it feels like a career.
2. **A tender board instead of handed-out subsidies.** Governments post tenders (school buses, mine haulage, port contracts) with deadlines, service levels and penalties. Players and AI rivals bid against each other. In PvP, bidding wars are the heart of the competition.
3. **Money you can see.** Fares, fuel, wages and repairs float off vehicles as small +/− amounts on the map. A weekly "Where your money went" card breaks down spending. Fuel prices move with the economy, so realistic costs are a decision, not a hidden number.
4. **Real operations.** Hire drivers and mechanics with wages, buy fuel, take out insurance, and handle breakdowns with tow trucks. Weather has effects: snow slows rail, sandstorms close desert roads, rush hours change demand.
5. **A living world that reacts to you.** Town mood shows in speech bubbles and a news ticker. Rivals put up billboards. Industries visibly grow when you serve them well and decline when you don't.
6. **Profit Lens.** One tap overlays demand and profit heatmaps on the map and suggests the next route. It's made for mobile players who don't want to read spreadsheets.
7. **One-thumb building.** Drag a finger from town to town and the game proposes the road, stops and depot with a price tag before you confirm.
8. **PvAI rivals with personalities:** the Monopolist (buys up your towns), the Budget King (undercuts your fares), and the Green Operator (wins eco tenders). PvP adds seasons, leagues and hostile takeovers through shares.
9. **Photo mode.** The 4x rendered sprites make strong screenshots. A share card with company stats becomes free marketing.
10. **Going multinational.** A world meta-map where each country is a region map with its own currency, rules and rivals. Your HQ network becomes the endgame.
