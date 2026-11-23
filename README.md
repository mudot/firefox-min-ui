# Firefox Min UI

**A compact, single-row interface for Firefox.**

Firefox Min UI is an open-source browser UI customization that brings tabs, navigation controls, and the address bar into a single, space-efficient toolbar. Inspired by the interaction patterns of minimalist browsers, it replaces the conventional two-row layout with an address field that expands when you need it.

> **Status: v0.16 beta — experimental software.** Firefox Min UI modifies Firefox's internal interface through privileged AutoConfig scripts. It is not a Firefox extension, is not affiliated with Mozilla or Min Browser, and is not yet validated for general production use.

## Features

- **Single-row toolbar:** combines tabs and native Firefox navigation controls.
- **Expandable address bar:** click the active tab to reveal the address field; the field is designed to use the available space between the native control groups.
- **Native controls:** retains Firefox's back, forward, reload, extension, menu, and window controls rather than recreating their behavior.
- **Subtle transitions:** animated address-bar expansion, with reduced-motion support.
- **Keyboard-friendly navigation:** `Ctrl+L` focuses the address field; `Esc` can dismiss it when the suggestions popup is not open.
- **Responsive fallback:** the custom layout is disabled for narrow windows (below 1,100 CSS pixels), customization mode, and fullscreen conditions handled by the UI script.
- **Collision detection:** attempts to restore the standard toolbar layout if an invalid arrangement is detected.
- **Bilingual Windows installer:** English by default, with a Portuguese (Brazil) option.
- **Diagnostics and rollback:** installer-based status reporting, backups, update handling, and uninstall support.

## How it works

Firefox Min UI moves Firefox's native navigation toolbar into the tab-toolbar area while the custom layout is active. The address bar expands on demand, and the remaining controls continue to use Firefox's own implementation.

The project uses **Firefox AutoConfig and privileged JavaScript**, plus CSS applied to Firefox's internal UI. This offers deeper customization than a normal WebExtension, but also means the project depends on Firefox internals that Mozilla may change at any time.

## Requirements

- Mozilla Firefox installed on **Windows**.
- Permission to modify the Firefox installation directory (administrator access may be required).
- A Firefox profile that you can select in the installer.
- The ability to close all Firefox windows before installation or removal.

The installer uses Windows PowerShell and .NET Windows Forms. No separate `fx-autoconfig` installation is required. The development test tools are **not** required by end users.

> Other operating systems, portable builds, enterprise-managed installations, and future Firefox releases have not been validated for this beta.

## Installation

1. **Back up your Firefox profile** and preferably create a separate testing profile through `about:profiles`.
2. Close **all** Firefox windows.
3. Download `Firefox-MinUI-Installer-v016.cmd` from the project's release files or use the file included in the source package.
4. Review the script before running it. Launch the installer on Windows and approve administrator access if requested.
5. Choose **English** or **Português (Brasil)** at the top of the installer.
6. Select the Firefox installation and the profile to customize.
7. Choose **Install / Update**, then reopen Firefox.
8. Click the currently selected tab or press `Ctrl+L` to test the address-bar interaction.

### Update from an earlier beta

Close Firefox, run the latest installer, select the **same installation and profile**, and choose **Install / Update**. The installer is designed to recognize files from earlier project releases and back up files it changes. If a conflicting or unrecognized AutoConfig file is detected, installation may be refused rather than overwriting it.

## Uninstall / Restore

1. Close all Firefox windows.
2. Run the same installer as administrator.
3. Select the Firefox installation and profile used for setup.
4. Choose **Uninstall / Restore**.
5. Reopen Firefox.

The installer provides a removal path for project-owned files. Backups are stored in timestamped `minui-backup-*` folders inside the selected Firefox profile. If restoration fails, inspect the diagnostic message and backup directory before changing files manually.

## Diagnostics and troubleshooting

Use **Diagnostics** in the installer **after running Firefox once**, with Firefox closed again. The report checks for installed components and reads the most recent runtime stage recorded by the loader.

| Symptom | What to check |
| --- | --- |
| Firefox still displays two toolbars | Verify that the selected profile is the one you actually use and review the runtime trace in **Diagnostics**. |
| Installer reports an existing or unknown AutoConfig file | Do not delete it blindly. Verify its ownership and check for another Firefox customization. |
| Custom toolbar disappears in a narrow window | The current implementation requires a window width of at least **1,100 CSS pixels**. |
| Controls overlap or the layout resets | Inspect the runtime trace for a layout-validation failure. |
| A Firefox update breaks the interface | Firefox's internal toolbar structure may have changed. Restore the standard interface and check for a compatible release. |

When reporting a bug, include the Firefox version, Windows version, display scaling, installer version, the diagnostic trace, and a screenshot with personal information removed.

## Security considerations

**Please read this section before installing.**

This project is **not** a standard, sandboxed Firefox add-on. Its AutoConfig setup uses privileged code and sets `general.config.sandbox_enabled` to `false` for the AutoConfig execution environment. It also loads the project's local UI script through a privileged script loader. These mechanisms require greater trust in the code than ordinary browser extensions.

- Inspect the installer and source code before granting administrator privileges.
- Download builds only from a source you trust; verify hashes when provided.
- Avoid installing on managed or work computers without approval.
- Test on a separate Firefox profile before using your primary profile.
- Do not combine unknown AutoConfig loaders or custom scripts.

Firefox Min UI is provided **as is**, without warranties. It is not security-audited or code-signed as of v0.16 beta.

## Project structure

```text
Firefox-MinUI-Installer-v016.cmd   # Self-contained Windows installer
README.md
LICENSE
checksums.sha256
src/
  minui-prefs.js                  # AutoConfig preferences
  minui.cfg                       # Local privileged loader
  minui-v16-browser.js            # Browser UI behavior
  minui-v16.css                   # UI styling source
tests/
  test_layout.py                  # Layout simulation harness
```

The standalone installer embeds the resources it needs. The files in `src/` are included for review and development.

## Development and testing

`tests/test_layout.py` exercises a **simulated toolbar structure** using Python, Playwright, and Chromium. The current harness expects Chromium at `/usr/bin/chromium` and is intended for the development environment, not for installation on users' machines.

These tests can detect basic layout issues; they **do not** prove that a release works on a real Windows Firefox installation. Browser-level testing, compatibility checks, and a security review are still required before a stable release.

## Contributing

Issues and pull requests are welcome. Useful contributions include reproducible bug reports, testing across Firefox versions and display scales, accessibility improvements, installation safety, and documentation.

Please keep changes focused on preserving native Firefox behavior, avoiding UI overlap, and making installation and recovery predictable.

## License

Released under the **MIT License**. See [`LICENSE`](LICENSE).

## Maintainer

[**mudot**](https://github.com/mudot)

**Disclaimer:** Independent community project. Not affiliated with, endorsed by, or sponsored by Mozilla or Min Browser. Firefox is a trademark of the Mozilla Foundation.
