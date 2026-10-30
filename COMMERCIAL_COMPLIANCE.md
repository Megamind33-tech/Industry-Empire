# Commercial compliance

This is an engineering record, not a law-firm opinion. Unresolved items are marked open.

## What may be distributed

- OpenTTD and this port's GPL-2.0 code may be sold or given away if recipients get the GPL-2.0 text and corresponding source. This repository names the exact upstream commits and carries the Transport Empire patches.
- OpenGFX 7.1, OpenGFX2 Classic 0.8.1, and OpenMSX 0.4.2 are GPL-2.0. OpenGFX2 High Def is the same licence and is not in the APK because of its size. See `docs/GRAPHICS.md`.
- OpenSFX 1.0.3 is CC BY-SA 3.0. Attribution is in `THIRD_PARTY_NOTICES.md`. Derivatives of those sounds must stay under CC BY-SA 3.0. The sound pack is shipped unchanged.
- The launcher icon in `patches/` and the Android tree is original artwork for this release and is covered by GPL-2.0 with the rest of the application resources.
- No original Transport Tycoon Deluxe graphics, sounds, or music are included.

## Identity

The launcher name and main-menu title are Transport Empire. The in-game About window still says OpenTTD and names the OpenTTD team and Chris Sawyer's original copyright. That is intentional.

## Open items

- The APK is signed with the Android debug keystore. It is installable. It is not a Play App Signing upload. A release keystore was not created and must not be committed.
- Package id remains `org.openttd.sdl` because the Android port generates Java from that id. A store listing should not imply that the OpenTTD project publishes this package.
- OpenGFX2 High Def was not integrated. The uncompressed set is about 383 MB and was not loaded in a running game. Classic 0.8.1 was loaded and is the default art. OpenGFX 7.1 remains selectable.
- No new building, vehicle, or terrain sprites were drawn for this release. The visible change is the OpenGFX2 Classic baseset plus the Coastal Valley scenario.
- CC BY-SA sound inside a GPL-2.0 APK is distributed as a separate base-set archive with its own licence file. If a store requires a single outbound licence, get advice before listing. Do not strip the OpenSFX licence.
