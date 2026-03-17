<div align="center">
  <a href="https://www.znuny.org">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="https://www.znuny.com/assets/znuny-logo.svg">
      <img alt="Znuny" src="https://www.znuny.com/assets/znuny-logo-black.svg" width="300">
    </picture>
  </a>

  ![Build status](https://badge.proxy.znuny.com/Fred/private-dk-dev-upgrade)
</div>

# Fred

Fred is a developer tool for Znuny that supports you during development.

**Vendor:** Znuny GmbH
**License:** GNU AFFERO GENERAL PUBLIC LICENSE Version 3
**Supported Frameworks:** Znuny 6.0.x, 6.4.x, 6.5.x, 7.0.x, 7.1.x, 7.2.x, 7.3.x

---

## Features

| Module | Description |
|--------|-------------|
| **Console** | Short overview of all relevant developer information. |
| **ConfigSwitch** | Toggle frequently needed config options (e.g. DebugMode, TemplateCache) directly in Fred. |
| **ConfigLog** | Lists all `ConfigGet` calls of the current request including frequency. |
| **EnvLog** | Shows environment variables of the layout object. |
| **SessionLog** | Shows the current content of the server-side session. |
| **STDERRLog** | Shows entries from the STDERR log (with optional filter). |
| **SQLLog** | Lists all SQL statements of the current request. |
| **HTMLCheck** | Performs HTML quality checks in the frontend. |
| **JSLint** | Performs JavaScript quality checks. |
| **TranslationLog** | Shows failed translation attempts (untranslated strings) of the current request. |

Fred is modular: modules can be enabled/disabled individually and prioritized.

---

## Installation

1. Install the package as a Znuny addon (e.g. via **Admin → System → Package Manager** or `znuny.Console.pl Maint::Package::Install`).
2. Fred is available in the **Dev** menu in the agent, customer and public frontend (provided the respective frontend registration is active).

---

## Configuration

Settings are found under **Admin → System → Configuration → Dev::Fred** or in Fred under **Setting**.

| Setting | Description |
|---------|-------------|
| **Fred###Active** | Show or hide Fred. |
| **Fred###LogPath** | Log path for Fred logs (default: `/var/log/dev/fred/`). |
| **Fred###SystemName** | Display name for the system (e.g. to distinguish multiple instances). |
| **Fred###BackgroundColor** | Background color of the system name box (default: `#FF8A25`). |
| **Fred###ConsoleWidth** | Width of the Fred console in percent. |
| **Fred###ConsoleHeight** | Height of the Fred console in pixels. |
| **Fred###ConsoleOpacity** | Opacity of the Fred console (e.g. `0.9` = 90% visible). |
| **Fred###Module###…** | Per module: `Active`, `Prio`, `Description` and optional module-specific `Config`. |

**Note:** For ConfigSwitch, only use options with values 0/1 (No/Yes) in the module settings. The available options are defined in the configuration.

---

## Usage

- After installation, the **Dev** menu appears in the frontend with the **Fred-Developertools** entry.
- Use **Setting** in Fred to quickly access Fred configuration options.
- Individual modules can be enabled and ordered (Prio) in the configuration.

---

## Extending Fred

Fred is deliberately modular. New modules can be added as needed; suggestions and contributions are welcome.
