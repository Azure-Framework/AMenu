Config = {}

Config.UI = {
  brandText = 'Azure Menu',
  bannerImage = '',
  bannerLogo = '',
  headerHeight = 112,
  bannerFitMode = 'contain',
  bannerPosition = 'center center',
  bannerOverlayOpacity = 0.04,
  defaultRightAlign = false,
  defaultOffsetX = 18,
  defaultOffsetY = 18,
  defaultScale = 1.0,

  defaultTheme = 'blue',
  defaultPreset = 'modern_glow',
  allowUserThemeSelection = true,
  allowUserPositioning = true,
  allowUserBannerEditing = true,

  presets = {
    classic_blue = {
      label = 'Classic Blue',
      effect = 'classic',
      description = 'Closest to the original vMenu blue look.',
      t1 = 'rgba(15,78,168,0.92)', t2 = 'rgba(28,116,217,0.88)', t3 = 'rgba(62,156,255,0.82)',
      title = '#0da7ff', count = '#4aa9ff',
      listBg = 'rgba(18,24,31,0.72)', rowBg = 'rgba(34,41,50,0.72)', text = '#f4f4f4',
      activeBg = 'rgba(236,236,236,0.98)', activeText = '#111111',
      border = 'rgba(255,255,255,0.06)', borderStrong = 'rgba(255,255,255,0.12)',
      headerOverlay = 'linear-gradient(180deg, rgba(255,255,255,0.06), rgba(255,255,255,0))',
      glow = 'none', glowStrong = 'none',
      scrollTrack = 'rgba(10,18,28,0.88)', scrollThumb = 'rgba(28,116,217,0.92)', scrollThumbActive = 'rgba(62,156,255,0.96)'
    },
    modern_glow = {
      label = 'Modern Glow',
      effect = 'glow',
      description = 'Darker panel with neon blue edges and a brighter active row.',
      t1 = 'rgba(8,18,38,0.96)', t2 = 'rgba(26,92,200,0.94)', t3 = 'rgba(69,171,255,0.88)',
      title = '#8ad7ff', count = '#bfe8ff',
      listBg = 'rgba(7,12,19,0.82)', rowBg = 'rgba(14,20,30,0.88)', text = '#eef7ff',
      activeBg = 'rgba(65,170,255,0.94)', activeText = '#07111d',
      border = 'rgba(82,190,255,0.16)', borderStrong = 'rgba(82,190,255,0.34)',
      headerOverlay = 'linear-gradient(180deg, rgba(255,255,255,0.10), rgba(255,255,255,0.01))',
      glow = '0 0 18px rgba(43,167,255,0.22)', glowStrong = '0 0 26px rgba(43,167,255,0.28)',
      scrollTrack = 'rgba(8,14,22,0.92)', scrollThumb = 'rgba(45,146,255,0.92)', scrollThumbActive = 'rgba(102,195,255,0.96)'
    },
    red_glow = {
      label = 'Red Glow',
      effect = 'glow',
      description = 'Red-accented preset with stronger border glow.',
      t1 = 'rgba(36,10,14,0.96)', t2 = 'rgba(153,25,38,0.94)', t3 = 'rgba(255,94,116,0.88)',
      title = '#ff9baa', count = '#ffd0d7',
      listBg = 'rgba(19,9,12,0.84)', rowBg = 'rgba(31,14,18,0.90)', text = '#fff3f5',
      activeBg = 'rgba(255,110,130,0.95)', activeText = '#220a0f',
      border = 'rgba(255,106,128,0.18)', borderStrong = 'rgba(255,106,128,0.36)',
      headerOverlay = 'linear-gradient(180deg, rgba(255,255,255,0.09), rgba(255,255,255,0.01))',
      glow = '0 0 18px rgba(255,76,112,0.20)', glowStrong = '0 0 28px rgba(255,76,112,0.26)',
      scrollTrack = 'rgba(26,8,12,0.92)', scrollThumb = 'rgba(220,54,86,0.92)', scrollThumbActive = 'rgba(255,110,130,0.96)'
    },
    purple_glow = {
      label = 'Purple Glow',
      effect = 'neon',
      description = 'Deep purple neon styling.',
      t1 = 'rgba(20,10,36,0.96)', t2 = 'rgba(98,42,188,0.94)', t3 = 'rgba(186,118,255,0.90)',
      title = '#d6b2ff', count = '#ead9ff',
      listBg = 'rgba(14,9,24,0.84)', rowBg = 'rgba(24,15,40,0.90)', text = '#f7f0ff',
      activeBg = 'rgba(189,123,255,0.95)', activeText = '#180a29',
      border = 'rgba(180,120,255,0.18)', borderStrong = 'rgba(180,120,255,0.36)',
      headerOverlay = 'linear-gradient(180deg, rgba(255,255,255,0.10), rgba(255,255,255,0.01))',
      glow = '0 0 20px rgba(158,92,255,0.22)', glowStrong = '0 0 30px rgba(158,92,255,0.30)',
      scrollTrack = 'rgba(18,10,30,0.92)', scrollThumb = 'rgba(142,82,255,0.92)', scrollThumbActive = 'rgba(198,144,255,0.96)'
    },
    rgb_wave = {
      label = 'RGB Wave',
      effect = 'rgb',
      description = 'Animated RGB-style accent preset.',
      t1 = 'rgba(18,18,22,0.96)', t2 = 'rgba(255,64,128,0.92)', t3 = 'rgba(64,220,255,0.92)',
      title = '#ffffff', count = '#f3f8ff',
      listBg = 'rgba(10,10,14,0.86)', rowBg = 'rgba(18,18,24,0.92)', text = '#fafcff',
      activeBg = 'rgba(255,255,255,0.96)', activeText = '#111111',
      border = 'rgba(255,255,255,0.14)', borderStrong = 'rgba(255,255,255,0.28)',
      headerOverlay = 'linear-gradient(90deg, rgba(255,60,120,0.22), rgba(90,110,255,0.22), rgba(60,255,200,0.22))',
      glow = '0 0 20px rgba(255,255,255,0.16)', glowStrong = '0 0 32px rgba(255,255,255,0.22)',
      scrollTrack = 'rgba(14,14,18,0.94)', scrollThumb = 'linear-gradient(180deg, #ff4f7a, #5aa0ff)', scrollThumbActive = 'linear-gradient(180deg, #7dffcf, #b96cff)'
    },
    chrome_mirror = {
      label = 'Chrome Mirror',
      effect = 'chrome',
      description = 'Cool silver and chrome inspired look.',
      t1 = 'rgba(46,52,62,0.96)', t2 = 'rgba(120,130,145,0.94)', t3 = 'rgba(224,232,238,0.90)',
      title = '#eef5fb', count = '#ffffff',
      listBg = 'rgba(18,22,28,0.84)', rowBg = 'rgba(35,40,48,0.90)', text = '#f4f8fb',
      activeBg = 'rgba(222,232,240,0.96)', activeText = '#14181d',
      border = 'rgba(210,220,230,0.16)', borderStrong = 'rgba(230,240,248,0.34)',
      headerOverlay = 'linear-gradient(180deg, rgba(255,255,255,0.18), rgba(255,255,255,0.02))',
      glow = '0 0 18px rgba(220,232,240,0.16)', glowStrong = '0 0 28px rgba(220,232,240,0.22)',
      scrollTrack = 'rgba(24,28,34,0.94)', scrollThumb = 'rgba(163,175,188,0.95)', scrollThumbActive = 'rgba(235,242,247,0.98)'
    },
    shiny_black = {
      label = 'Shiny Black',
      effect = 'shiny',
      description = 'Glossy black preset with subtle shine.',
      t1 = 'rgba(8,8,10,0.98)', t2 = 'rgba(26,26,30,0.96)', t3 = 'rgba(88,88,98,0.86)',
      title = '#f6f6f8', count = '#d8d8e0',
      listBg = 'rgba(5,5,7,0.90)', rowBg = 'rgba(14,14,18,0.94)', text = '#fafafd',
      activeBg = 'rgba(233,233,240,0.96)', activeText = '#111111',
      border = 'rgba(255,255,255,0.10)', borderStrong = 'rgba(255,255,255,0.20)',
      headerOverlay = 'linear-gradient(180deg, rgba(255,255,255,0.13), rgba(255,255,255,0.01))',
      glow = '0 0 18px rgba(255,255,255,0.10)', glowStrong = '0 0 26px rgba(255,255,255,0.16)',
      scrollTrack = 'rgba(8,8,10,0.96)', scrollThumb = 'rgba(92,92,104,0.94)', scrollThumbActive = 'rgba(212,212,222,0.98)'
    },
    pink_neon = {
      label = 'Pink Neon',
      effect = 'neon',
      description = 'Hot pink glow theme.',
      t1 = 'rgba(34,6,26,0.96)', t2 = 'rgba(196,33,122,0.94)', t3 = 'rgba(255,118,202,0.90)',
      title = '#ffcaeb', count = '#ffe5f5',
      listBg = 'rgba(22,7,18,0.86)', rowBg = 'rgba(36,10,28,0.90)', text = '#fff4fb',
      activeBg = 'rgba(255,138,208,0.95)', activeText = '#220917',
      border = 'rgba(255,126,206,0.18)', borderStrong = 'rgba(255,126,206,0.36)',
      headerOverlay = 'linear-gradient(180deg, rgba(255,255,255,0.10), rgba(255,255,255,0.01))',
      glow = '0 0 20px rgba(255,76,191,0.22)', glowStrong = '0 0 30px rgba(255,76,191,0.30)',
      scrollTrack = 'rgba(24,8,20,0.94)', scrollThumb = 'rgba(220,62,166,0.94)', scrollThumbActive = 'rgba(255,148,220,0.98)'
    },
    emerald_pulse = {
      label = 'Emerald Pulse',
      effect = 'pulse',
      description = 'Clean green neon theme.',
      t1 = 'rgba(8,24,20,0.96)', t2 = 'rgba(22,138,103,0.94)', t3 = 'rgba(108,255,184,0.90)',
      title = '#b8ffe2', count = '#e0fff1',
      listBg = 'rgba(8,18,16,0.86)', rowBg = 'rgba(12,30,26,0.90)', text = '#effff8',
      activeBg = 'rgba(103,255,184,0.95)', activeText = '#081811',
      border = 'rgba(101,244,177,0.18)', borderStrong = 'rgba(101,244,177,0.34)',
      headerOverlay = 'linear-gradient(180deg, rgba(255,255,255,0.10), rgba(255,255,255,0.01))',
      glow = '0 0 18px rgba(65,255,171,0.22)', glowStrong = '0 0 28px rgba(65,255,171,0.28)',
      scrollTrack = 'rgba(8,18,14,0.94)', scrollThumb = 'rgba(29,184,130,0.94)', scrollThumbActive = 'rgba(118,255,197,0.98)'
    },
    gold_luxury = {
      label = 'Gold Luxury',
      effect = 'shine',
      description = 'Warm gold premium preset.',
      t1 = 'rgba(34,24,8,0.96)', t2 = 'rgba(178,138,38,0.94)', t3 = 'rgba(255,220,118,0.90)',
      title = '#ffe4a1', count = '#fff1cc',
      listBg = 'rgba(20,14,7,0.86)', rowBg = 'rgba(34,24,12,0.90)', text = '#fff8eb',
      activeBg = 'rgba(255,220,120,0.95)', activeText = '#231607',
      border = 'rgba(255,214,116,0.18)', borderStrong = 'rgba(255,214,116,0.34)',
      headerOverlay = 'linear-gradient(180deg, rgba(255,255,255,0.10), rgba(255,255,255,0.01))',
      glow = '0 0 18px rgba(255,214,90,0.18)', glowStrong = '0 0 28px rgba(255,214,90,0.24)',
      scrollTrack = 'rgba(24,18,8,0.94)', scrollThumb = 'rgba(202,160,45,0.94)', scrollThumbActive = 'rgba(255,224,128,0.98)'
    },
    ice_blue = {
      label = 'Ice Blue',
      effect = 'glow',
      description = 'Frosted blue-white theme.',
      t1 = 'rgba(8,26,38,0.96)', t2 = 'rgba(62,150,199,0.94)', t3 = 'rgba(184,235,255,0.90)',
      title = '#dff7ff', count = '#f0fbff',
      listBg = 'rgba(8,18,24,0.86)', rowBg = 'rgba(14,28,36,0.90)', text = '#f5fcff',
      activeBg = 'rgba(194,238,255,0.95)', activeText = '#0a1720',
      border = 'rgba(177,232,255,0.18)', borderStrong = 'rgba(177,232,255,0.34)',
      headerOverlay = 'linear-gradient(180deg, rgba(255,255,255,0.14), rgba(255,255,255,0.01))',
      glow = '0 0 18px rgba(147,219,255,0.18)', glowStrong = '0 0 28px rgba(147,219,255,0.24)',
      scrollTrack = 'rgba(10,20,28,0.94)', scrollThumb = 'rgba(87,176,220,0.94)', scrollThumbActive = 'rgba(200,241,255,0.98)'
    },
    sunset_orange = {
      label = 'Sunset Orange',
      effect = 'glow',
      description = 'Warm orange fade preset.',
      t1 = 'rgba(36,16,6,0.96)', t2 = 'rgba(220,104,26,0.94)', t3 = 'rgba(255,182,96,0.90)',
      title = '#ffd2a6', count = '#ffe7ca',
      listBg = 'rgba(24,12,6,0.86)', rowBg = 'rgba(38,18,8,0.90)', text = '#fff6ef',
      activeBg = 'rgba(255,186,104,0.95)', activeText = '#241106',
      border = 'rgba(255,175,94,0.18)', borderStrong = 'rgba(255,175,94,0.34)',
      headerOverlay = 'linear-gradient(180deg, rgba(255,255,255,0.10), rgba(255,255,255,0.01))',
      glow = '0 0 18px rgba(255,146,61,0.20)', glowStrong = '0 0 28px rgba(255,146,61,0.26)',
      scrollTrack = 'rgba(26,12,6,0.94)', scrollThumb = 'rgba(232,124,46,0.94)', scrollThumbActive = 'rgba(255,196,124,0.98)'
    },

    cyan_glow = {
      label = 'Cyan Glow',
      effect = 'glow',
      description = 'Bright cyan glow with clean glassy edges.',
      t1 = 'rgba(6,24,36,0.96)', t2 = 'rgba(18,156,196,0.94)', t3 = 'rgba(104,246,255,0.92)',
      title = '#c9fbff', count = '#e9feff',
      listBg = 'rgba(7,18,24,0.86)', rowBg = 'rgba(12,28,36,0.90)', text = '#f2feff',
      activeBg = 'rgba(118,246,255,0.96)', activeText = '#06161b',
      border = 'rgba(120,244,255,0.18)', borderStrong = 'rgba(120,244,255,0.36)',
      headerOverlay = 'linear-gradient(180deg, rgba(255,255,255,0.12), rgba(255,255,255,0.01))',
      glow = '0 0 20px rgba(74,235,255,0.22)', glowStrong = '0 0 32px rgba(74,235,255,0.30)',
      scrollTrack = 'rgba(8,18,24,0.94)', scrollThumb = 'rgba(28,184,214,0.94)', scrollThumbActive = 'rgba(128,250,255,0.98)'
    },
    royal_purple = {
      label = 'Royal Purple',
      effect = 'shine',
      description = 'Rich royal purple with glossy highlights.',
      t1 = 'rgba(22,10,40,0.97)', t2 = 'rgba(106,48,196,0.95)', t3 = 'rgba(214,164,255,0.92)',
      title = '#edd8ff', count = '#f8efff',
      listBg = 'rgba(15,8,28,0.86)', rowBg = 'rgba(24,12,42,0.91)', text = '#fbf5ff',
      activeBg = 'rgba(218,172,255,0.96)', activeText = '#160826',
      border = 'rgba(210,166,255,0.18)', borderStrong = 'rgba(210,166,255,0.36)',
      headerOverlay = 'linear-gradient(180deg, rgba(255,255,255,0.14), rgba(255,255,255,0.01))',
      glow = '0 0 18px rgba(173,106,255,0.20)', glowStrong = '0 0 28px rgba(173,106,255,0.28)',
      scrollTrack = 'rgba(18,10,32,0.94)', scrollThumb = 'rgba(132,80,222,0.94)', scrollThumbActive = 'rgba(223,181,255,0.98)'
    },
    liquid_chrome = {
      label = 'Liquid Chrome',
      effect = 'chrome',
      description = 'Highly reflective chrome with a brighter sweep.',
      t1 = 'rgba(40,44,52,0.97)', t2 = 'rgba(148,158,168,0.95)', t3 = 'rgba(244,248,252,0.94)',
      title = '#fbfdff', count = '#ffffff',
      listBg = 'rgba(18,20,26,0.88)', rowBg = 'rgba(34,38,44,0.92)', text = '#f7fafc',
      activeBg = 'rgba(238,243,248,0.97)', activeText = '#14171b',
      border = 'rgba(230,236,242,0.18)', borderStrong = 'rgba(245,249,252,0.38)',
      headerOverlay = 'linear-gradient(180deg, rgba(255,255,255,0.22), rgba(255,255,255,0.03))',
      glow = '0 0 20px rgba(230,238,245,0.16)', glowStrong = '0 0 30px rgba(230,238,245,0.24)',
      scrollTrack = 'rgba(22,24,28,0.94)', scrollThumb = 'rgba(175,184,194,0.96)', scrollThumbActive = 'rgba(246,249,252,0.99)'
    },
    rainbow_flux = {
      label = 'Rainbow Flux',
      effect = 'rgb',
      description = 'Extra colorful RGB preset with stronger rainbow motion.',
      t1 = 'rgba(16,16,20,0.97)', t2 = 'rgba(255,82,130,0.95)', t3 = 'rgba(110,255,212,0.93)',
      title = '#ffffff', count = '#ffffff',
      listBg = 'rgba(10,10,14,0.88)', rowBg = 'rgba(16,16,22,0.92)', text = '#fafcff',
      activeBg = 'rgba(255,255,255,0.97)', activeText = '#111111',
      border = 'rgba(255,255,255,0.16)', borderStrong = 'rgba(255,255,255,0.30)',
      headerOverlay = 'linear-gradient(90deg, rgba(255,82,130,0.24), rgba(92,102,255,0.24), rgba(110,255,212,0.24))',
      glow = '0 0 22px rgba(255,255,255,0.18)', glowStrong = '0 0 34px rgba(255,255,255,0.24)',
      scrollTrack = 'rgba(12,12,16,0.94)', scrollThumb = 'linear-gradient(180deg, #ff5782, #7c86ff)', scrollThumbActive = 'linear-gradient(180deg, #74ffd4, #ff7cf2)'
    },
    obsidian_shine = {
      label = 'Obsidian Shine',
      effect = 'shiny',
      description = 'Deep obsidian black with a bright moving sheen.',
      t1 = 'rgba(6,6,8,0.99)', t2 = 'rgba(18,18,22,0.97)', t3 = 'rgba(118,118,130,0.86)',
      title = '#fafaff', count = '#e5e5ec',
      listBg = 'rgba(4,4,6,0.92)', rowBg = 'rgba(11,11,15,0.95)', text = '#fbfbff',
      activeBg = 'rgba(240,240,246,0.97)', activeText = '#101014',
      border = 'rgba(255,255,255,0.10)', borderStrong = 'rgba(255,255,255,0.22)',
      headerOverlay = 'linear-gradient(180deg, rgba(255,255,255,0.16), rgba(255,255,255,0.01))',
      glow = '0 0 18px rgba(255,255,255,0.10)', glowStrong = '0 0 28px rgba(255,255,255,0.16)',
      scrollTrack = 'rgba(7,7,9,0.96)', scrollThumb = 'rgba(98,98,112,0.94)', scrollThumbActive = 'rgba(228,228,236,0.98)'
    },
    toxic_lime = {
      label = 'Toxic Lime',
      effect = 'pulse',
      description = 'Aggressive lime pulse with bright green accents.',
      t1 = 'rgba(12,22,8,0.97)', t2 = 'rgba(102,188,28,0.95)', t3 = 'rgba(208,255,108,0.93)',
      title = '#ebffbf', count = '#f7ffde',
      listBg = 'rgba(10,16,7,0.88)', rowBg = 'rgba(18,28,10,0.92)', text = '#f7ffef',
      activeBg = 'rgba(214,255,122,0.97)', activeText = '#121907',
      border = 'rgba(192,255,118,0.18)', borderStrong = 'rgba(192,255,118,0.36)',
      headerOverlay = 'linear-gradient(180deg, rgba(255,255,255,0.12), rgba(255,255,255,0.01))',
      glow = '0 0 20px rgba(179,255,94,0.20)', glowStrong = '0 0 32px rgba(179,255,94,0.28)',
      scrollTrack = 'rgba(12,18,8,0.94)', scrollThumb = 'rgba(128,214,34,0.94)', scrollThumbActive = 'rgba(222,255,144,0.98)'
    },
    candy_glow = {
      label = 'Candy Glow',
      effect = 'neon',
      description = 'Bright candy pink and lavender neon style.',
      t1 = 'rgba(38,8,28,0.97)', t2 = 'rgba(216,52,148,0.95)', t3 = 'rgba(255,172,236,0.93)',
      title = '#ffdff6', count = '#fff0fb',
      listBg = 'rgba(22,6,18,0.88)', rowBg = 'rgba(38,10,31,0.92)', text = '#fff6fc',
      activeBg = 'rgba(255,180,238,0.97)', activeText = '#220a1a',
      border = 'rgba(255,162,228,0.18)', borderStrong = 'rgba(255,162,228,0.38)',
      headerOverlay = 'linear-gradient(180deg, rgba(255,255,255,0.13), rgba(255,255,255,0.01))',
      glow = '0 0 22px rgba(255,126,220,0.22)', glowStrong = '0 0 34px rgba(255,126,220,0.30)',
      scrollTrack = 'rgba(24,8,20,0.94)', scrollThumb = 'rgba(228,76,176,0.95)', scrollThumbActive = 'rgba(255,188,240,0.99)'
    },
    stealth_black = {
      label = 'Stealth Black',
      effect = 'classic',
      description = 'Minimal black preset with almost no color.',
      t1 = 'rgba(10,10,10,0.98)', t2 = 'rgba(18,18,18,0.96)', t3 = 'rgba(44,44,44,0.90)',
      title = '#efefef', count = '#bfbfbf',
      listBg = 'rgba(7,7,7,0.90)', rowBg = 'rgba(12,12,12,0.94)', text = '#f5f5f5',
      activeBg = 'rgba(225,225,225,0.96)', activeText = '#101010',
      border = 'rgba(255,255,255,0.08)', borderStrong = 'rgba(255,255,255,0.16)',
      headerOverlay = 'linear-gradient(180deg, rgba(255,255,255,0.08), rgba(255,255,255,0.01))',
      glow = 'none', glowStrong = 'none',
      scrollTrack = 'rgba(8,8,8,0.96)', scrollThumb = 'rgba(84,84,84,0.94)', scrollThumbActive = 'rgba(194,194,194,0.98)'
    }
  }
}

