# Commercial compliance

This is an engineering record, not a law-firm opinion. Unresolved items are marked open.

## What may be distributed

- OpenTTD and this port's GPL-2.0 code may be sold or given away if recipients get the GPL-2.0 text and corresponding source. This repository names the exact upstream commits and carries the Industry Empire patches.
- OpenGFX 7.1 and OpenMSX 0.4.2 are GPL-2.0.
- OpenSFX 1.0.3 is CC BY-SA 3.0. Attribution is in `THIRD_PARTY_NOTICES.md`. Derivatives of those sounds must stay under CC BY-SA 3.0. The sound pack is shipped unchanged.
- The launcher icon in `patches/` and the Android tree is original artwork for this release and is covered by GPL-2.0 with the rest of the application resources.
- No original Transport Tycoon Deluxe graphics, sounds, or music are included.

## Identity

The launcher name and main-menu title are Industry Empire. The in-game About window still says OpenTTD and names the OpenTTD team and Chris Sawyer's original copyright. That is intentional.

## Open items

- The APK is signed with the Android debug keystore. It is installable. It is not a Play App Signing upload. A release keystore was not created and must not be committed.
- Package id remains `org.openttd.sdl` because the Android port generates Java from that id. A store listing should not imply that the OpenTTD project publishes this package.
- OpenGFX2 was not integrated. Its high-resolution set is incomplete and was not audited sprite by sprite. Shipping a mixed, untested graphics set would risk missing sprites.
- New building, vehicle, and terrain art was not produced. The visible world is OpenGFX 7.1.
- CC BY-SA sound inside a GPL-2.0 APK is distributed as a separate base-set archive with its own licence file. If a store requires a single outbound licence, get advice before listing. Do not strip the OpenSFX licence.
