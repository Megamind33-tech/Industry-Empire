# Quick Start and the 6,144 towns

OpenTTD does not store a fixed town count for the Normal, Low, and High settings. It scales a small base by the map area. The base for Normal is 23 plus a random 0–7. On a 256×256 map that is a few dozen towns. On a 4096×4096 map the same Normal setting is 5,888–7,680 towns. 6,144 is that formula with a random add of 1:

`ceil(24 << (12 + 12 - 12) / 16) = 6144`

The generation window prints that number under "Town generation" as `current / total`. It is the number of towns being placed, not a separate bug in the counter.

Quick Start ignores the saved map size and always uses:

- 256×256 temperate map
- Low town density, about 15 towns
- Normal industries
- Hilly terrain and high terrain variety, using the existing OpenGFX sprites
- No rival companies and no vehicle breakdowns
- Year 1950
- The First Route game script

World Generation is still on the main menu. If the chosen settings would place more than about 150 towns, the game asks before it starts. The town dropdown shows the estimate, for example `Normal (about 6144 towns)` on a 4096 map.

The tutorial is a game script in the APK at `game/industry-empire-tutorial`. It opens a story page and two goals: buy a bus, then earn passenger income. Skip tutorial and Replay tutorial are buttons on that page. Starting Quick Start again also starts a new tutorial game.

An upgrade deletes the previous `openttd.cfg` so an old 4096×4096 setting does not come back. Saved games are left in place.

OpenGFX2 and newly rendered building sprites are not in this build. High terrain variety is the OpenTTD setting that reduces obvious grass repetition with the sprites already in OpenGFX 7.1.

APK SHA-256: `7f16396f265865d6d112774aae02e7773c2dda652c72c8e7dc16be4177d05bfb`