Config.Addons = {
  file = 'addons.json'
}

Config.Controls = {
  fallbackOpenControl = 244,
  disableOpenFallback = false,
  fallbackNoclipControl = 289
}

Config.Civilian = {

  MaxTransferAmount = 100000,
  GpsRequestTimeoutSeconds = 120
}

Config.World = {
  manageSync = true,
  allowMenuControls = true,
  syncOnJoin = false,
  syncOnOpen = false,
}

Config.UI.bannerCycle = {
  'banners/azure.png'
}

Config.UI.menuBanners = {
  main = 'banners/azure.png',
  qbcoreManagement = 'banners/azure.png',
  qbcorePlayerActions = 'banners/azure.png',
  onlinePlayers = 'banners/azure.png',
  playerRelated = 'banners/azure.png',
  vehicleRelated = 'banners/azure.png',
  worldRelated = 'banners/azure.png',
  miscSettings = 'banners/azure.png',
  resourceCommands = 'banners/azure.png'
}

Config.QBCore = {
  Enabled = true,
  FrameworkBridgeResource = 'vMenu-Bridge',
  CoreResource = 'Az-Framework',
  VehicleKeysResource = 'qb-vehiclekeys',

  AdminAce = 'vMenu.Framework.Admin',
  AdminQBPermissions = { 'god', 'admin' },

  RestrictVehicleSpawner = true,
  RequireOnDuty = true,
  AllowedJobs = {
    police = { label = 'LEO', requireDuty = true },
    sheriff = { label = 'LEO', requireDuty = true },
    bcso = { label = 'LEO', requireDuty = true },
    sasp = { label = 'LEO', requireDuty = true },
    state = { label = 'LEO', requireDuty = true },
    lspd = { label = 'LEO', requireDuty = true },

    ambulance = { label = 'EMS', requireDuty = true },
    ems = { label = 'EMS', requireDuty = true },

    fire = { label = 'FIRE', requireDuty = true },
    firedept = { label = 'FIRE', requireDuty = true },
    safd = { label = 'FIRE', requireDuty = true },
  },

  SpawnCosts = {
    Default = 750,
    Classes = {
      [0] = 300, [1] = 400, [2] = 500, [3] = 500, [4] = 650,
      [5] = 800, [6] = 900, [7] = 1250, [8] = 350, [9] = 600,
      [10] = 750, [11] = 600, [12] = 550, [13] = 100, [14] = 1000,
      [15] = 2500, [16] = 3500, [17] = 250, [18] = 250, [19] = 3000,
      [20] = 950, [21] = 0, [22] = 1100,
    },
    JobMultipliers = {
      police = 0.25, sheriff = 0.25, bcso = 0.25, sasp = 0.25, state = 0.25, lspd = 0.25,
      ambulance = 0.25, ems = 0.25,
      fire = 0.25, firedept = 0.25, safd = 0.25,
    }
  },

  MoneyAccountOrder = { 'bank', 'cash' },
  SplitPayment = true,

  Keys = {
    ClientSetOwnerEvent = 'vehiclekeys:client:SetOwner',
    UseServerAcquireEvent = false,
    ServerAcquireEvent = 'qb-vehiclekeys:server:AcquireVehicleKeys',
  },

  Audit = {
    Enabled = true,
    PrintToConsole = true,
    Webhook = '',
  }
}

Config.LegacyVMenu = {
  autoImportSavedVehicles = true,
  vehiclePrefix = 'veh_',
}
