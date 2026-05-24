# AMenu

AMenu is a Lua/NUI menu resource with a separate framework bridge. This build supports Az-Framework, ESX Legacy, NDCore, QBCore, and standalone fallback mode through `AMenu-Bridge`.

## Features

- Main AMenu categories and controls
- Modern themed NUI with banner/header customization
- Resource command viewer
- Online player list
- Framework Management menu for player info, revive, heal, save, jobs, money, duty, kicks, and key hooks
- Framework auto-detection for Az-Framework, ESX Legacy, NDCore, and QBCore
- Config-driven permissions, local banners, spawn costs, and vehicle-spawner restrictions

## Resource Names

```cfg
ensure AMenu-Bridge
ensure AMenu
```

## Required Start Order

Start your framework first, then the bridge, then the menu.

### Az-Framework

```cfg
ensure Az-Framework
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

## Framework Bridge Config

Edit:

```txt
AMenu-Bridge/config.lua
```

Main options:

```lua
Config.Framework = {
    Mode = 'auto', -- auto, az, esx, nd, qb, standalone
    Priority = { 'az', 'esx', 'nd', 'qb' },
    Resources = {
        az = 'Az-Framework',
        esx = 'es_extended',
        nd = 'ND_Core',
        qb = 'qb-core'
    }
}
```

Use `Mode = 'auto'` for normal servers. Set it manually if more than one framework is started.

## Supported Framework Actions

The Framework Management section uses `AMenu-Bridge` and supports:

```txt
Player Info
Revive Player
Heal Player
Save Player
Set Duty where supported
Set Job / Group
Add Cash
Add Bank
Remove Cash
Remove Bank
Kick Player
Vehicle key event hooks
Vehicle spawn charging/restrictions
```

## Permissions

Add the needed ACE permissions to your server config or `AMenu/config/permissions.cfg`.

```cfg
add_ace group.admin "AMenu.Framework.Admin" allow
add_ace group.admin "AMenu.Framework.Menu" allow
add_ace group.admin "AMenu.Staff" allow
```

Optional framework-specific ACEs are also supported:

```cfg
add_ace group.admin "AMenu.ESX.Admin" allow
add_ace group.admin "AMenu.NDCore.Admin" allow
add_ace group.admin "AMenu.QBCore.Admin" allow
add_ace group.admin "AMenu.QBCore.Menu" allow
```

ESX admin groups, NDCore admin groups, and QBCore admin permission names are configurable in `AMenu-Bridge/config.lua`.

## Menu Config

Edit:

```txt
AMenu/config.lua
```

The table named `Config.QBCore` is still present for older UI callback compatibility, but the real multi-framework detection and actions are handled by `AMenu-Bridge/config.lua`.

## Banner / Header Customization

The menu supports direct banner layout controls through `AMenu/config.lua` and the in-menu **Menu Settings** section.

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

- Set Banner Image URL
- Set Banner Logo URL
- Set Brand Text
- Set Header Height
- Set Banner Fit Mode
- Set Banner Position
- Set Banner Overlay Opacity
- Reset Menu Appearance

## Important Files

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

## Notes

- Keep secrets in your server config, not in the AMenu repository.
- Do not commit production ban lists unless intended.
- If you run multiple frameworks at once, set `Config.Framework.Mode` manually so the bridge does not pick the wrong core.
