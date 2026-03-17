# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

## [7.3.1] - 2025-03-08

This release aligns Fred with Znuny’s **Dev::** namespace for developer tools, renames the frontend module and several backend modules for consistency, and extends support to multiple Znuny versions.

### Added

- **Base class** `Kernel/System/Dev/Fred/Base.pm` for Fred backend modules. Shared logic and structure for all Fred system modules (ConfigLog, Console, EnvLog, etc.) now live in this base class to simplify maintenance and future extensions.
- **README.md** with a short project overview, list of features (Console, ConfigSwitch, ConfigLog, EnvLog, SessionLog, STDERRLog, SQLLog, HTMLCheck, JSLint, TranslationLog), installation steps, main configuration options, and basic usage. Written in English.
- **Feature documentation** `doc/en/feature.md` describing each module and its purpose, plus installation and configuration notes. Replaces the previous XML-based doc layout where applicable.
- **Dedicated JavaScript files** `Core.Dev.Fred.ConfigSwitch.js` and `Core.Dev.Fred.SQLLog.js`. Config switch and SQL log behaviour are no longer bundled only in the main Fred JS file; they have their own modules under the `Core.Dev.Fred` namespace for clearer structure and loading.
- **Multi-framework support**: the package now declares compatibility with Znuny 6.0.x, 6.4.x, 6.5.x, 7.0.x, 7.1.x, 7.2.x and 7.3.x in the SOPM, so the same package can be installed across these versions (subject to actual runtime compatibility).

### Changed

- **Namespace** from `Fred` to `Dev::Fred` so Fred is clearly grouped with other Znuny developer tools:
  - Output modules: `Kernel/Output/HTML/Fred/` → `Kernel/Output/HTML/Dev/Fred/`.
  - System modules: `Kernel/System/Fred/` → `Kernel/System/Dev/Fred/`.
  - Templates: flat names like `DevelFredConfigLog.tt` are now under the directory `Kernel/Output/HTML/Templates/Standard/Dev/Fred/` (e.g. `ConfigLog.tt`, `Console.tt`).
  - FilterContent: `Kernel/Output/HTML/FilterContent/Fred.pm` → `Kernel/Output/HTML/FilterContent/Dev/Fred.pm`.
- **Frontend module**: the main Fred UI is no longer registered as `DevelFred`. The module file is now `Kernel/Modules/Fred.pm` and the frontend action is `Fred`. Links and bookmarks that used `Action=DevelFred` must be updated to `Action=Fred`.
- **Module names** (behavior and purpose unchanged, names aligned with “Log” where they log or list data):
  - EnvDump → **EnvLog** (environment/layout data).
  - SessionDump → **SessionLog** (server-side session content).
  - TranslationDebug → **TranslationLog** (failed translation attempts).
  All corresponding SysConfig keys, package names, and template references use the new names.
- **JavaScript and CSS**: all Fred-related assets renamed from the `Core.Fred` to the `Core.Dev.Fred` namespace (e.g. `Core.Fred.js` → `Core.Dev.Fred.js`, `Core.Fred.css` → `Core.Dev.Fred.css`) in both Agent and Customer skins, so they match the `Dev::Fred` backend namespace.
- **SysConfig**: Fred settings are grouped under **Dev::Fred**. In the admin interface they appear under *Admin → System → Configuration → Dev::Fred*. All setting names and module keys (e.g. `Fred###Module###TranslationLog`, `Fred###Module###EnvLog`, `Fred###Module###SessionLog`) use the new naming; custom config or scripts that reference the old keys must be updated.

### Removed

- **`Kernel/Modules/DevelFred.pm`** — replaced by `Kernel/Modules/Fred.pm`. The frontend is now reached via the `Fred` action only.
- **`doc/en/Fred.xml`** — replaced by `doc/en/feature.md` (and optionally other docs). Any references to the old doc file or its IDs should point to the new documentation.
