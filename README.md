# Firefox Min UI v0.16 beta

Single-line Firefox UI with an expanding address field, native navigation buttons and extension buttons.

## Fix in v0.16

Opening the address bar now places the native Firefox navigation toolbar across the complete top row, **over** the invisible tab strip. The toolbar is anchored to the left edge and stops just before the native window buttons; the address field flexes to fill the remaining center area. This removes the old half-width limitation caused by the tab-strip retaining layout space. All native buttons stay in place.

The internal caption area width is measured at runtime to account for scaling and theme differences.

## Installation / Upgrade

1. Close every Firefox window.
2. Run `Firefox-MinUI-Installer-v016.cmd` as administrator.
3. Select Firefox and the same profile used for v0.15. Choose **Install / Update**.
4. Reopen Firefox, click the active tab, and verify the address field fills most available width with back/forward/reload on the left and extensions/menu on the right.
5. Close Firefox, run **Diagnostics**, and check the v16 trace and layout status.
6. Use **Uninstall / Restore** in the same installer if needed.

## Safety and limitations

This is **experimental privileged browser UI customization**, not an official extension. It modifies Firefox's AutoConfig installation and may break after a Firefox update. It does not globally disable browser security. Backups and an uninstall path are included. Test in a separate profile before sharing publicly. Functional behavior on the user's Windows Firefox installation has not yet been verified.

Source: https://github.com/mudot

Independent project, not affiliated with Mozilla or Min Browser.

## Development test

The project includes a visual layout harness in `tests/test_layout.py`. It requires Python, Playwright and a Chromium browser in the development environment. Run it separately; the Windows installer does not require these tools. This harness uses a structural approximation of Firefox's toolbar, not a live Firefox session.
