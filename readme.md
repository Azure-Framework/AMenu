# vMenu for Azure Framework

This vMenu build keeps the standard vMenu layout while adding Azure-themed styling and Azure Framework management actions through `vMenu-Bridge`.

## Features

- Azure-themed menu presets and banner support
- Main vMenu categories and controls
- Resource command viewer
- Online player list
- Azure Framework Management menu
- Banner and appearance editing from inside the menu
- Config-driven local banner support

## Resource Name

```cfg
ensure vMenu
```

## Required Start Order

```cfg
ensure Az-Framework
ensure vMenu-Bridge
ensure vMenu
```

## Main Config File

```txt
config.lua
```

## Azure Banner Setup

The default local Azure banner is:

```txt
html/banners/azure.png
```

The default menu banner mapping is configured in:

```lua
Config.UI.bannerCycle
Config.UI.menuBanners
```

## Easy Banner / Header Customization

The menu now supports direct banner layout controls through `config.lua` and the in-menu **Menu Settings** section.

### Config keys

```lua
Config.UI.headerHeight = 112
Config.UI.bannerFitMode = 'contain'
Config.UI.bannerPosition = 'center center'
Config.UI.bannerOverlayOpacity = 0.04
```

### What they do

- `headerHeight` changes the visible banner/header height
- `bannerFitMode` accepts `contain`, `cover`, or `stretch`
- `bannerPosition` controls image placement, for example `center top` or `center 45%`
- `bannerOverlayOpacity` controls how dark the overlay is over the banner image

### In-menu controls

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

This makes it much easier to tune the Azure banner if it looks slightly clipped on your preferred theme or scale.

## Azure Framework Management

The Azure Framework Management section uses `vMenu-Bridge` for player-facing framework actions such as:

```txt
Player Info
Revive Player
Heal Player
Save Player
Set Duty
Set Job
Add Cash
```

## Permissions

Add the needed ACE permissions to your server config or `config/permissions.cfg`.

```cfg
add_ace group.admin "vMenu.Framework.Admin" allow
add_ace group.admin "vMenu.QBCore.Admin" allow
```

The QBCore ACE name is kept only for compatibility with older menu checks. Azure actions still route through `vMenu-Bridge`.

## Important Files

```txt
config.lua
config/permissions.cfg
config/addons.json
config/extras.json
config/locations.json
config/tattoos.json
html/index.html
html/app.js
html/styles.css
html/banners/azure.png
```

## GitHub / Repository Notes

- Do not commit private banner assets unless you want them public.
- Do not commit production ban lists or private command data unless intended.
- Keep secrets in your server config, not in the vMenu repository.
