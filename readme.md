<div align="center">

# AMenu

### Modern Lua/NUI FiveM menu system with a separate multi-framework bridge.

![FiveM](https://img.shields.io/badge/FiveM-Menu%20Resource-blue)
![Lua](https://img.shields.io/badge/Lua-5.4-blueviolet)
![NUI](https://img.shields.io/badge/NUI-HTML%2FCSS%2FJS-orange)
![Bridge](https://img.shields.io/badge/Bridge-AMenu--Bridge-success)
![Frameworks](https://img.shields.io/badge/Frameworks-Az%20%7C%20QBX%20%7C%20QB%20%7C%20ESX%20%7C%20NDCore%20%7C%20Standalone-brightgreen)

</div>

---

## Overview

**AMenu** is a modern FiveM Lua/NUI menu resource built with a separate framework bridge called **AMenu-Bridge**.

The menu is designed to support framework-based servers while still allowing standalone fallback mode. The bridge handles framework detection, player lookups, player actions, job/group changes, money actions, duty status, vehicle key hooks, and other framework-specific features.

> [!IMPORTANT]  
> Start your framework first, then `AMenu-Bridge`, then `AMenu`.


---

<details open>
<summary><strong>Preview / Screenshots</strong></summary>

<br>

### Main Menu & Core Navigation

| Main Menu | Civilian Player Menu |
|---|---|
| ![AMenu Main Menu](images/amenu-main-menu.png) | ![AMenu Civilian Player Menu](images/amenu-civilian-player-menu.png) |

| Vehicle Controls | Resource Commands |
|---|---|
| ![AMenu Vehicle Controls](images/amenu-vehicle-controls.png) | ![AMenu Resource Commands](images/amenu-resource-commands.png) |

| Online Players | Qbox Management |
|---|---|
| ![AMenu Online Players](images/amenu-online-players.png) | ![AMenu Qbox Management](images/amenu-qbox-management.png) |

| Player Action Menu | Menu Settings |
|---|---|
| ![AMenu Player Actions](images/amenu-player-actions.png) | ![AMenu Menu Settings](images/amenu-menu-settings.png) |

### Theme Presets

| Candy Glow Preset | Royal Purple Preset |
|---|---|
| ![AMenu Candy Glow Preset](images/amenu-preset-candy-glow.png) | ![AMenu Royal Purple Preset](images/amenu-preset-royal-purple.png) |

These screenshots show the main layout, civilian actions, vehicle tools, resource command browser, online player list, framework-backed Qbox management, player actions, menu settings, and sample theme presets.

</details>


## Resource Names

```cfg
ensure AMenu-Bridge
ensure AMenu
```

| Resource | Purpose |
|---|---|
| `AMenu-Bridge` | Framework detection and framework-side actions |
| `AMenu` | Main menu resource, UI, categories, permissions, and NUI controls |

---

## Features

| Category | Features |
|---|---|
| Core Menu | Main AMenu categories, controls, menu navigation, and NUI layout |
| UI | Modern themed NUI, banner/header customization, brand text, local images, and layout settings |
| Resources | Resource command viewer and server resource tools |
| Players | Online player list and framework-backed player management |
| Framework Management | Player info, revive, heal, save, jobs/groups, duty, money, kicks, and key hooks |
| Bridge | Auto-detection for Az-Framework, Qbox/QBX, ESX Legacy, NDCore, QBCore, and standalone fallback |
| Config | Config-driven permissions, banners, spawn costs, restrictions, and menu behavior |

---

<details open>
<summary><strong>Supported Frameworks</strong></summary>

<br>

AMenu supports the following frameworks through `AMenu-Bridge`:

| Framework | Resource Name | Bridge Mode |
|---|---:|---:|
| Az-Framework | `Az-Framework` | `az` |
| Qbox / QBX | `qbx_core` | `qbx` |
| ESX Legacy | `es_extended` | `esx` |
| NDCore | `ND_Core` | `nd` |
| QBCore | `qb-core` | `qb` |
| Standalone | None | `standalone` |

Use `auto` for normal servers. Set the mode manually if you run more than one framework at the same time.

</details>

---

<details open>
<summary><strong>Required Start Order</strong></summary>

<br>

Start your framework first, then the bridge, then the menu.

### Az-Framework

```cfg
ensure Az-Framework
ensure AMenu-Bridge
ensure AMenu
```

### Qbox / QBX

```cfg
ensure qbx_core
ensure AMenu-Bridge
ensure AMenu
```

### ESX Legacy

```cfg
ensure es_extended
ensure AMenu-Bridge
ensure AMenu
```

### NDCore

```cfg
ensure ND_Core
ensure AMenu-Bridge
ensure AMenu
```

### QBCore

```cfg
ensure qb-core
ensure AMenu-Bridge
ensure AMenu
```

### Standalone

```cfg
ensure AMenu-Bridge
ensure AMenu
```

> [!NOTE]  
> If the bridge detects the wrong framework, force the correct mode in `AMenu-Bridge/config.lua`.

</details>

---

<details open>
<summary><strong>Framework Bridge Config</strong></summary>

<br>

Edit:

```txt
AMenu-Bridge/config.lua
```

Main bridge options:

```lua
Config.Framework = {
    Mode = 'auto',
    Priority = { 'az', 'qbx', 'esx', 'nd', 'qb' },
    Resources = {
        az = 'Az-Framework',
        qbx = 'qbx_core',
        esx = 'es_extended',
        nd = 'ND_Core',
        qb = 'qb-core'
    }
}
```

Accepted mode values:

```txt
auto
az
qbx
esx
nd
qb
standalone
```

### When To Use Manual Mode

Use manual mode if:

- More than one framework resource is started.
- The bridge is choosing the wrong framework.
- You are testing multiple framework resources in the same dev server.
- You want to lock AMenu to one core for release/server stability.

Example:

```lua
Config.Framework.Mode = 'qbx'
```

</details>

---

<details>
<summary><strong>Supported Framework Actions</strong></summary>

<br>

The Framework Management section uses `AMenu-Bridge` and supports framework-backed actions where the selected framework allows them.

```txt
Player Info
Revive Player
Heal Player
Save Player
Set Duty
Set Job / Group
Add Cash
Add Bank
Remove Cash
Remove Bank
Kick Player
Vehicle Key Event Hooks
Vehicle Spawn Charging
Vehicle Spawn Restrictions
```

Some actions depend on the framework and server configuration. If a framework does not expose a feature, the bridge should safely skip or return unsupported instead of breaking the menu.

</details>

---

<details open>
<summary><strong>Permissions</strong></summary>

<br>

Add the needed ACE permissions to your server config or to:

```txt
AMenu/config/permissions.cfg
```

Recommended base permissions:

```cfg
add_ace group.admin "AMenu.Framework.Admin" allow
add_ace group.admin "AMenu.Framework.Menu" allow
add_ace group.admin "AMenu.Staff" allow
```

Optional framework-specific permissions:

```cfg
add_ace group.admin "AMenu.AzFramework.Admin" allow
add_ace group.admin "AMenu.QBX.Admin" allow
add_ace group.admin "AMenu.ESX.Admin" allow
add_ace group.admin "AMenu.NDCore.Admin" allow
add_ace group.admin "AMenu.QBCore.Admin" allow
add_ace group.admin "AMenu.QBCore.Menu" allow
```

ESX admin groups, NDCore admin groups, QBCore admin permission names, and other framework permission options are configurable in:

```txt
AMenu-Bridge/config.lua
```

> [!TIP]  
> Keep permission names consistent across your server so staff groups do not accidentally receive the wrong access.

</details>

---

<details>
<summary><strong>Menu Config</strong></summary>

<br>

Edit:

```txt
AMenu/config.lua
```

This file controls the main menu behavior, UI options, categories, local banner settings, spawner settings, and resource-side options.

The table named `Config.QBCore` may still be present for older UI callback compatibility. The real multi-framework detection and framework actions are handled by:

```txt
AMenu-Bridge/config.lua
```

</details>

---

<details open>
<summary><strong>Banner / Header Customization</strong></summary>

<br>

AMenu supports direct banner layout controls through `AMenu/config.lua` and the in-menu **Menu Settings** section.

```lua
Config.UI.headerHeight = 112
Config.UI.bannerFitMode = 'contain'
Config.UI.bannerPosition = 'center center'
Config.UI.bannerOverlayOpacity = 0.04
```

Open:

```txt
Main Menu > Menu Settings
```

Available options include:

| Option | Description |
|---|---|
| Set Banner Image URL | Changes the main banner background image |
| Set Banner Logo URL | Changes the logo displayed in the header |
| Set Brand Text | Changes the menu brand/title text |
| Set Header Height | Adjusts the top banner/header height |
| Set Banner Fit Mode | Supports modes like `contain` or `cover` |
| Set Banner Position | Adjusts image alignment inside the header |
| Set Banner Overlay Opacity | Adjusts the banner overlay darkness/lightness |
| Reset Menu Appearance | Restores default menu appearance settings |

</details>

---

<details>
<summary><strong>Important Files</strong></summary>

<br>

```txt
AMenu/config.lua
AMenu/config/permissions.cfg
AMenu/config/addons.json
AMenu/config/extras.json
AMenu/config/locations.json
AMenu/config/tattoos.json
AMenu/html/index.html
AMenu/html/app.js
AMenu/html/styles.css
AMenu-Bridge/config.lua
AMenu-Bridge/server/main.lua
AMenu-Bridge/client/main.lua
```

| File | Purpose |
|---|---|
| `AMenu/config.lua` | Main menu config and UI/menu behavior |
| `AMenu/config/permissions.cfg` | Optional ACE permission config |
| `AMenu/config/addons.json` | Addon/menu data |
| `AMenu/config/extras.json` | Extra menu data |
| `AMenu/config/locations.json` | Location/menu point data |
| `AMenu/config/tattoos.json` | Tattoo/menu data |
| `AMenu/html/index.html` | NUI entry point |
| `AMenu/html/app.js` | Main NUI logic |
| `AMenu/html/styles.css` | Menu styling |
| `AMenu-Bridge/config.lua` | Framework bridge config |
| `AMenu-Bridge/server/main.lua` | Server-side bridge logic |
| `AMenu-Bridge/client/main.lua` | Client-side bridge logic |

</details>

---

<details>
<summary><strong>Troubleshooting</strong></summary>

<br>

### AMenu opens, but framework actions do not work

Make sure your framework starts before the bridge:

```cfg
ensure qbx_core
ensure AMenu-Bridge
ensure AMenu
```

Replace `qbx_core` with your actual framework resource.

### The bridge detected the wrong framework

Force the mode manually:

```lua
Config.Framework.Mode = 'qb'
```

or:

```lua
Config.Framework.Mode = 'qbx'
```

### Staff cannot use framework actions

Check ACE permissions:

```cfg
add_ace group.admin "AMenu.Framework.Admin" allow
add_ace group.admin "AMenu.Framework.Menu" allow
add_ace group.admin "AMenu.Staff" allow
```

Then restart the menu and bridge.

### Qbox / QBX is not being detected

Qbox uses the real resource name:

```txt
qbx_core
```

Do not use `qbx-core` as the resource ensure name unless your server has a custom renamed resource.

### Menu banner looks stretched

Adjust:

```lua
Config.UI.bannerFitMode = 'contain'
Config.UI.bannerPosition = 'center center'
Config.UI.headerHeight = 112
```

### Menu UI looks too dark or blacked out

Avoid adding heavy full-screen opacity layers, forced page-level `color-scheme: dark;`, or large drop-shadow effects to the NUI. Keep the UI transparent and controlled through the menu theme settings.

</details>

---

<details>
<summary><strong>Updating</strong></summary>

<br>

Before updating, back up:

```txt
AMenu/config.lua
AMenu/config/permissions.cfg
AMenu/config/addons.json
AMenu/config/extras.json
AMenu/config/locations.json
AMenu/config/tattoos.json
AMenu-Bridge/config.lua
```

Then replace the resource files and manually merge your config changes.

</details>

---

## Notes

- Keep secrets in your server config, not inside the AMenu repository.
- Do not commit production ban lists unless you intentionally want them public.
- If multiple frameworks are running, set `Config.Framework.Mode` manually so the bridge does not pick the wrong core.
- Keep `AMenu-Bridge` and `AMenu` together when releasing or installing the resource.
- Restart `AMenu-Bridge` before `AMenu` after changing bridge settings.

---

## Credits

Created by Azure.

---

## License

Use, edit, and distribute according to your server or project license terms. If you release a public fork, keep credits intact and never include private tokens, private server data, or production-only configuration.
