(() => {
  const DATA = window.VMENU_UI_DATA || {};
  const shell = document.getElementById('shell');
  const menuHeader = document.getElementById('menuHeader');
  const menuTitleEl = document.getElementById('menuTitle');
  const menuCountEl = document.getElementById('menuCount');
  const menuListEl = document.getElementById('menuList');
  const descriptionTextEl = document.getElementById('descriptionText');
  const closeBtn = document.getElementById('closeBtn');
  const toastEl = document.getElementById('toast');
  const brandText = document.getElementById('brandText');
  const bannerLogo = document.getElementById('bannerLogo');
  const modal = document.getElementById('modal');
  const modalTitle = document.getElementById('modalTitle');
  const modalFields = document.getElementById('modalFields');
  const modalDisplayWrap = document.getElementById('modalDisplayWrap');
  const modalDisplayText = document.getElementById('modalDisplayText');
  const modalCopy = document.getElementById('modalCopy');
  const modalCancel = document.getElementById('modalCancel');
  const modalSubmit = document.getElementById('modalSubmit');

  const themes = {
    blue: { t1: 'rgba(15,78,168,0.92)', t2: 'rgba(28,116,217,0.88)', t3: 'rgba(62,156,255,0.82)', title: '#0da7ff', count: '#4aa9ff' },
    red: { t1: 'rgba(120,18,28,0.92)', t2: 'rgba(183,38,52,0.88)', t3: 'rgba(228,91,91,0.84)', title: '#ff6161', count: '#ff8a8a' },
    green: { t1: 'rgba(16,88,61,0.92)', t2: 'rgba(24,136,95,0.88)', t3: 'rgba(66,204,138,0.84)', title: '#5ff0af', count: '#95ffc9' },
    orange: { t1: 'rgba(132,70,7,0.92)', t2: 'rgba(214,112,13,0.88)', t3: 'rgba(255,170,65,0.84)', title: '#ffa63e', count: '#ffc06f' },
    purple: { t1: 'rgba(69,29,129,0.92)', t2: 'rgba(114,60,189,0.88)', t3: 'rgba(164,116,255,0.84)', title: '#bc95ff', count: '#d4bcff' }
  };

  function buildPresetMap(snap = getSnapshot()) {
    const configured = (snap.ui && snap.ui.presets) || {};
    const fromConfig = {};
    Object.entries(configured).forEach(([key, preset]) => {
      fromConfig[key] = {
        key,
        label: preset.label || key,
        description: preset.description || `Use the ${key} preset.`,
        t1: preset.t1 || preset.theme1 || themes.blue.t1,
        t2: preset.t2 || preset.theme2 || themes.blue.t2,
        t3: preset.t3 || preset.theme3 || themes.blue.t3,
        title: preset.title || '#ffffff',
        count: preset.count || '#ffffff',
        listBg: preset.listBg || 'rgba(18, 24, 31, 0.72)',
        rowBg: preset.rowBg || 'rgba(34, 41, 50, 0.72)',
        text: preset.text || '#f4f4f4',
        activeBg: preset.activeBg || 'rgba(236, 236, 236, 0.98)',
        activeText: preset.activeText || '#111111',
        border: preset.border || 'rgba(255,255,255,0.06)',
        borderStrong: preset.borderStrong || preset.border || 'rgba(255,255,255,0.12)',
        headerOverlay: preset.headerOverlay || 'linear-gradient(180deg, rgba(255,255,255,0.06), rgba(255,255,255,0))',
        glow: preset.glow || 'none',
        glowStrong: preset.glowStrong || preset.glow || 'none',
        scrollTrack: preset.scrollTrack || 'rgba(8, 12, 18, 0.72)',
        scrollThumb: preset.scrollThumb || preset.t2 || 'rgba(255,255,255,0.22)',
        scrollThumbActive: preset.scrollThumbActive || preset.t3 || preset.t2 || 'rgba(255,255,255,0.34)',
        inputBg: preset.inputBg || 'rgba(255,255,255,0.06)',
        inputBorder: preset.inputBorder || preset.borderStrong || 'rgba(255,255,255,0.12)',
        inputText: preset.inputText || preset.text || '#ffffff',
        modalBg: preset.modalBg || 'rgba(0,0,0,0.94)',
        brandText: preset.brandText || '',
        bannerImage: preset.bannerImage || '',
        bannerLogo: preset.bannerLogo || '',
        effect: preset.effect || ''
      };
    });
    if (Object.keys(fromConfig).length) return fromConfig;
    const fallback = {};
    Object.entries(themes).forEach(([key, preset]) => {
      fallback[key] = {
        key,
        label: key,
        description: `Use the ${key} theme.`,
        t1: preset.t1,
        t2: preset.t2,
        t3: preset.t3,
        title: preset.title,
        count: preset.count,
        listBg: 'rgba(18, 24, 31, 0.72)',
        rowBg: 'rgba(34, 41, 50, 0.72)',
        text: '#f4f4f4',
        activeBg: 'rgba(236, 236, 236, 0.98)',
        activeText: '#111111',
        border: 'rgba(255,255,255,0.06)',
        borderStrong: 'rgba(255,255,255,0.12)',
        headerOverlay: 'linear-gradient(180deg, rgba(255,255,255,0.06), rgba(255,255,255,0))',
        glow: 'none',
        glowStrong: 'none',
        scrollTrack: 'rgba(8, 12, 18, 0.72)',
        scrollThumb: preset.t2,
        scrollThumbActive: preset.t3,
        inputBg: 'rgba(255,255,255,0.06)',
        inputBorder: 'rgba(255,255,255,0.12)',
        inputText: '#ffffff',
        modalBg: 'rgba(0,0,0,0.94)',
        brandText: '',
        bannerImage: '',
        bannerLogo: '',
        effect: ''
      };
    });
    return fallback;
  }

  const VEHICLE_COLOR_NAMES = {
    0: 'Black', 1: 'Graphite', 2: 'Black Steel', 3: 'Dark Silver', 4: 'Silver', 5: 'Blue Silver', 6: 'Rolled Steel', 7: 'Shadow Silver', 8: 'Stone Silver', 9: 'Midnight Silver',
    10: 'Cast Iron Silver', 11: 'Anthracite Black', 12: 'Matte Black', 13: 'Matte Gray', 14: 'Light Gray', 15: 'Util Black', 16: 'Util Black Poly', 17: 'Util Dark Silver', 18: 'Util Silver', 19: 'Util Gun Metal',
    20: 'Util Shadow Silver', 21: 'Worn Black', 22: 'Worn Graphite', 23: 'Worn Silver Gray', 24: 'Worn Silver', 25: 'Worn Blue Silver', 26: 'Worn Shadow Silver', 27: 'Metallic Red', 28: 'Torino Red', 29: 'Formula Red',
    30: 'Blaze Red', 31: 'Graceful Red', 32: 'Garnet Red', 33: 'Desert Red', 34: 'Cabernet Red', 35: 'Candy Red', 36: 'Sunrise Orange', 37: 'Classic Gold', 38: 'Orange', 39: 'Matte Red',
    40: 'Matte Dark Red', 41: 'Matte Orange', 42: 'Matte Yellow', 43: 'Util Red', 44: 'Util Bright Red', 45: 'Util Garnet Red', 46: 'Worn Red', 47: 'Worn Golden Red', 48: 'Worn Dark Red', 49: 'Dark Green',
    50: 'Racing Green', 51: 'Sea Green', 52: 'Olive Green', 53: 'Bright Green', 54: 'Gasoline Green', 55: 'Matte Lime Green', 56: 'Util Dark Green', 57: 'Util Green', 58: 'Worn Dark Green', 59: 'Worn Green',
    60: 'Worn Sea Wash', 61: 'Metallic Midnight Blue', 62: 'Metallic Dark Blue', 63: 'Saxony Blue', 64: 'Blue', 65: 'Mariner Blue', 66: 'Harbor Blue', 67: 'Diamond Blue', 68: 'Surf Blue', 69: 'Nautical Blue',
    70: 'Ultra Blue', 71: 'Schafter Purple', 72: 'Spinnaker Purple', 73: 'Racing Blue', 74: 'Light Blue', 75: 'Util Midnight Blue', 76: 'Util Blue', 77: 'Util Sea Foam Blue', 78: 'Util Lightning Blue', 79: 'Util Maui Blue Poly',
    80: 'Util Bright Blue', 81: 'Matte Dark Blue', 82: 'Matte Blue', 83: 'Matte Midnight Blue', 84: 'Worn Dark Blue', 85: 'Worn Blue', 86: 'Worn Light Blue', 87: 'Metallic Taxi Yellow', 88: 'Metallic Race Yellow', 89: 'Metallic Bronze',
    90: 'Metallic Yellow Bird', 91: 'Metallic Lime', 92: 'Metallic Champagne', 93: 'Metallic Pueblo Beige', 94: 'Metallic Dark Ivory', 95: 'Metallic Choco Brown', 96: 'Metallic Golden Brown', 97: 'Metallic Light Brown', 98: 'Metallic Straw Beige', 99: 'Metallic Moss Brown',
    100: 'Metallic Biston Brown', 101: 'Metallic Beechwood', 102: 'Metallic Dark Beechwood', 103: 'Metallic Choco Orange', 104: 'Metallic Beach Sand', 105: 'Metallic Sun Bleeched Sand', 106: 'Metallic Cream', 107: 'Util Brown', 108: 'Util Medium Brown', 109: 'Util Light Brown',
    110: 'Metallic White', 111: 'Metallic Frost White', 112: 'Worn Honey Beige', 113: 'Worn Brown', 114: 'Worn Dark Brown', 115: 'Worn Straw Beige', 116: 'Brushed Steel', 117: 'Brushed Black Steel', 118: 'Brushed Aluminium', 119: 'Chrome',
    120: 'Worn Off White', 121: 'Util Off White', 122: 'Worn Orange', 123: 'Worn Light Orange', 124: 'Metallic Securicor Green', 125: 'Worn Taxi Yellow', 126: 'Police Car Blue', 127: 'Matte Green', 128: 'Matte Brown', 129: 'Worn Orange',
    130: 'Matte White', 131: 'Worn White', 132: 'Worn Olive Army Green', 133: 'Pure White', 134: 'Hot Pink', 135: 'Salmon Pink', 136: 'Metallic Vermillion Pink', 137: 'Orange', 138: 'Green', 139: 'Blue',
    140: 'Metallic Black Blue', 141: 'Metallic Black Purple', 142: 'Metallic Black Red', 143: 'Hunter Green', 144: 'Metallic Purple', 145: 'Metallic V Dark Blue', 146: 'Modshop Black 1', 147: 'Matte Purple', 148: 'Matte Dark Purple', 149: 'Metallic Lava Red',
    150: 'Matte Forest Green', 151: 'Matte Olive Drab', 152: 'Matte Desert Brown', 153: 'Matte Desert Tan', 154: 'Matte Foilage Green', 155: 'Default Alloy', 156: 'Epsilon Blue', 157: 'Pure Gold', 158: 'Brushed Gold', 159: 'Mettalic', 160: 'Unknown'
  };

  const COLOR_PRESETS = Array.from({ length: 161 }, (_, id) => ({
    id,
    label: `${String(id).padStart(3, '0')} - ${VEHICLE_COLOR_NAMES[id] || `Color ${id}`}`
  }));

  const COLOR_GROUPS = [
    { id: 'classic', label: 'Classic' },
    { id: 'metallic', label: 'Metallic' },
    { id: 'matte', label: 'Matte' },
    { id: 'metal', label: 'Metal' },
    { id: 'util', label: 'Util' },
    { id: 'worn', label: 'Worn' }
  ];

  const getColorGroupEntries = (groupId) => COLOR_PRESETS.filter(entry => {
    const name = String(VEHICLE_COLOR_NAMES[entry.id] || '');
    if (groupId === 'classic') return !/^(Metallic|Matte|Util|Worn|Brushed)/.test(name) && !['Chrome', 'Pure Gold', 'Brushed Gold'].includes(name);
    if (groupId === 'metallic') return /^Metallic/.test(name);
    if (groupId === 'matte') return /^Matte/.test(name);
    if (groupId === 'metal') return /^Brushed/.test(name) || ['Chrome', 'Pure Gold', 'Brushed Gold'].includes(name);
    if (groupId === 'util') return /^Util/.test(name);
    if (groupId === 'worn') return /^Worn/.test(name);
    return true;
  });

  const vehicleColorValueForTarget = (snap, target) => {
    const veh = (snap.vehicle || {});
    if (target === 'primary') return veh.primaryColor ?? 0;
    if (target === 'secondary') return veh.secondaryColor ?? 0;
    if (target === 'pearlescent') return veh.pearlescentColor ?? 0;
    if (target === 'wheel') return veh.wheelColor ?? 0;
    if (target === 'dashboard') return veh.dashboardColor ?? 0;
    if (target === 'interior') return veh.interiorColor ?? 0;
    return 0;
  };

  const vehicleColorActionForTarget = (target) => {
    if (target === 'primary') return 'setVehiclePrimaryColor';
    if (target === 'secondary') return 'setVehicleSecondaryColor';
    if (target === 'pearlescent') return 'setVehiclePearlescentColor';
    if (target === 'wheel') return 'setVehicleWheelColor';
    if (target === 'dashboard') return 'setVehicleDashboardColor';
    if (target === 'interior') return 'setVehicleInteriorColor';
    return 'setVehiclePrimaryColor';
  };

  const WINDOW_TINTS = [
    { id: -1, label: 'Stock / None' },
    { id: 0, label: 'None' },
    { id: 1, label: 'Pure Black' },
    { id: 2, label: 'Dark Smoke' },
    { id: 3, label: 'Light Smoke' },
    { id: 4, label: 'Stock' },
    { id: 5, label: 'Limo' },
    { id: 6, label: 'Green' }
  ];

  const WHEEL_TYPES = [
    { id: 0, label: 'Sport' }, { id: 1, label: 'Muscle' }, { id: 2, label: 'Lowrider' }, { id: 3, label: 'SUV' }, { id: 4, label: 'Offroad' },
    { id: 5, label: 'Tuner' }, { id: 6, label: 'Bike Wheels' }, { id: 7, label: 'High End' }, { id: 8, label: 'Benny Originals' }, { id: 9, label: 'Benny Bespoke' },
    { id: 10, label: 'Open Wheel' }, { id: 11, label: 'Street' }, { id: 12, label: 'Track' }
  ];

  const XENON_COLORS = [
    { id: 255, label: 'Default Xenon' }, { id: 0, label: 'White' }, { id: 1, label: 'Blue' }, { id: 2, label: 'Electric Blue' },
    { id: 3, label: 'Mint Green' }, { id: 4, label: 'Lime Green' }, { id: 5, label: 'Yellow' }, { id: 6, label: 'Golden Shower' },
    { id: 7, label: 'Orange' }, { id: 8, label: 'Red' }, { id: 9, label: 'Pony Pink' }, { id: 10, label: 'Hot Pink' },
    { id: 11, label: 'Purple' }, { id: 12, label: 'Blacklight' }
  ];

  const NEON_POSITIONS = [
    { id: 0, label: 'Left Neon' },
    { id: 1, label: 'Right Neon' },
    { id: 2, label: 'Front Neon' },
    { id: 3, label: 'Back Neon' }
  ];

  const COLOR_RGB_PRESETS = [
    { label: 'White', rgb: [255, 255, 255] },
    { label: 'Ice Blue', rgb: [120, 190, 255] },
    { label: 'Blue', rgb: [40, 90, 255] },
    { label: 'Mint', rgb: [90, 255, 200] },
    { label: 'Green', rgb: [0, 255, 70] },
    { label: 'Lime', rgb: [170, 255, 0] },
    { label: 'Yellow', rgb: [255, 230, 0] },
    { label: 'Orange', rgb: [255, 140, 0] },
    { label: 'Red', rgb: [255, 30, 30] },
    { label: 'Pink', rgb: [255, 80, 180] },
    { label: 'Purple', rgb: [180, 70, 255] },
    { label: 'Blacklight', rgb: [60, 0, 255] }
  ];

  const VEHICLE_MOD_NAMES = {
    0: 'Spoilers', 1: 'Front Bumper', 2: 'Rear Bumper', 3: 'Side Skirt', 4: 'Exhaust', 5: 'Frame', 6: 'Grille', 7: 'Hood', 8: 'Left Fender', 9: 'Right Fender',
    10: 'Roof', 11: 'Engine', 12: 'Brakes', 13: 'Transmission', 14: 'Horn', 15: 'Suspension', 16: 'Armor', 23: 'Front Wheels', 24: 'Back Wheels', 25: 'Plate Holder',
    26: 'Vanity Plates', 27: 'Trim A', 28: 'Ornaments', 29: 'Dashboard', 30: 'Dial', 31: 'Door Speaker', 32: 'Seats', 33: 'Steering Wheel', 34: 'Shifter Levers',
    35: 'Plaques', 36: 'Speakers', 37: 'Trunk', 38: 'Hydraulics', 39: 'Engine Block', 40: 'Air Filter', 41: 'Struts', 42: 'Arch Cover', 43: 'Antennas',
    44: 'Trim B', 45: 'Tank', 46: 'Windows', 48: 'Livery'
  };

  const state = {
    open: false,
    snapshot: null,
    stack: [{ id: 'main' }],
    selected: 0,
    toastTimer: null,
    modalOpen: false,
    modalResolver: null,
    modalCopyText: '',
    modalMode: 'form'
  };

  const nui = async (name, payload = {}) => {
    if (typeof GetParentResourceName !== 'function') return null;
    const res = await fetch(`https://${GetParentResourceName()}/${name}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json; charset=UTF-8' },
      body: JSON.stringify(payload)
    });
    return res.json();
  };

  const showToast = (msg) => {
    if (!msg) return;
    toastEl.textContent = msg;
    toastEl.classList.remove('hidden');
    clearTimeout(state.toastTimer);
    state.toastTimer = setTimeout(() => toastEl.classList.add('hidden'), 3200);
  };

  const copyTextToClipboard = async (text) => {
    if (!text) return false;
    try {
      if (navigator.clipboard?.writeText) {
        await navigator.clipboard.writeText(text);
        return true;
      }
    } catch {}
    try {
      modalDisplayText.value = text;
      modalDisplayText.focus();
      modalDisplayText.select();
      return document.execCommand('copy');
    } catch {
      return false;
    }
  };

  const openModal = ({ title, fields }) => {
    state.modalOpen = true;
    state.modalMode = 'form';
    state.modalCopyText = '';
    modal.classList.remove('hidden');
    modalTitle.textContent = title || 'Input';
    modalFields.classList.remove('hidden');
    modalDisplayWrap.classList.add('hidden');
    modalCopy.classList.add('hidden');
    modalSubmit.classList.remove('hidden');
    modalSubmit.textContent = 'Confirm';
    modalCancel.textContent = 'Cancel';
    modalFields.innerHTML = (fields || []).map((field, idx) => {
      const inputType = String(field.type || 'text').toLowerCase();
      const isTextArea = field.multiline === true || inputType === 'textarea';
      const commonAttrs = `data-field="${field.name}" placeholder="${field.placeholder || ''}" ${idx === 0 ? 'autofocus' : ''}`;
      if (isTextArea) {
        return `
      <label>
        <span>${field.label}</span>
        <textarea ${commonAttrs} rows="${Math.max(3, Number(field.rows || 4))}">${field.value ?? ''}</textarea>
      </label>
    `;
      }
      return `
      <label>
        <span>${field.label}</span>
        <input ${commonAttrs} type="${field.type || 'text'}" value="${field.value ?? ''}">
      </label>
    `;
    }).join('');
    if (typeof GetParentResourceName === 'function') nui('setModalInputMode', { enabled: true });
    const first = modalFields.querySelector('input, textarea');
    if (first) {
      setTimeout(() => {
        first.focus();
        if (typeof first.select === 'function') first.select();
      }, 10);
    }
    return new Promise((resolve) => {
      state.modalResolver = resolve;
    });
  };

  const requestPromptInput = async ({ title, fields }) => openModal({ title, fields });

  const openDisplayModal = ({ title, text, copyText }) => {
    state.modalOpen = true;
    state.modalMode = 'display';
    state.modalCopyText = copyText || text || '';
    modal.classList.remove('hidden');
    modalTitle.textContent = title || 'Details';
    modalFields.classList.add('hidden');
    modalDisplayWrap.classList.remove('hidden');
    modalDisplayText.value = text || '';
    modalCopy.classList.toggle('hidden', !state.modalCopyText);
    modalSubmit.classList.add('hidden');
    modalCancel.textContent = 'Close';
    if (typeof GetParentResourceName === 'function') nui('setModalInputMode', { enabled: true });
    setTimeout(() => { modalDisplayText.focus(); modalDisplayText.select(); }, 10);
  };

  const closeModal = (submit) => {
    if (!state.modalOpen) return;
    const values = {};
    if (state.modalMode === 'form') {
      modalFields.querySelectorAll('input, textarea').forEach(input => {
        const rawValue = input.value ?? '';
        values[input.dataset.field] = input.type === 'number' ? Number(rawValue || 0) : rawValue;
      });
    }
    modal.classList.add('hidden');
    state.modalOpen = false;
    if (typeof GetParentResourceName === 'function') nui('setModalInputMode', { enabled: false });
    const resolver = state.modalResolver;
    state.modalResolver = null;
    if (resolver) resolver(submit ? values : null);
  };

  modalCancel.addEventListener('click', () => closeModal(false));
  modalSubmit.addEventListener('click', () => closeModal(true));
  modalCopy.addEventListener('click', async () => {
    const ok = await copyTextToClipboard(state.modalCopyText);
    showToast(ok ? 'Copied.' : 'Copy failed. Select the text manually.');
  });
  if (closeBtn) closeBtn.addEventListener('click', () => closeUi());

  function getSnapshot() {
    return state.snapshot || { toggles: {}, values: {}, players: [], registeredCommands: [], savedVehicles: [], savedPeds: [], savedOutfits: [], loadouts: [], vehicle: { extras: [] }, vehicleCatalog: [], ui: {} };
  }

  function getPermissions() {
    return getSnapshot().permissions || { canEdit: false, principals: [], aces: [], commonGroups: [] };
  }

  function frameworkInfo(snap = getSnapshot()) {
    const qb = snap.qb || {};
    const raw = String(qb.frameworkLabel || qb.label || qb.frameworkName || qb.framework || '').trim();
    const key = String(qb.framework || qb.frameworkName || raw || '').toLowerCase();
    let label = raw || 'Framework';
    const l = label.toLowerCase();
    if (key === 'az' || l.includes('az-framework') || l.includes('az framework') || l.includes('azure')) label = 'Azure Framework';
    else if (key === 'nd' || l.includes('nd_core') || l.includes('nd-core') || l.includes('ndcore')) label = 'NDCore';
    else if (key === 'qb' || key === 'qbcore' || l.includes('qbcore') || l.includes('qb-core')) label = 'QBCore';
    return {
      label,
      menuLabel: `${label} Management`,
      upper: `${label} Management`.toUpperCase(),
      resource: qb.resource || '',
      started: qb.coreStarted === true,
      canAccess: qb.canAccessMenu === true
    };
  }

  function setNavGuard(ms = 120) {
    state.navGuardUntil = Date.now() + ms;
  }

  function navGuardActive() {
    return Date.now() < (state.navGuardUntil || 0);
  }

  function scrollActiveIntoView(forceTop = false) {
    if (!menuListEl) return;
    if (forceTop) menuListEl.scrollTop = 0;
    const active = menuListEl.querySelector('.menu-item.active');
    if (active) active.scrollIntoView({ block: forceTop ? 'start' : 'nearest' });
  }

  const baseMenus = {
    main: () => ({
      title: 'Main Menu',
      items: [
        { label: 'NoClip (F2)', type: 'toggle', key: 'noclip', description: 'Toggle noclip instantly. F2 also toggles it directly.' },
        { label: 'Online Players', submenu: 'onlinePlayers', description: 'Player tools and moderation options.' },
        { label: 'Player Related Options', submenu: 'playerRelated', description: 'NoClip, player options, appearance, and weapon menus.' },
        { label: 'Vehicle Related Options', submenu: 'vehicleRelated', description: 'Vehicle controls, spawner, saved vehicles, and personal vehicle tools.' },
        { label: 'World Options', submenu: 'worldOptions', description: 'Server-synced time and weather controls.' },
        { label: 'Misc Settings', submenu: 'miscSettings', description: 'Teleport, developer tools, voice, menu settings, and extras.' },
        ...(getPermissions().canEdit ? [{ label: 'Permissions Editor', submenu: 'permissionsEditor', description: 'Edit permissions.cfg style principals and ACE rules live.' }] : [])
      ]
    }),
    about: () => ({
      title: 'About',
      items: [
        { label: 'Custom AMenu-style UI', type: 'info', description: 'This build uses a live NUI plus client/server Lua actions.' },
        { label: 'Open Keybind', type: 'info', description: 'Press M or use /amenuui.' },
        { label: 'Vehicle Catalog', type: 'info', description: `${(getSnapshot().vehicleCatalog || []).reduce((a, c) => a + (c.count || 0), 0)} registered vehicle models detected.` }
      ]
    }),
    playerRelated: () => ({
      title: 'PLAYER OPTIONS',
      items: [
        { label: 'NoClip (F2)', type: 'toggle', key: 'noclip', description: 'Toggle noclip movement. F2 also toggles it directly.' },
        { label: 'Player Options', submenu: 'playerOptions', description: 'Health, stamina, wanted, and utility toggles.' },
        { label: 'Player Appearance', submenu: 'playerAppearance', description: 'Ped spawning, saved peds, and MP ped outfit share codes.' },
        { label: 'Weapon Options', submenu: 'weaponOptions', description: 'Give weapons, ammo toggles, and per-category weapons.' },
        { label: 'Weapon Loadouts', submenu: 'weaponLoadouts', description: 'Save, equip, and delete weapon loadouts.' }
      ]
    }),
    playerOptions: () => ({
      title: 'PLAYER OPTIONS',
      items: [
        { label: 'God Mode', type: 'toggle', key: 'god', description: 'Keep your ped invincible.' },
        { label: 'Invisible', type: 'toggle', key: 'invisible', description: 'Hide your ped from view.' },
        { label: 'Unlimited Stamina', type: 'toggle', key: 'unlimitedStamina', description: 'Continuously restore stamina.' },
        { label: 'Fast Run', type: 'toggle', key: 'fastRun', description: 'Increase run speed.' },
        { label: 'Fast Swim', type: 'toggle', key: 'fastSwim', description: 'Increase swim speed.' },
        { label: 'Super Jump', type: 'toggle', key: 'superJump', description: 'Apply super jump each frame.' },
        { label: 'No Ragdoll', type: 'toggle', key: 'noRagdoll', description: 'Prevent ragdoll reactions.' },
        { label: 'Never Wanted', type: 'toggle', key: 'neverWanted', description: 'Keep wanted level cleared.' },
        { label: 'Ignored By Everyone', type: 'toggle', key: 'ignored', description: 'AI and police ignore you.' },
        { label: 'Stay In Vehicle', type: 'toggle', key: 'stayInVehicle', description: 'Prevent exit through common controls.' },
        { label: 'Freeze Player', type: 'toggle', key: 'freezePlayer', description: 'Freeze or unfreeze your ped.' },
        { label: 'Heal Player', type: 'action', action: 'heal', description: 'Restore your health.' },
        { label: 'Max Armor', type: 'action', action: 'maxArmor', description: 'Set armor to 100.' },
        { label: 'Set Wanted Level', type: 'prompt', action: 'setWantedLevel', description: 'Choose a wanted level from 0 to 5.', fields: [{ name: 'level', label: 'Wanted level (0-5)', type: 'number', value: 0 }] },
        { label: 'Vehicle Auto Pilot', submenu: 'autopilotOptions', description: 'Drive to waypoint or wander while in a vehicle.' }
      ]
    }),
    autopilotOptions: () => ({
      title: 'AUTO PILOT',
      items: [
        { label: 'Drive To Waypoint', type: 'action', action: 'driveToWaypoint', description: 'Drive your current vehicle to the waypoint.' },
        { label: 'Drive Around Randomly', type: 'action', action: 'driveRandom', description: 'Wander around with the current vehicle.' },
        { label: 'Stop Driving', type: 'action', action: 'stopDriving', description: 'Clear the ped task.' },
        { label: 'Cruise Style 786603', type: 'action', action: 'setDrivingStyle', value: 786603, description: 'Balanced default cruise style.' },
        { label: 'Rush Style 1074528293', type: 'action', action: 'setDrivingStyle', value: 1074528293, description: 'More aggressive drive style.' }
      ]
    }),
    playerAppearance: () => ({
      title: 'PLAYER APPEARANCE',
      items: [
        { label: 'Spawn Ped By Model', type: 'prompt', action: 'spawnPed', description: 'Enter a ped model name.', fields: [{ name: 'model', label: 'Ped model', value: DATA.pedSuggestions?.[0] || 'mp_m_freemode_01' }] },
        { label: 'Save Current Ped', type: 'prompt', action: 'savePed', description: 'Save your current ped model for later.', fields: [{ name: 'name', label: 'Save name', value: 'My Ped' }] },
        { label: 'Saved Peds', submenu: 'savedPeds', description: 'Load or delete saved ped entries.' },
        { label: 'MP Ped Outfits', submenu: 'mpPedOutfits', description: 'Save outfits and use outfit share codes.' },
        { label: 'Addon Peds', submenu: 'addonPeds', description: 'Spawn peds from addons.json.' },
        ...(DATA.pedSuggestions || []).map(model => ({ label: `Spawn ${model}`, type: 'action', action: 'spawnPedQuick', value: model, description: `Spawn ${model}.` }))
      ]
    }),
    addonPeds: (ctx, snap) => ({
      title: 'ADDON PEDS',
      items: ((snap.addons || {}).peds || []).length
        ? (snap.addons || {}).peds.map(model => ({ label: `Spawn ${model}`, type: 'action', action: 'spawnPedQuick', value: model, description: model }))
        : [{ label: 'No addon peds configured', type: 'info', description: 'Add entries to addons.json.' }]
    }),
    savedPeds: (ctx, snap) => ({
      title: 'SAVED PEDS',
      items: (snap.savedPeds || []).length
        ? snap.savedPeds.flatMap((ped, index) => ([
            { label: `Load ${ped.name}`, type: 'action', action: 'loadPed', value: index, description: 'Spawn saved model.' },
            { label: `Delete ${ped.name}`, type: 'action', action: 'deletePed', value: index, description: `Delete ${ped.name} from saved peds.` }
          ]))
        : [{ label: 'No saved peds', type: 'info', description: 'Use Save Current Ped first.' }]
    }),
    mpPedOutfits: (ctx, snap) => ({
      title: 'MP PED OUTFITS',
      items: [
        { label: 'Save Current Outfit', type: 'prompt', action: 'saveOutfit', description: 'Save your current clothing/prop setup.', fields: [{ name: 'name', label: 'Outfit name', value: `Outfit ${(snap.savedOutfits || []).length + 1}` }] },
        { label: 'Export Current Outfit Share Code', type: 'action', action: 'exportOutfitCode', description: 'Generate a share code for the current outfit.' },
        { label: 'Import Outfit Share Code', type: 'prompt', action: 'importOutfitCode', description: 'Paste an outfit share code to apply it.', fields: [{ name: 'code', label: 'Outfit share code', value: '' }] },
        ...((snap.savedOutfits || []).length
          ? snap.savedOutfits.flatMap((outfit, index) => ([
              { label: `Load ${outfit.name}`, type: 'action', action: 'loadOutfit', value: index, description: 'Apply this saved outfit.' },
              { label: `Delete ${outfit.name}`, type: 'action', action: 'deleteOutfit', value: index, description: `Delete ${outfit.name}.` }
            ]))
          : [{ label: 'No saved outfits', type: 'info', description: 'Use Save Current Outfit first.' }])
      ]
    }),
    weaponOptions: () => ({
      title: 'WEAPON OPTIONS',
      items: [
        { label: 'Get All Weapons', type: 'action', action: 'giveAllWeapons', description: 'Grant the full generated weapon list.' },
        { label: 'Remove All Weapons', type: 'action', action: 'removeAllWeapons', description: 'Remove every weapon from your ped.' },
        { label: 'Unlimited Ammo', type: 'toggle', key: 'unlimitedAmmo', description: 'Keep ammo topped up for equipped weapons.' },
        { label: 'No Reload', type: 'toggle', key: 'noReload', description: 'Infinite clip on current weapons.' },
        { label: 'Refill Ammo', type: 'action', action: 'refillAmmo', description: 'Refill ammo for the current weapon.' },
        { label: 'Spawn Weapon By Name', type: 'prompt', action: 'giveWeapon', description: 'Enter a weapon spawn name like WEAPON_PISTOL.', fields: [{ name: 'weapon', label: 'Weapon name', value: 'WEAPON_PISTOL' }] },
        { label: 'Addon Weapons', submenu: 'addonWeapons', description: 'Weapons from addons.json.' },
        ...(DATA.weaponCategories || []).map(category => ({ label: category.title, submenu: 'weaponCategory', context: { category: category.title }, description: `${category.items.length} weapons.` }))
      ]
    }),
    addonWeapons: (ctx, snap) => ({
      title: 'ADDON WEAPONS',
      items: ((snap.addons || {}).weapons || []).length
        ? (snap.addons || {}).weapons.map(weapon => ({ label: weapon, type: 'action', action: 'giveWeapon', value: weapon, description: weapon }))
        : [{ label: 'No addon weapons configured', type: 'info', description: 'Add entries to addons.json.' }]
    }),
    weaponCategory: (ctx) => {
      const category = (DATA.weaponCategories || []).find(c => c.title === ctx.category);
      return {
        title: String(ctx.category || 'WEAPONS').toUpperCase(),
        items: ((category && category.items) || []).map(item => ({ label: item.label, type: 'action', action: 'giveWeapon', value: item.weapon, description: item.weapon }))
      };
    },
    weaponLoadouts: (ctx, snap) => ({
      title: 'WEAPON LOADOUTS',
      items: [
        { label: 'Save Current Loadout', type: 'prompt', action: 'saveLoadout', description: 'Save your current detected weapons.', fields: [{ name: 'name', label: 'Loadout name', value: `Loadout ${(snap.loadouts || []).length + 1}` }] },
        ...((snap.loadouts || []).length
          ? snap.loadouts.flatMap((loadout, index) => ([
              { label: `Equip ${loadout.name}`, type: 'action', action: 'equipLoadout', value: index, description: `${loadout.weapons.length} stored weapons.` },
              { label: `Delete ${loadout.name}`, type: 'action', action: 'deleteLoadout', value: index, description: `Delete ${loadout.name}.` }
            ]))
          : [{ label: 'No saved loadouts', type: 'info', description: 'Use Save Current Loadout first.' }])
      ]
    }),
    vehicleRelated: () => ({
      title: 'Vehicle Related Options',
      items: [
        arrowEntry('Vehicle Options', 'vehicleOptions', 'Here you can change common vehicle options, as well as tune & style your vehicle.'),
        arrowEntry('Vehicle Spawner', 'vehicleSpawner', 'Spawn a vehicle by name or choose one from a specific category.'),
        arrowEntry('Saved Vehicles', 'savedVehicles', 'Save new vehicles, or spawn or delete already saved vehicles.'),
        arrowEntry('Personal Vehicle', 'personalVehicle', 'Set a vehicle as your personal vehicle, and control some things about that vehicle when you are not inside.')
      ]
    }),

    vehicleOptions: (ctx, snap) => ({
      title: 'Vehicle Options',
      items: [
        arrowEntry('God Mode Options', 'vehicleGodModeOptions', 'Enable or disable specific damage types.'),
        { label: 'Vehicle God Mode', type: 'toggle', key: 'vehicleGod', description: 'Make the current vehicle invincible.' },
        { label: 'Keep Vehicle Clean', type: 'toggle', key: 'keepClean', description: 'Continuously clean the current vehicle.' },
        { label: 'Repair Vehicle', type: 'action', action: 'repairVehicle', description: 'Repair any visual and physical damage present on your vehicle.' },
        { label: 'Wash Vehicle', type: 'action', action: 'washVehicle', description: 'Clean your vehicle.' },
        { label: 'Set Dirt Level', type: 'prompt', action: 'setVehicleDirtLevel', description: `Current dirt level: ${Number((snap.vehicle || {}).dirtLevel || 0).toFixed(1)}. Enter 0 to 15.`, fields: [{ name: 'dirt', label: 'Dirt level', type: 'number', value: Number((snap.vehicle || {}).dirtLevel || 0).toFixed(1) }] },
        arrowEntry('Mod Menu', 'vehicleMods', 'Tune and customize your vehicle here.'),
        arrowEntry('Vehicle Colors', 'vehicleColors', 'Style your vehicle even further with a full paint menu like AMenu.'),
        arrowEntry('Vehicle Neon Kits', 'vehicleNeons', 'Make your vehicle shine with some fancy neon underglow.'),
        arrowEntry('Vehicle Liveries', 'vehicleLiveries', 'Style your vehicle with fancy liveries.'),
        arrowEntry('Vehicle Extras', 'vehicleExtras', 'Add or remove vehicle components/extras.'),
        { label: 'Toggle Engine On/Off', type: 'action', action: 'toggleEngine', description: 'Turn your engine on or off.' },
        { label: 'Set License Plate Text', type: 'prompt', action: 'setPlate', description: 'Enter a custom license plate for your vehicle.', fields: [{ name: 'plate', label: 'Plate text', value: 'VMENU' }] },
        { label: `License Plate Type (${(snap.vehicle || {}).plateType ?? 0})`, submenu: 'vehiclePlateTypes', description: 'Choose a license plate type and press enter to apply it to your vehicle.' },
        arrowEntry('Vehicle Doors', 'vehicleDoors', 'Open, close, remove and restore vehicle doors here.'),
        arrowEntry('Vehicle Windows', 'vehicleWindows', 'Roll your windows up or down and manage window states.'),
        { label: 'Bike Seatbelt', type: 'toggle', key: 'bikeSeatbelt', description: 'Reduce the chance of being knocked off motorcycles.' },
        { label: 'Speed Limiter', type: 'prompt', action: 'speedLimiter', description: 'Set your vehicle max speed in mph. Enter 0 to clear.', fields: [{ name: 'speed', label: 'Max speed (mph, 0 disables)', type: 'number', value: ((snap.values || {}).speedLimitMph) || 0 }] },
        { label: 'Set Engine Torque Multiplier', type: 'prompt', action: 'setEngineTorqueMultiplier', description: 'Set the engine torque multiplier.', fields: [{ name: 'value', label: 'Torque multiplier', type: 'number', value: 1.0 }] },
        { label: 'Set Engine Power Multiplier', type: 'prompt', action: 'setEnginePowerMultiplier', description: 'Set the engine power multiplier.', fields: [{ name: 'value', label: 'Power multiplier', type: 'number', value: 1.0 }] },
        { label: 'Disable Plane Turbulence', type: 'toggle', key: 'planeTurbulence', description: 'Reduce plane turbulence while flying.' },
        { label: 'Disable Helicopter Turbulence', type: 'toggle', key: 'heliTurbulence', description: 'Reduce helicopter turbulence while flying.' },
        { label: 'Anchor Boat', type: 'toggle', key: 'anchoredBoat', description: 'Toggle anchor state on boats.' },
        { label: 'Flip Vehicle', type: 'action', action: 'flipVehicle', description: 'Sets your current vehicle on all 4 wheels.' },
        { label: 'Toggle Vehicle Alarm', type: 'action', action: 'alarmVehicle', description: 'Starts or stops your vehicle alarm.' },
        { label: 'Cycle Through Vehicle Seats', type: 'action', action: 'cycleVehicleSeat', description: 'Cycle through the available vehicle seats.' },
        arrowEntry('Vehicle Lights', 'vehicleLighting', 'Xenon, neon and tire smoke controls.'),
        arrowEntry('Fix / Destroy Tires', 'tireOptions', 'Fix or destroy a specific vehicle tire, or all of them at once.'),
        { label: 'Destroy Engine', type: 'action', action: 'destroyEngine', description: 'Destroys your vehicle engine.' },
        { label: 'Freeze Vehicle', type: 'toggle', key: 'vehicleFreeze', description: 'Freeze the current vehicle in place.' },
        { label: 'Toggle Vehicle Visibility', type: 'toggle', key: 'vehicleInvisible', description: 'Makes your vehicle visible or invisible until you leave it.' },
        { label: 'Engine Always On', type: 'toggle', key: 'engineAlwaysOn', description: 'Keep the engine running.' },
        { label: 'Infinite Fuel', type: 'toggle', key: 'infiniteFuel', description: 'Keep vehicle fuel level full.' },
        { label: 'Show Vehicle Health', type: 'toggle', key: 'showVehicleHealth', description: 'Draw engine and body health on-screen.' },
        { label: 'Enable Default Radio Station', type: 'toggle', key: 'defaultRadio', description: 'Keep the selected radio station active.' },
        { label: 'Set Default Radio Station', type: 'prompt', action: 'setRadioStation', description: 'Set the default radio station name.', fields: [{ name: 'station', label: 'Station', value: 'OFF' }] },
        { label: 'Disable Siren', type: 'toggle', key: 'sirenOff', description: 'Force the current siren off.' },
        { label: 'No Bike Helmet', type: 'toggle', key: 'noBikeHelmet', description: 'Prevent automatic bike helmets.' },
        { label: 'Flash Highbeams On Honk', type: 'toggle', key: 'flashHighbeamsOnHonk', description: 'Flash highbeams while the horn is active.' },
        { label: 'Delete Vehicle', type: 'action', action: 'deleteVehicle', description: 'Delete your current vehicle.' }
      ]
    }),

    vehicleGodModeOptions: () => ({
      title: 'God Mode Options',
      items: [
        { label: 'Invincible', type: 'toggle', key: 'vehicleGod', description: 'Use Vehicle God Mode above to toggle this option.' },
        { label: 'Engine Damage', type: 'toggle', key: 'protectEngineDamage', description: 'Block engine damage while active.' },
        { label: 'Visual Damage', type: 'toggle', key: 'protectVisualDamage', description: 'Continuously repair visual damage while active.' },
        { label: 'Strong Wheels', type: 'toggle', key: 'strongWheels', description: 'Make tires more resilient.' },
        { label: 'Ramp Damage', type: 'toggle', key: 'rampDamageProtection', description: 'Reduce ramp-style collision damage.' },
        { label: 'Auto Repair', type: 'toggle', key: 'autoRepairVehicle', description: 'Continuously repair the current vehicle.' }
      ]
    }),

    vehicleMods: (ctx, snap) => ({
      title: 'Mod Menu',
      items: [
        { label: `Turbo ${snap.vehicle?.toggles?.turbo ? '[ON]' : '[OFF]'}`, type: 'action', action: 'toggleVehicleMod', value: 18, description: 'Toggle turbo on or off.' },
        { label: `Xenon Headlights ${snap.vehicle?.toggles?.xenon ? '[ON]' : '[OFF]'}`, type: 'action', action: 'toggleVehicleMod', value: 22, description: 'Toggle xenon headlights.' },
        { label: `Tire Smoke ${snap.vehicle?.toggles?.tireSmoke ? '[ON]' : '[OFF]'}`, type: 'action', action: 'toggleVehicleMod', value: 20, description: 'Toggle tire smoke.' },
        { label: `Bullet Proof Tires ${snap.vehicle?.bulletproofTires ? '[ON]' : '[OFF]'}`, type: 'action', action: 'toggleBulletproofTires', description: 'Toggle bullet proof tires.' },
        { label: `Low Grip Tires ${snap.vehicle?.lowGrip ? '[ON]' : '[OFF]'}`, type: 'action', action: 'toggleLowGripTires', description: 'Toggle low grip tires.' },
        arrowEntry('Wheel Type', 'vehicleWheelTypes', `Current wheel type: ${WHEEL_TYPES.find(entry => entry.id === ((snap.vehicle || {}).wheelType ?? 0))?.label || ((snap.vehicle || {}).wheelType ?? 0)}.`),
        arrowEntry('Window Tint', 'vehicleWindowTints', `Current window tint: ${WINDOW_TINTS.find(entry => entry.id === ((snap.vehicle || {}).windowTint ?? 0))?.label || ((snap.vehicle || {}).windowTint ?? 0)}.`),
        arrowEntry('Xenon Colors', 'vehicleXenonColors', `Current xenon color: ${(snap.vehicle || {}).xenonColor ?? 255}.`),
        arrowEntry('Tire Smoke Colors', 'vehicleTyreSmokeColors', `Current tire smoke RGB: ${((snap.vehicle || {}).tyreSmoke || [255,255,255]).join(', ')}.`),
        { label: `Custom Front Wheels ${snap.vehicle?.frontWheelsCustom ? '[ON]' : '[OFF]'}`, type: 'action', action: 'toggleWheelVariation', value: 23, description: 'Toggle custom front wheel variation.' },
        { label: `Custom Rear Wheels ${snap.vehicle?.rearWheelsCustom ? '[ON]' : '[OFF]'}`, type: 'action', action: 'toggleWheelVariation', value: 24, description: 'Toggle custom rear wheel variation.' },
        ...(((snap.vehicle || {}).mods) || []).map(mod => ({
          label: `${VEHICLE_MOD_NAMES[mod.type] || ('Mod ' + mod.type)}`,
          submenu: 'vehicleModCategory',
          context: { modType: mod.type },
          description: `Current: ${mod.current >= 0 ? ('Option ' + (mod.current + 1)) : 'Stock'} | Available options: ${mod.count}.`
        }))
      ]
    }),

    vehicleModCategory: (ctx, snap) => {
      const mod = ((snap.vehicle || {}).mods || []).find(entry => entry.type === ctx.modType);
      return {
        title: (VEHICLE_MOD_NAMES[ctx.modType] || `MOD ${ctx.modType}`).toUpperCase(),
        items: mod
          ? [{ label: 'Stock', type: 'action', action: 'setVehicleMod', value: { modType: ctx.modType, index: -1 }, description: 'Revert this mod slot to stock.' }].concat(Array.from({ length: mod.count }, (_, index) => ({
              label: `${VEHICLE_MOD_NAMES[ctx.modType] || 'Option'} ${index + 1}${mod.current === index ? ' [CURRENT]' : ''}`,
              type: 'action',
              action: 'setVehicleMod',
              value: { modType: ctx.modType, index },
              description: `Install option ${index + 1}.`
            })))
          : [{ label: 'No upgrades available', type: 'info', description: 'This vehicle does not expose upgrades for this category.' }]
      };
    },

    vehiclePlateTypes: (ctx, snap) => ({
      title: 'License Plate Type',
      items: [
        'Blue On White 1','Blue On White 2','Blue On White 3','Yellow On Blue','Yellow On Black','North Yankton','ECola','Las Venturas','Liberty City','LS Car Meet','LS Panic','LS Pounders','Sprunk'
      ].map((label, index) => ({ label: `${label}${((snap.vehicle || {}).plateType === index) ? ' [CURRENT]' : ''}`, type: 'action', action: 'setPlateType', value: index, description: `Set plate type to ${label}.` }))
    }),

    vehicleLighting: (ctx, snap) => ({
      title: 'Vehicle Lights',
      items: [
        { label: `Xenon Headlights ${snap.vehicle?.toggles?.xenon ? '[ON]' : '[OFF]'}`, type: 'action', action: 'toggleVehicleMod', value: 22, description: 'Toggle xenon headlights.' },
        arrowEntry('Xenon Colors', 'vehicleXenonColors', `Current xenon color: ${(snap.vehicle || {}).xenonColor ?? 255}.`),
        { label: `Tire Smoke ${snap.vehicle?.toggles?.tireSmoke ? '[ON]' : '[OFF]'}`, type: 'action', action: 'toggleVehicleMod', value: 20, description: 'Toggle tire smoke.' },
        arrowEntry('Tire Smoke Colors', 'vehicleTyreSmokeColors', `Current tire smoke RGB: ${((snap.vehicle || {}).tyreSmoke || [255,255,255]).join(', ')}.`),
        arrowEntry('Vehicle Neon Kits', 'vehicleNeons', 'Toggle individual neon positions or all at once.')
      ]
    }),

    vehicleWheelTypes: (ctx, snap) => ({
      title: 'Wheel Type',
      items: WHEEL_TYPES.map(entry => ({ label: `${entry.label}${((snap.vehicle || {}).wheelType === entry.id) ? ' [CURRENT]' : ''}`, type: 'action', action: 'setVehicleWheelType', value: entry.id, description: `Set wheel type to ${entry.label}.` }))
    }),

    vehicleWindowTints: (ctx, snap) => ({
      title: 'Window Tint',
      items: WINDOW_TINTS.map(entry => ({ label: `${entry.label}${((snap.vehicle || {}).windowTint === entry.id) ? ' [CURRENT]' : ''}`, type: 'action', action: 'setVehicleWindowTint', value: entry.id, description: `Set window tint to ${entry.label}.` }))
    }),

    vehicleXenonColors: (ctx, snap) => ({
      title: 'Xenon Colors',
      items: XENON_COLORS.map(entry => ({ label: `${entry.label}${((snap.vehicle || {}).xenonColor === entry.id) ? ' [CURRENT]' : ''}`, type: 'action', action: 'setVehicleXenonColor', value: entry.id, description: `Set xenon headlights to ${entry.label}.` }))
    }),

    vehicleTyreSmokeColors: () => ({
      title: 'Tire Smoke Colors',
      items: [
        ...COLOR_RGB_PRESETS.map(entry => ({ label: entry.label, type: 'action', action: 'setTyreSmokeColor', value: { r: entry.rgb[0], g: entry.rgb[1], b: entry.rgb[2] }, description: `Set tire smoke to ${entry.label}.` })),
        { label: 'Custom RGB', type: 'prompt', action: 'setTyreSmokeColor', description: 'Enter a custom tire smoke RGB color.', fields: [{ name: 'r', label: 'Red', type: 'number', value: 255 }, { name: 'g', label: 'Green', type: 'number', value: 255 }, { name: 'b', label: 'Blue', type: 'number', value: 255 }] }
      ]
    }),

    vehicleNeons: (ctx, snap) => ({
      title: 'Vehicle Neon Kits',
      items: [
        { label: 'Toggle All Neons', type: 'action', action: 'toggleAllNeon', description: 'Enable or disable every neon position.' },
        ...NEON_POSITIONS.map(entry => ({ label: `${entry.label}${((snap.vehicle || {}).neonEnabled || [])[entry.id + 1] ? ' [ON]' : ' [OFF]'}`, type: 'action', action: 'toggleNeonPosition', value: entry.id, description: `Toggle ${entry.label.toLowerCase()}.` })),
        ...COLOR_RGB_PRESETS.map(entry => ({ label: `Color: ${entry.label}`, type: 'action', action: 'setNeonColor', value: { r: entry.rgb[0], g: entry.rgb[1], b: entry.rgb[2] }, description: `Set neon color to ${entry.label}.` })),
        { label: 'Custom RGB', type: 'prompt', action: 'setNeonColor', description: 'Enter a custom neon RGB color.', fields: [{ name: 'r', label: 'Red', type: 'number', value: 255 }, { name: 'g', label: 'Green', type: 'number', value: 255 }, { name: 'b', label: 'Blue', type: 'number', value: 255 }] }
      ]
    }),

    vehicleDoors: () => ({
      title: 'Vehicle Doors',
      items: [
        { label: 'Open All Doors', type: 'action', action: 'openAllDoors', description: 'Open every door on the current vehicle.' },
        { label: 'Close All Doors', type: 'action', action: 'closeAllDoors', description: 'Close every door on the current vehicle.' },
        { label: 'Left Front Door', type: 'action', action: 'toggleDoor', value: 0, description: 'Toggle the left front door.' },
        { label: 'Right Front Door', type: 'action', action: 'toggleDoor', value: 1, description: 'Toggle the right front door.' },
        { label: 'Left Rear Door', type: 'action', action: 'toggleDoor', value: 2, description: 'Toggle the left rear door.' },
        { label: 'Right Rear Door', type: 'action', action: 'toggleDoor', value: 3, description: 'Toggle the right rear door.' },
        { label: 'Hood', type: 'action', action: 'toggleDoor', value: 4, description: 'Toggle the hood.' },
        { label: 'Trunk', type: 'action', action: 'toggleDoor', value: 5, description: 'Toggle the trunk.' },
        { label: 'Remove Door', type: 'prompt', action: 'removeDoor', description: 'Break a specific vehicle door.', fields: [{ name: 'door', label: 'Door index', type: 'number', value: 0 }] },
        { label: 'Delete Removed Doors', type: 'action', action: 'restoreDoors', description: 'Repair the vehicle to restore removed doors.' }
      ]
    }),

    vehicleWindows: () => ({
      title: 'Vehicle Windows',
      items: [
        { label: 'Front Left Window', type: 'action', action: 'toggleWindow', value: 0, description: 'Roll the front left window up or down.' },
        { label: 'Front Right Window', type: 'action', action: 'toggleWindow', value: 1, description: 'Roll the front right window up or down.' },
        { label: 'Rear Left Window', type: 'action', action: 'toggleWindow', value: 2, description: 'Roll the rear left window up or down.' },
        { label: 'Rear Right Window', type: 'action', action: 'toggleWindow', value: 3, description: 'Roll the rear right window up or down.' }
      ]
    }),

    vehicleExtras: (ctx, snap) => ({
      title: 'Vehicle Extras',
      items: (((snap.vehicle || {}).extras) || []).length
        ? snap.vehicle.extras.map(extra => ({ label: `Extra ${extra.id}`, type: 'action', action: 'toggleExtra', value: extra.id, description: `Currently ${extra.enabled ? 'enabled' : 'disabled'}.`, right: extra.enabled ? '[x]' : '[ ]' }))
        : [{ label: 'No extras found', type: 'info', description: 'Get in a vehicle that has extras.' }]
    }),

    vehicleColors: (ctx, snap) => ({
      title: 'Vehicle Colors',
      items: [
        arrowEntry('Customize Colors', 'vehicleCustomizeColors', 'Primary and secondary paint, plus pearlescent options.'),
        { label: `Dashboard Color (${(snap.vehicle || {}).dashboardColor ?? 0})`, submenu: 'vehicleDashboardColors', description: 'Set the dashboard color.' },
        { label: `Interior / Trim Color (${(snap.vehicle || {}).interiorColor ?? 0})`, submenu: 'vehicleInteriorColors', description: 'Set the interior / trim color.' },
        { label: `Wheel Color (${(snap.vehicle || {}).wheelColor ?? 0})`, submenu: 'vehicleWheelColors', description: 'Set the wheel paint color.' }
      ]
    }),

    vehicleCustomizeColors: (ctx, snap) => ({
      title: 'Customize Colors',
      items: [
        { label: `Primary Color (${(snap.vehicle || {}).primaryColor ?? 0})`, submenu: 'vehiclePrimaryColors', description: 'Customize the primary color.' },
        { label: `Secondary Color (${(snap.vehicle || {}).secondaryColor ?? 0})`, submenu: 'vehicleSecondaryColors', description: 'Customize the secondary color.' }
      ]
    }),

    vehiclePrimaryColors: (ctx, snap) => ({
      title: 'Primary Color',
      items: [
        { label: `Custom RGB${snap.vehicle?.primaryCustomEnabled ? ` (${(snap.vehicle?.primaryCustomColor || [255,255,255]).join(', ')})` : ''}`, type: 'prompt', action: 'setVehicleCustomPrimaryColor', description: 'Set a custom primary RGB color.', fields: [{ name: 'r', label: 'Red', type: 'number', value: (snap.vehicle?.primaryCustomColor || [255,255,255])[0] || 255 }, { name: 'g', label: 'Green', type: 'number', value: (snap.vehicle?.primaryCustomColor || [255,255,255])[1] || 255 }, { name: 'b', label: 'Blue', type: 'number', value: (snap.vehicle?.primaryCustomColor || [255,255,255])[2] || 255 }] },
        ...(snap.vehicle?.primaryCustomEnabled ? [{ label: 'Clear Custom RGB', type: 'action', action: 'clearVehicleCustomPrimaryColor', description: 'Clear the custom primary RGB color.' }] : []),
        ...COLOR_GROUPS.map(group => ({ label: group.label, submenu: 'vehicleColorGroup', context: { target: 'primary', group: group.id }, description: `${group.label} primary colors.` }))
      ]
    }),

    vehicleSecondaryColors: (ctx, snap) => ({
      title: 'Secondary Color',
      items: [
        { label: `Custom RGB${snap.vehicle?.secondaryCustomEnabled ? ` (${(snap.vehicle?.secondaryCustomColor || [255,255,255]).join(', ')})` : ''}`, type: 'prompt', action: 'setVehicleCustomSecondaryColor', description: 'Set a custom secondary RGB color.', fields: [{ name: 'r', label: 'Red', type: 'number', value: (snap.vehicle?.secondaryCustomColor || [255,255,255])[0] || 255 }, { name: 'g', label: 'Green', type: 'number', value: (snap.vehicle?.secondaryCustomColor || [255,255,255])[1] || 255 }, { name: 'b', label: 'Blue', type: 'number', value: (snap.vehicle?.secondaryCustomColor || [255,255,255])[2] || 255 }] },
        ...(snap.vehicle?.secondaryCustomEnabled ? [{ label: 'Clear Custom RGB', type: 'action', action: 'clearVehicleCustomSecondaryColor', description: 'Clear the custom secondary RGB color.' }] : []),
        { label: `Pearlescent (${(snap.vehicle || {}).pearlescentColor ?? 0})`, submenu: 'vehiclePearlescentColors', description: 'Set the pearlescent paint color.' },
        ...COLOR_GROUPS.map(group => ({ label: group.label, submenu: 'vehicleColorGroup', context: { target: 'secondary', group: group.id }, description: `${group.label} secondary colors.` }))
      ]
    }),

    vehicleColorGroup: (ctx, snap) => {
      const current = vehicleColorValueForTarget(snap, ctx.target);
      const action = vehicleColorActionForTarget(ctx.target);
      const entries = getColorGroupEntries(ctx.group);
      return {
        title: `${String(ctx.target || 'Color').charAt(0).toUpperCase()}${String(ctx.target || 'Color').slice(1)} ${String(ctx.group || '').charAt(0).toUpperCase()}${String(ctx.group || '').slice(1)}`,
        items: entries.map(entry => ({
          label: `${entry.label}${current === entry.id ? ' [CURRENT]' : ''}`,
          type: 'action',
          action,
          value: entry.id,
          description: `Set ${ctx.target} color to ${entry.label}.`
        }))
      };
    },

    vehiclePearlescentColors: (ctx, snap) => ({
      title: 'Pearlescent',
      items: COLOR_PRESETS.map(entry => ({ label: `${entry.label}${((snap.vehicle || {}).pearlescentColor === entry.id) ? ' [CURRENT]' : ''}`, type: 'action', action: 'setVehiclePearlescentColor', value: entry.id, description: `Set pearlescent color ${entry.id}.` }))
    }),

    vehicleWheelColors: (ctx, snap) => ({
      title: 'Wheel Color',
      items: COLOR_PRESETS.map(entry => ({ label: `${entry.label}${((snap.vehicle || {}).wheelColor === entry.id) ? ' [CURRENT]' : ''}`, type: 'action', action: 'setVehicleWheelColor', value: entry.id, description: `Set wheel color ${entry.id}.` }))
    }),

    vehicleDashboardColors: (ctx, snap) => ({
      title: 'Dashboard Color',
      items: COLOR_PRESETS.map(entry => ({ label: `${entry.label}${((snap.vehicle || {}).dashboardColor === entry.id) ? ' [CURRENT]' : ''}`, type: 'action', action: 'setVehicleDashboardColor', value: entry.id, description: `Set dashboard color ${entry.id}.` }))
    }),

    vehicleInteriorColors: (ctx, snap) => ({
      title: 'Interior / Trim Color',
      items: COLOR_PRESETS.map(entry => ({ label: `${entry.label}${((snap.vehicle || {}).interiorColor === entry.id) ? ' [CURRENT]' : ''}`, type: 'action', action: 'setVehicleInteriorColor', value: entry.id, description: `Set interior color ${entry.id}.` }))
    }),

    vehicleLiveries: (ctx, snap) => ({
      title: 'Vehicle Liveries',
      items: Array.from({ length: Math.max((snap.vehicle || {}).liveryCount || 0, (snap.vehicle || {}).modLiveryCount || 0, 0) }, (_, i) => ({ label: `Livery ${i}${(((snap.vehicle || {}).livery === i) || ((snap.vehicle || {}).modLiveryIndex === i)) ? ' [CURRENT]' : ''}`, type: 'action', action: 'setVehicleLivery', value: i, description: `Apply livery ${i}.` })).concat([{ label: 'Clear / Default Livery', type: 'action', action: 'setVehicleLivery', value: -1, description: 'Reset livery where supported.' }])
    }),

    vehicleSpawner: (ctx, snap) => ({
      title: 'VEHICLE SPAWNER',
      items: [
        { label: 'Replace Previous Vehicle', type: 'toggle', key: 'replaceOldVehicle', description: 'Delete your last personal vehicle before spawning a new one.' },
        { label: 'Spawn By Model Name', type: 'prompt', action: 'spawnVehicle', description: 'Spawn any valid vehicle model.', fields: [{ name: 'model', label: 'Vehicle model', value: 'adder' }] },
        { label: 'Common Vehicles', submenu: 'commonVehicles', description: `${(DATA.commonVehicleSpawns || []).length} quick-spawn entries.` },
        ...(((((snap.addons || {}).vehicleCategories || []).length || ((snap.addons || {}).vehicles || []).length) ? [{ label: `Addon Vehicles (${((snap.addons || {}).vehicles || []).length})`, submenu: 'addonVehicles', description: 'Spawn addon vehicles with category support from addons.json.' }] : [])),
        ...(snap.vehicleCatalog || []).filter(group => group.id !== 'Addon Vehicles').map(group => ({ label: `${group.label} (${group.count})`, submenu: 'vehicleClass', context: { classId: group.id }, description: `${group.count} registered vehicle models.` }))
      ]
    }),
    commonVehicles: () => ({
      title: 'COMMON VEHICLES',
      items: (DATA.commonVehicleSpawns || []).map(entry => ({ label: entry.label, type: 'action', action: 'spawnVehicle', value: { model: entry.model }, description: entry.model }))
    }),
    addonVehicles: (ctx, snap) => ({
      title: 'ADDON VEHICLES',
      items: (((snap.addons || {}).vehicleCategories) || []).length
        ? (snap.addons || {}).vehicleCategories.map(group => ({ label: `${group.label} (${group.count})`, submenu: 'addonVehicleCategory', context: { addonCategoryId: group.id }, description: `${group.count} addon vehicle entries.` }))
        : (((snap.addons || {}).vehicles) || []).length
          ? (snap.addons || {}).vehicles.map(model => ({ label: model, type: 'action', action: 'spawnVehicle', value: { model }, description: 'Spawn addon vehicle from addons.json.' }))
          : [{ label: 'No addon vehicles configured', type: 'info', description: 'Add vehicle spawn names to addons.json.' }]
    }),
    addonVehicleCategory: (ctx, snap) => {
      const group = (snap.addons?.vehicleCategories || []).find(g => g.id === ctx.addonCategoryId);
      return {
        title: String(ctx.addonCategoryId || 'ADDON VEHICLES').toUpperCase(),
        items: group
          ? group.models.map(entry => ({ label: entry.label || entry.model, type: 'action', action: 'spawnVehicle', value: { model: entry.model }, description: entry.description || entry.model }))
          : [{ label: 'No addon vehicles found', type: 'info', description: 'Nothing detected for this addon category.' }]
      };
    },
    vehicleClass: (ctx, snap) => {
      const group = (snap.vehicleCatalog || []).find(g => g.id === ctx.classId);
      return {
        title: String(ctx.classId || 'VEHICLES').toUpperCase(),
        items: group ? group.models.map(entry => ({ label: entry.label, type: 'action', action: 'spawnVehicle', value: { model: entry.model }, description: entry.model })) : [{ label: 'No vehicles found', type: 'info', description: 'Nothing detected for this class.' }]
      };
    },
    savedVehicles: (ctx, snap) => ({
      title: 'SAVED VEHICLES',
      items: [
        { label: 'Save Current Vehicle', type: 'prompt', action: 'saveVehicle', description: 'Save the vehicle you are in or near.', fields: [{ name: 'name', label: 'Save name', value: `Vehicle ${(snap.savedVehicles || []).length + 1}` }] },
        { label: 'Import Old .dll AMenu Vehicles', type: 'action', action: 'importLegacyAMenuVehicles', description: 'Pulls old TomGrobbe/AMenu saved vehicles from client KVP entries named veh_*. Safe to press more than once.' },
        ...((snap.savedVehicles || []).length
          ? snap.savedVehicles.flatMap((vehicle, index) => ([
              { label: `Spawn ${vehicle.name}`, type: 'action', action: 'spawnSavedVehicle', value: index, description: `${vehicle.model || vehicle.label || 'saved vehicle'}${vehicle.legacyCategory ? ' | Old AMenu category: ' + vehicle.legacyCategory : ''}` },
              { label: `Delete ${vehicle.name}`, type: 'action', action: 'deleteSavedVehicle', value: index, description: `Delete ${vehicle.name}.` }
            ]))
          : [{ label: 'No saved vehicles', type: 'info', description: 'Use Save Current Vehicle first.' }])
      ]
    }),
    vehicleShareCodes: () => ({
      title: 'VEHICLE SHARE CODES',
      items: [
        { label: 'Export Current Vehicle Share Code', type: 'action', action: 'exportVehicleCode', description: 'Generate a share code for the current vehicle.' },
        { label: 'Import Vehicle Share Code', type: 'prompt', action: 'importVehicleCode', description: 'Paste a vehicle share code to spawn/apply it.', fields: [{ name: 'code', label: 'Vehicle share code', value: '' }] }
      ]
    }),
    personalVehicle: (ctx, snap) => ({
      title: 'PERSONAL VEHICLE',
      items: [
        { label: 'Set Current As Personal', type: 'action', action: 'setPersonalVehicle', description: 'Mark your current vehicle as personal.' },
        { label: 'Toggle Engine', type: 'action', action: 'togglePersonalEngine', description: 'Toggle the personal vehicle engine.' },
        { label: 'Toggle Lights', type: 'action', action: 'togglePersonalLights', description: 'Flash or toggle personal vehicle lights.' },
        { label: 'Lock Doors', type: 'action', action: 'lockPersonalVehicle', description: 'Lock or unlock the personal vehicle.' },
        { label: 'Kick Passengers', type: 'action', action: 'kickPassengers', description: 'Kick non-driver occupants from the personal vehicle.' },
        { label: 'Sound Horn', type: 'action', action: 'hornPersonalVehicle', description: 'Sound the horn.' },
        { label: 'Toggle Alarm', type: 'action', action: 'alarmPersonalVehicle', description: 'Trigger the alarm.' },
        { label: 'Add / Remove Blip', type: 'action', action: 'togglePersonalBlip', description: 'Toggle a map blip for your personal vehicle.' },
        { label: 'Delete Personal Vehicle', type: 'action', action: 'deletePersonalVehicle', description: 'Delete the assigned personal vehicle.' },
        { label: 'Current Personal', type: 'info', description: snap.personalVehicle?.label || 'None set yet.' }
      ]
    }),
    worldOptions: (ctx, snap) => ({
      title: 'WORLD OPTIONS',
      items: (snap.config?.worldControlsEnabled === false)
        ? [
            { label: 'World controls disabled', type: 'info', description: 'Enable Config.World.manageSync and Config.World.allowMenuControls if you want this resource to control time/weather.' }
          ]
        : [
            { label: 'Time Options', submenu: 'timeOptions', description: 'Synced server time controls like AMenu.' },
            { label: 'Weather Options', submenu: 'weatherOptions', description: 'Synced server weather controls like AMenu.' }
          ]
    }),

timeOptions: () => ({
  title: 'TIME OPTIONS',
  items: [
    { label: 'Freeze Time', type: 'toggle', key: 'freezeTime', description: 'Freeze synced server time.' },
    { label: 'Set Custom Time', type: 'prompt', action: 'setTime', description: 'Set an exact synced hour and minute.', fields: [{ name: 'hour', label: 'Hour', type: 'number', value: 12 }, { name: 'minute', label: 'Minute', type: 'number', value: 0 }] },
    ...Array.from({ length: 24 }, (_, hour) => ({ label: `${String(hour).padStart(2, '0')}:00`, type: 'action', action: 'setTime', value: { hour, minute: 0 }, description: `Set time to ${String(hour).padStart(2, '0')}:00.` })),
    ...(DATA.timePresets || []).map(item => ({ label: item.label, type: 'action', action: 'setTime', value: { hour: item.hour, minute: item.minute }, description: `Set time to ${String(item.hour).padStart(2, '0')}:${String(item.minute).padStart(2, '0')}.` }))
  ]
}),
weatherOptions: () => ({
  title: 'WEATHER OPTIONS',
  items: [
    { label: 'Dynamic Weather', type: 'toggle', key: 'dynamicWeather', description: 'Cycle synced weather every few minutes.' },
    { label: 'Blackout', type: 'toggle', key: 'blackout', description: 'Toggle synced blackout state.' },
    { label: 'Remove Clouds', type: 'action', action: 'removeClouds', description: 'Clear cloud hats like AMenu.' },
    { label: 'Randomize Clouds', type: 'action', action: 'randomizeClouds', description: 'Pick a random cloud pattern like AMenu.' },
    ...(DATA.weatherPresets || []).map(item => ({ label: item.label, type: 'action', action: 'setWeather', value: item.value, description: `Set weather to ${item.value}.` }))
  ]
}),
    voiceOptions: () => ({
      title: 'VOICE SETTINGS',
      items: [
        { label: 'Enable Voice Chat', type: 'toggle', key: 'voiceEnabled', description: 'Enable or disable voice chat.' },
        { label: 'Show Current Speaker', type: 'toggle', key: 'showCurrentSpeaker', description: 'Show when you are talking on-screen.' },
        { label: 'Join Staff Voice Channel', type: 'toggle', key: 'staffChannel', description: 'Join or leave mumble channel 99.' },
        { label: 'Voice Range', type: 'cycle', key: 'voiceRangeIndex', options: ['Whisper', 'Normal', 'Shout'], description: 'Cycle your talk proximity range.' }
      ]
    }),
    recordingOptions: () => ({
      title: 'RECORDING OPTIONS',
      items: [
        { label: 'Take Photo', type: 'action', action: 'takePhoto', description: 'Open the GTA photo flow if available.' },
        { label: 'Open Gallery', type: 'action', action: 'openGallery', description: 'Open the Rockstar Editor gallery if available.' },
        { label: 'Start Recording', type: 'action', action: 'startRecording', description: 'Start Rockstar clip recording.' },
        { label: 'Stop Recording', type: 'action', action: 'stopRecording', description: 'Save and stop recording.' },
        { label: 'Open Rockstar Editor', type: 'action', action: 'openEditor', description: 'Open Rockstar Editor if available.' }
      ]
    }),
    miscSettingsLegacy: (ctx, snap) => ({
      title: 'Misc Settings',
      items: [
        { label: 'Teleport Options', submenu: 'teleportOptions', description: 'Teleport utilities and presets.' },
        { label: 'Developer Tools', submenu: 'developerTools', description: 'Coords, entity spawner, and clear-area tools.' },
        { label: 'Menu Settings', submenu: 'menuSettings', description: 'Move the menu, switch theme, and use banner config.' },
        { label: 'Voice Options', submenu: 'voiceOptions', description: 'Voice chat toggles and range settings.' },
        ...(getPermissions().canEdit ? [{ label: 'Permissions Editor', submenu: 'permissionsEditor', description: 'Edit permissions.cfg style principals and ACE rules live.' }] : []),
        { label: 'Recording Options', submenu: 'recordingOptions', description: 'Photo, gallery, recording, and Rockstar Editor controls.' },
        { label: 'About', submenu: 'about', description: 'Information about this custom AMenu-style resource.' },
        { label: 'Disable Private Messages', type: 'toggle', key: 'disablePrivateMessages', description: 'Block incoming private messages from this resource.' },
        { label: 'Disable Controller Support', type: 'toggle', key: 'disableControllerSupport', description: 'Ignore controller navigation for this UI.' },
        { label: 'Show Speed KM/H', type: 'toggle', key: 'showSpeedKmh', description: 'Show vehicle speed in km/h.' },
        { label: 'Show Speed MPH', type: 'toggle', key: 'showSpeedMph', description: 'Show vehicle speed in mph.' },
        { label: 'Location Display', type: 'toggle', key: 'locationDisplay', description: 'Draw your current street/location on-screen.' },
        { label: 'Show Coordinates Overlay', type: 'toggle', key: 'showCoords', description: 'Draw your vector4 coordinates on-screen.' },
        { label: 'Night Vision', type: 'toggle', key: 'nightVision', description: 'Toggle night vision.' },
        { label: 'Thermal Vision', type: 'toggle', key: 'thermalVision', description: 'Toggle thermal vision.' },
        { label: 'Overhead Names', type: 'toggle', key: 'overheadNames', description: 'Draw nearby player names.' },
        { label: 'Player Blips', type: 'toggle', key: 'playerBlips', description: 'Show blips for active players.' },
        { label: 'Restore Appearance', type: 'action', action: 'restoreAppearance', description: 'Restore the appearance snapshot saved on first open.' },
        { label: 'Restore Weapons', type: 'action', action: 'restoreWeapons', description: 'Restore the initial weapons snapshot.' },
        { label: 'Connection Options', type: 'info', description: snap.serverText || 'No extra connection data available.' }
      ]
    }),
    teleportOptions: () => ({
      title: 'TELEPORT OPTIONS',
      items: [
        { label: 'Teleport To Waypoint', type: 'action', action: 'teleportToWaypoint', description: 'Teleport to the active waypoint.' },
        { label: 'Teleport To Coordinates', type: 'prompt', action: 'teleportToCoords', description: 'Enter raw coordinates.', fields: [{ name: 'x', label: 'X', type: 'number', value: 0 }, { name: 'y', label: 'Y', type: 'number', value: 0 }, { name: 'z', label: 'Z', type: 'number', value: 72 }] },
        { label: 'Teleport From vector3 / vector4', type: 'prompt', action: 'teleportToVector', description: 'Paste vector3(...) or vector4(...) text.', fields: [{ name: 'coords', label: 'Vector text', value: 'vector4(0.0, 0.0, 72.0, 0.0)' }] },
        ...(DATA.teleportPresets || []).map(item => ({ label: item.label, type: 'action', action: 'teleportPreset', value: item.coords, description: `${item.coords.join(', ')}` }))
      ]
    }),
    developerTools: () => ({
      title: 'DEVELOPER TOOLS',
      items: [
        { label: 'Show Current Coordinates', type: 'action', action: 'showCoordsText', description: 'Open the current vector3/vector4 coordinates.' },
        { label: 'Copy Vector3', type: 'action', action: 'copyCoordsV3', description: 'Open and copy vector3 coordinates.' },
        { label: 'Copy Vector4', type: 'action', action: 'copyCoordsV4', description: 'Open and copy vector4 coordinates.' },
        { label: 'Spawn Entity By Model', type: 'prompt', action: 'spawnEntity', description: 'Spawn an object by model name.', fields: [{ name: 'model', label: 'Object model', value: DATA.entitySuggestions?.[0] || 'prop_barrier_work05' }] },
        ...(DATA.entitySuggestions || []).map(model => ({ label: `Spawn ${model}`, type: 'action', action: 'spawnEntityQuick', value: model, description: `Spawn ${model}.` })),
        { label: 'Clear Nearby Area', type: 'action', action: 'clearArea', description: 'Clear peds and vehicles nearby.' }
      ]
    }),
    menuSettings: (ctx, snap) => ({
      title: 'MENU SETTINGS',
      items: [
        ...(snap.ui?.allowPositioning !== false ? [
          { label: 'Right Align Menu', type: 'toggle', key: 'rightAlign', description: 'Move the menu to the right side of the screen.' },
          { label: 'Set UI Scale', type: 'prompt', action: 'setMenuScale', description: 'Change UI scale from 0.70 to 1.40.', fields: [{ name: 'scale', label: 'UI scale', type: 'number', value: snap.ui?.scale ?? 1.0 }] },
          { label: 'Set UI Offsets', type: 'prompt', action: 'setMenuOffsets', description: 'Move the menu around the screen.', fields: [{ name: 'x', label: 'Offset X', type: 'number', value: snap.ui?.offsetX ?? 18 }, { name: 'y', label: 'Offset Y', type: 'number', value: snap.ui?.offsetY ?? 18 }] }
        ] : [{ label: 'Menu Position Locked', type: 'info', description: 'This server preset locks position, scale, and alignment.' }]),
        ...(snap.ui?.allowThemeSelection !== false
          ? Object.entries(buildPresetMap(snap)).sort((a, b) => String((a[1] && a[1].label) || a[0]).localeCompare(String((b[1] && b[1].label) || b[0]))).map(([key, preset]) => ({
              label: `Preset: ${preset.label || key}${(snap.ui?.preset || snap.ui?.theme) === key ? ' [ACTIVE]' : ''}`,
              type: 'action',
              action: 'setThemePreset',
              value: key,
              description: preset.description || `Switch to ${key}.`
            }))
          : [{ label: 'Theme Preset Locked', type: 'info', description: 'This server forces one default theme preset for everyone.' }]),
        ...(snap.ui?.allowBannerEditing !== false ? [
          { label: 'Set Banner Image URL', type: 'prompt', action: 'setBannerImageUrl', description: 'Use a direct https image URL or a local html/ path.', fields: [{ name: 'url', label: 'Banner image URL', value: snap.ui?.bannerImage || '' }] },
          { label: 'Set Banner Logo URL', type: 'prompt', action: 'setBannerLogoUrl', description: 'Use a direct https image URL or a local html/ path.', fields: [{ name: 'url', label: 'Banner logo URL', value: snap.ui?.bannerLogo || '' }] },
          { label: 'Set Brand Text', type: 'prompt', action: 'setBrandText', description: 'Set the title text shown in the menu header.', fields: [{ name: 'text', label: 'Brand text', value: snap.ui?.brandText || 'AMenu' }] },
          { label: 'Set Header Height', type: 'prompt', action: 'setHeaderHeight', description: 'Adjust the banner/header height in pixels. Good range: 96 to 128.', fields: [{ name: 'height', label: 'Header height', type: 'number', value: snap.ui?.headerHeight ?? 112 }] },
          { label: `Set Banner Fit Mode [${snap.ui?.bannerFitMode || 'contain'}]`, type: 'submenu', items: [
              { label: 'Contain', type: 'action', action: 'setBannerFitMode', value: 'contain', description: 'Show the entire banner without cropping.' },
              { label: 'Cover', type: 'action', action: 'setBannerFitMode', value: 'cover', description: 'Fill the header area and allow controlled cropping.' },
              { label: 'Stretch', type: 'action', action: 'setBannerFitMode', value: 'stretch', description: 'Stretch the banner to fit the full header.' }
            ] },
          { label: 'Set Banner Position', type: 'prompt', action: 'setBannerPosition', description: 'Examples: center center, center top, center 45%, left center.', fields: [{ name: 'position', label: 'Banner position', value: snap.ui?.bannerPosition || 'center center' }] },
          { label: 'Set Banner Overlay Opacity', type: 'prompt', action: 'setBannerOverlayOpacity', description: 'Dark overlay amount over the banner. Range 0.00 to 0.60.', fields: [{ name: 'opacity', label: 'Overlay opacity', type: 'number', value: snap.ui?.bannerOverlayOpacity ?? 0.04 }] },
          { label: 'Clear Banner Image', type: 'action', action: 'clearBannerImage', description: 'Remove the custom banner image.' },
          { label: 'Clear Banner Logo', type: 'action', action: 'clearBannerLogo', description: 'Remove the custom banner logo.' },
          { label: 'Reset Menu Appearance', type: 'action', action: 'resetMenuAppearance', description: 'Reset theme, banner, logo, and brand text back to defaults.' }
        ] : [{ label: 'Banner Editing Locked', type: 'info', description: 'This server preset does not allow user banner or brand editing.' }]),
        { label: 'Current Brand Text', type: 'info', description: snap.ui?.brandText || 'AMenu' },
        { label: 'Current Header Height', type: 'info', description: `${snap.ui?.headerHeight || 112}px` },
        { label: 'Current Banner Fit Mode', type: 'info', description: snap.ui?.bannerFitMode || 'contain' },
        { label: 'Current Banner Position', type: 'info', description: snap.ui?.bannerPosition || 'center center' },
        { label: 'Current Banner Overlay Opacity', type: 'info', description: String(snap.ui?.bannerOverlayOpacity ?? 0.04) },
        { label: 'Configured Banner Image', type: 'info', description: snap.ui?.bannerImage || 'No banner image configured in config.lua' },
        { label: 'Configured Banner Logo', type: 'info', description: snap.ui?.bannerLogo || 'No banner logo configured in config.lua' }
      ]
    }),
    qbcoreManagement: (ctx, snap) => {
      const qb = snap.qb || {};
      const fw = frameworkInfo(snap);
      if (!qb.enabled) {
        return { title: fw.upper, items: [{ label: 'Framework Bridge Disabled', type: 'info', description: 'Enable the AMenu framework bridge config.' }] };
      }
      if (!qb.coreStarted) {
        return { title: fw.upper, items: [{ label: 'No Active Framework Started', type: 'info', description: 'Start Az-Framework before AMenu-Bridge/AMenu, then re-select your character or restart the server.' }] };
      }
      if (!qb.canAccessMenu) {
        return { title: fw.upper, items: [{ label: 'No Permission', type: 'info', description: 'Grant AMenu.Framework.Admin, AMenu.QBCore.Menu, AMenu.QBCore.All, AMenu.QBCore.Admin, AMenu.Staff, or framework admin permission.' }] };
      }
      const players = qb.players || [];
      return {
        title: fw.upper,
        items: [
          { label: `Refresh ${fw.label} Player List`, type: 'action', action: 'qbRefreshPlayers', description: `Reload players from ${fw.resource || fw.label}.` },
          { label: 'Give Yourself Current Vehicle Keys', type: 'action', action: 'qbGiveSelfKeys', description: `Reads your current/closest vehicle plate and gives you keys through ${fw.label}.` },
          ...(players.length ? players.map(p => ({
            label: `[${p.source}] ${p.name}`,
            submenu: 'qbcorePlayerActions',
            context: p,
            description: `Framework: ${p.framework || fw.label} | CID: ${p.citizenid || 'unknown'} | Job: ${p.job || 'none'} ${p.grade || 0} | ${p.onduty ? 'On Duty' : 'Off Duty'} | Cash: $${p.cash || 0} | Bank: $${p.bank || 0}`
          })) : [{ label: `No ${fw.label} Players Found`, type: 'info', description: `Refresh the list or make sure players are fully loaded into ${fw.label}.` }])
        ]
      };
    },

    qbcorePlayerActions: (ctx, snap) => {
      const fw = frameworkInfo(snap);
      return {
        title: `[${ctx.source || '?'}] ${ctx.name || fw.label + ' Player'}`,
        items: [
          { label: 'Player Info', type: 'action', action: 'qbInfo', context: ctx, description: 'Show citizen ID, job, bank, cash, and active framework.' },
          { label: 'Revive Player', type: 'action', action: 'qbRevive', context: ctx, description: `Runs ${fw.label} revive/fallback revive events on the selected player.` },
          { label: 'Heal Player', type: 'action', action: 'qbHeal', context: ctx, description: 'Heals and clears visible damage on the selected player.' },
          { label: 'Save Player', type: 'action', action: 'qbSave', context: ctx, description: `Runs ${fw.label} save if supported.` },
          { label: 'Set Duty: On', type: 'action', action: 'qbDutyOn', context: ctx, description: `Sets duty on if ${fw.label} supports duty.` },
          { label: 'Set Duty: Off', type: 'action', action: 'qbDutyOff', context: ctx, description: `Sets duty off if ${fw.label} supports duty.` },
          { label: 'Set Job: Police', type: 'action', action: 'qbSetJobPreset', value: { job: 'police', grade: 0 }, context: ctx, description: 'Set job to police grade 0.' },
          { label: 'Set Job: Sheriff', type: 'action', action: 'qbSetJobPreset', value: { job: 'sheriff', grade: 0 }, context: ctx, description: 'Set job to sheriff grade 0.' },
          { label: 'Set Job: State', type: 'action', action: 'qbSetJobPreset', value: { job: 'state', grade: 0 }, context: ctx, description: 'Set job to state grade 0.' },
          { label: 'Set Job: EMS', type: 'action', action: 'qbSetJobPreset', value: { job: 'ambulance', grade: 0 }, context: ctx, description: 'Set job to ambulance grade 0.' },
          { label: 'Set Job: Fire', type: 'action', action: 'qbSetJobPreset', value: { job: 'fire', grade: 0 }, context: ctx, description: 'Set job to fire grade 0.' },
          { label: 'Custom Set Job', type: 'prompt', action: 'qbSetCustomJob', context: ctx, description: `Type a ${fw.label} job/group and grade.`, fields: [{ name: 'job', label: 'Job/group name', value: ctx.job || 'police' }, { name: 'grade', label: 'Grade', type: 'number', value: 0 }] },
          { label: 'Add Cash', type: 'prompt', action: 'qbAddMoney', context: ctx, description: 'Add cash to this player.', fields: [{ name: 'account', label: 'Account', value: 'cash' }, { name: 'amount', label: 'Amount', type: 'number', value: 1000 }] },
          { label: 'Add Bank', type: 'prompt', action: 'qbAddMoney', context: ctx, description: 'Add bank money to this player.', fields: [{ name: 'account', label: 'Account', value: 'bank' }, { name: 'amount', label: 'Amount', type: 'number', value: 1000 }] },
          { label: 'Remove Cash', type: 'prompt', action: 'qbRemoveMoney', context: ctx, description: 'Remove cash from this player.', fields: [{ name: 'account', label: 'Account', value: 'cash' }, { name: 'amount', label: 'Amount', type: 'number', value: 1000 }] },
          { label: 'Remove Bank', type: 'prompt', action: 'qbRemoveMoney', context: ctx, description: 'Remove bank money from this player.', fields: [{ name: 'account', label: 'Account', value: 'bank' }, { name: 'amount', label: 'Amount', type: 'number', value: 1000 }] },
          { label: 'Give Keys For Plate', type: 'prompt', action: 'qbGivePlateKeys', context: ctx, description: 'Give the selected player keys for the plate typed.', fields: [{ name: 'plate', label: 'Vehicle plate', value: '' }] },
          { label: 'Give Current Vehicle Keys', type: 'action', action: 'qbGiveCurrentKeys', context: ctx, description: 'Uses the current/closest vehicle plate near you and gives the selected player keys.' },
          { label: 'Kick Player', type: 'prompt', action: 'qbKick', context: ctx, description: 'Kick the selected player.', fields: [{ name: 'reason', label: 'Kick reason', value: 'Kicked by staff.' }] }
        ]
      };
    },

    onlinePlayers: (ctx, snap) => ({
      title: 'ONLINE PLAYERS',
      items: [
        ...((snap.players || []).map(player => ({ label: `[${player.id}] ${player.name}`, submenu: 'singlePlayer', context: { playerId: player.id, playerName: player.name }, description: 'Open player action menu.' }))),
        { label: 'Banned Players', submenu: 'bannedPlayers', description: 'View active bans and remove them if permitted.' }
      ]
    }),
    singlePlayer: (ctx) => ({
      title: String(ctx.playerName || 'PLAYER').toUpperCase(),
      items: [
        { label: 'Teleport To Player', type: 'action', action: 'teleportToPlayer', value: ctx.playerId, description: 'Teleport to this player.' },
        { label: 'Waypoint To Player', type: 'action', action: 'waypointToPlayer', value: ctx.playerId, description: 'Set waypoint to this player.' },
        { label: 'Spectate Player', type: 'action', action: 'spectatePlayer', value: ctx.playerId, description: 'Toggle spectator mode.' },
        { label: 'Summon Player', type: 'action', action: 'summonPlayer', value: ctx.playerId, description: 'Bring this player to you.' },
        { label: 'Kill Player', type: 'action', action: 'killPlayer', value: ctx.playerId, description: 'Kill this player.' },
        { label: 'Kick Player', type: 'prompt', action: 'kickPlayer', context: ctx, description: 'Kick this player with a reason.', fields: [{ name: 'reason', label: 'Kick reason', value: 'Rule violation' }] },
        { label: 'Temp Ban Player', type: 'prompt', action: 'tempBanPlayer', context: ctx, description: 'Temp ban this player.', fields: [{ name: 'minutes', label: 'Ban length (minutes)', type: 'number', value: 60 }, { name: 'reason', label: 'Ban reason', value: 'Rule violation' }] },
        { label: 'Perm Ban Player', type: 'prompt', action: 'permBanPlayer', context: ctx, description: 'Ban this player permanently.', fields: [{ name: 'reason', label: 'Ban reason', value: 'Rule violation' }] },
        { label: 'Identifiers', type: 'action', action: 'identifiers', value: ctx.playerId, description: 'Open this player\'s identifiers.' },
        { label: 'Send Private Message', type: 'prompt', action: 'sendPrivateMessage', context: ctx, description: 'Send a private message to this player.', fields: [{ name: 'message', label: 'Message', value: 'Hello' }] }
      ]
    }),
    permissionsEditor: (ctx, snap) => ({
      title: 'PERMISSIONS EDITOR',
      items: [
        { label: 'View Permissions Summary', type: 'action', action: 'showPermissionsSummary', description: 'Open a copyable overview of the current principals and ACE rules.' },
        { label: 'Grant Group To Online Player', submenu: 'permissionOnlinePlayers', description: 'Pick an online player and grant or revoke common groups live.' },
        { label: 'Add Principal Rule', type: 'prompt', action: 'addPermissionPrincipal', description: 'Add a permissions.cfg style add_principal rule.', fields: [{ name: 'subject', label: 'Principal / player id / identifier', value: '1' }, { name: 'group', label: 'Group (admin, moderator, builtin.everyone)', value: 'admin' }] },
        { label: 'Remove Principal Rule', type: 'prompt', action: 'removePermissionPrincipal', description: 'Remove a permissions.cfg style add_principal rule.', fields: [{ name: 'subject', label: 'Principal / player id / identifier', value: '1' }, { name: 'group', label: 'Group (admin, moderator, builtin.everyone)', value: 'admin' }] },
        { label: 'Add ACE Rule', type: 'prompt', action: 'addPermissionAce', description: 'Add a permissions.cfg style add_ace rule.', fields: [{ name: 'principal', label: 'Principal (group.admin, builtin.everyone, id)', value: 'group.admin' }, { name: 'ace', label: 'ACE permission', value: 'AMenu.NoClip' }, { name: 'mode', label: 'allow / deny', value: 'allow' }] },
        { label: 'Remove ACE Rule', type: 'prompt', action: 'removePermissionAce', description: 'Remove a permissions.cfg style add_ace rule.', fields: [{ name: 'principal', label: 'Principal (group.admin, builtin.everyone, id)', value: 'group.admin' }, { name: 'ace', label: 'ACE permission', value: 'AMenu.NoClip' }, { name: 'mode', label: 'allow / deny', value: 'allow' }] },
        { label: `Principal Rules (${(snap.permissions?.principals || []).length})`, submenu: 'permissionPrincipals', description: 'Review the currently parsed add_principal rules.' },
        { label: `ACE Rules (${(snap.permissions?.aces || []).length})`, submenu: 'permissionAceRules', description: 'Review the currently parsed add_ace rules.' }
      ]
    }),
    permissionOnlinePlayers: (ctx, snap) => ({
      title: 'ONLINE PLAYERS',
      items: (snap.players || []).length
        ? (snap.players || []).map(player => ({ label: `[${player.id}] ${player.name}`, submenu: 'permissionPlayerEditor', context: { playerId: player.id, playerName: player.name }, description: 'Grant or revoke groups for this online player.' }))
        : [{ label: 'No online players', type: 'info', description: 'There are no players available to edit right now.' }]
    }),
    permissionPlayerEditor: (ctx, snap) => ({
      title: String(ctx.playerName || 'PLAYER').toUpperCase(),
      items: [
        ...((snap.permissions?.commonGroups || ['group.moderator', 'group.admin']).flatMap(group => ([
          { label: `Grant ${group}`, type: 'action', action: 'grantPlayerGroup', value: ctx.playerId, context: { group }, description: `Grant ${group} to this player's persistent identifier.` },
          { label: `Revoke ${group}`, type: 'action', action: 'revokePlayerGroup', value: ctx.playerId, context: { group }, description: `Remove ${group} from this player's persistent identifier.` }
        ]))),
        { label: 'Grant Custom Group', type: 'prompt', action: 'addPermissionPrincipal', description: 'Grant a custom group to this online player.', fields: [{ name: 'subject', label: 'Player id', value: String(ctx.playerId || '') }, { name: 'group', label: 'Group', value: 'admin' }] },
        { label: 'Revoke Custom Group', type: 'prompt', action: 'removePermissionPrincipal', description: 'Revoke a custom group from this online player.', fields: [{ name: 'subject', label: 'Player id', value: String(ctx.playerId || '') }, { name: 'group', label: 'Group', value: 'admin' }] }
      ]
    }),
    permissionPrincipals: (ctx, snap) => ({
      title: 'PRINCIPAL RULES',
      items: (snap.permissions?.principals || []).length
        ? (snap.permissions.principals || []).map(entry => ({ label: `${entry.subject} -> ${entry.group}`, type: 'info', description: 'Use Remove Principal Rule from the editor to delete or change this entry.' }))
        : [{ label: 'No principal rules', type: 'info', description: 'There are no parsed add_principal rules.' }]
    }),
    permissionAceRules: (ctx, snap) => ({
      title: 'ACE RULES',
      items: (snap.permissions?.aces || []).length
        ? (snap.permissions.aces || []).map(entry => ({ label: `${entry.principal} :: ${entry.ace}`, type: 'info', description: `${entry.mode || 'allow'} | Use Remove ACE Rule from the editor to delete or change this entry.` }))
        : [{ label: 'No ACE rules', type: 'info', description: 'There are no parsed add_ace rules.' }]
    }),
    bannedPlayers: (ctx, snap) => ({
      title: 'BANNED PLAYERS',
      items: (snap.bans || []).length
        ? (snap.bans || []).map((ban, index) => ({ label: ban.playerName || `Ban ${index + 1}`, type: 'info', description: `${ban.reason || 'No reason'} | By ${ban.bannedBy || 'unknown'}` }))
        : [{ label: 'No bans loaded', type: 'info', description: 'You may not have permission or there may be no active bans.' }]
    })
  };

  const disabledEntry = (label, description, right = '') => ({ label, type: 'info', description, disabled: true, right });
  const arrowEntry = (label, submenu, description, context = null) => Object.assign({ label, submenu, description }, context ? { context } : {});
  const savedVehicleContext = (vehicle = {}, fallbackIndex = 0) => ({
    vehicleIndex: Number(vehicle.index ?? fallbackIndex ?? 0),
    vehicleName: String(vehicle.name || `Vehicle ${Number(vehicle.index ?? fallbackIndex ?? 0) + 1}`),
    vehicleModel: String(vehicle.model || vehicle.label || 'saved vehicle'),
    vehicleClass: String(vehicle.vehicleClass || 'Unknown'),
    category: String(vehicle.category || vehicle.legacyCategory || 'Uncategorized'),
    legacyCategory: vehicle.legacyCategory || '',
    available: vehicle.available !== false,
    importedFrom: vehicle.importedFrom || ''
  });
  const savedVehicleDescription = (ctx = {}) => `${ctx.vehicleModel || 'Saved vehicle'} | ${ctx.vehicleClass || 'Unknown'} | ${ctx.category || 'Uncategorized'}${ctx.legacyCategory ? ' | Old AMenu category: ' + ctx.legacyCategory : ''}${ctx.available === false ? ' | model unavailable/missing' : ''}`;
  const savedVehicleRow = (vehicle, fallbackIndex = 0) => {
    const ctx = savedVehicleContext(vehicle, fallbackIndex);
    return { label: `${ctx.vehicleName}${ctx.importedFrom ? '  • old AMenu' : ''}${ctx.available === false ? '  • unavailable' : ''}`, submenu: 'savedVehicleActions', context: ctx, description: savedVehicleDescription(ctx) };
  };
  const prettyPedLabel = (model) => String(model || '')
    .replace(/^a_c_/, '')
    .replace(/^mp_/, '')
    .replace(/_/g, ' ')
    .replace(/\b\w/g, c => c.toUpperCase());
  const pedMatches = (model, kind) => {
    const value = String(model || '').toLowerCase();
    if (kind === 'main') return value === 'mp_m_freemode_01' || value === 'mp_f_freemode_01';
    if (kind === 'animals') return value.startsWith('a_c_');
    if (kind === 'female') return value.includes('_f_') || value.startsWith('mp_f_');
    if (kind === 'male') return (value.includes('_m_') || value.startsWith('mp_m_')) && !value.startsWith('mp_f_');
    if (kind === 'other') return !pedMatches(value, 'main') && !pedMatches(value, 'animals') && !pedMatches(value, 'female') && !pedMatches(value, 'male');
    return true;
  };
  const pedItemsForKind = (kind) => {
    const models = (DATA.pedSuggestions || []).filter(model => pedMatches(model, kind));
    if (!models.length) return [disabledEntry('No peds in this category', 'Add more ped suggestions or addon peds to populate this list.')];
    return models.map(model => ({ label: prettyPedLabel(model), type: 'action', action: 'spawnPedQuick', value: model, description: model }));
  };
  const weaponCategoryLookup = {
    'Handguns': 'Handguns',
    'Assault Rifles': 'Assault Rifles',
    'Shotguns': 'Shotguns',
    'Sub-/Light Machine Guns': 'Sub-/Light Machine Guns',
    'Throwables': 'Throwables',
    'Melee': 'Melee',
    'Heavy Weapons': 'Heavy Weapons',
    'Sniper Rifles': 'Sniper Rifles'
  };
  const buildWeaponCategoryItems = (ctx) => {
    const title = weaponCategoryLookup[ctx.category] || ctx.category;
    const category = (DATA.weaponCategories || []).find(c => c.title === title);
    if (!category) return [disabledEntry('No weapons found', 'This category is not populated in menu-data.js.')];
    return (category.items || [])
      .filter(item => !['WEAPON_MENU','WEAPON_ALL','WEAPON_GETALL','WEAPON_REMOVEALL','WEAPON_UNLIMITEDAMMO','WEAPON_NORELOAD','WEAPON_SPAWN','WEAPON_SPAWNBYNAME','WEAPON_SETALLAMMO'].includes(item.weapon))
      .map(item => ({
        label: item.label,
        submenu: 'weaponEntryActions',
        context: { weapon: item.weapon, weaponLabel: item.label },
        description: item.weapon
      }));
  };
  const commonScenarioEntries = [
    ['Smoke', 'WORLD_HUMAN_SMOKING'],
    ['Clipboard', 'WORLD_HUMAN_CLIPBOARD'],
    ['Guard', 'WORLD_HUMAN_GUARD_STAND'],
    ['Janitor', 'WORLD_HUMAN_JANITOR'],
    ['Binoculars', 'WORLD_HUMAN_BINOCULARS'],
    ['Sit Bench', 'PROP_HUMAN_SEAT_BENCH'],
    ['Sit Chair', 'PROP_HUMAN_SEAT_CHAIR'],
    ['Lean', 'WORLD_HUMAN_LEANING'],
    ['Cheer', 'WORLD_HUMAN_CHEERING'],
    ['Film', 'WORLD_HUMAN_MOBILE_FILM_SHOCKING']
  ];

  Object.assign(baseMenus, {
    main: (ctx, snap) => {
      const fw = frameworkInfo(snap);
      return {
      title: 'Main Menu',
      items: [
        arrowEntry('Online Players', 'onlinePlayers', 'All currently connected players.'),
        arrowEntry(fw.menuLabel, 'qbcoreManagement', `${fw.label} player management, jobs, money, duty, revive, heal, and keys.`),
        arrowEntry('Banned Players', 'bannedPlayers', 'View and manage all banned players in this menu.'),
        arrowEntry('Player Related Options', 'playerRelated', 'Open this submenu for player related subcategories.'),
        arrowEntry('Vehicle Related Options', 'vehicleRelated', 'Open this submenu for vehicle related subcategories.'),
        arrowEntry('World Related Options', 'worldRelated', 'Open this submenu for world related subcategories.'),
        arrowEntry('Voice Chat Settings', 'voiceOptions', 'Change voice chat options here.'),
        arrowEntry('Recording Options', 'recordingOptions', 'In-game recording options.'),
        arrowEntry('Misc Settings', 'miscSettings', 'Miscellaneous AMenu options/settings can be configured here. You can also save your settings in this menu.'),
        arrowEntry('About AMenu', 'about', 'Information about AMenu.')
      ]
      };
    },

    about: (ctx, snap) => ({
      title: 'About AMenu',
      items: [
        ...(snap.serverText ? [{ label: 'Server Info', type: 'info', description: snap.serverText }] : []),
        { label: 'AMenu Version', type: 'info', description: 'Lua/NUI recreation matching the uploaded reference structure and flow.' },
        { label: 'About AMenu / Credits', type: 'info', description: 'Reference structure based on the original AMenu layout by Vespura.' }
      ]
    }),

    playerRelated: () => ({
      title: 'Player Related Options',
      items: [
        arrowEntry('Player Options', 'playerOptions', 'Common player options can be accessed here.'),
        arrowEntry('Player Appearance', 'playerAppearance', 'Choose a ped model, customize it and save & load your customized characters.'),
        arrowEntry('MP Ped Customization', 'mpPedCustomization', 'Create, edit, save and load multiplayer peds.'),
        arrowEntry('Weapon Options', 'weaponOptions', 'Add/remove weapons, modify weapons and set ammo options.'),
        arrowEntry('Weapon Loadouts', 'weaponLoadouts', 'Manage, and spawn saved weapon loadouts.'),
        { label: 'Toggle NoClip', type: 'toggle', key: 'noclip', description: 'Toggle NoClip on or off.' }
      ]
    }),

    playerOptions: (ctx, snap) => ({
      title: 'Player Options',
      items: [
        { label: 'Godmode', type: 'toggle', key: 'god', description: 'Keep your ped invincible.' },
        { label: 'Invisible', type: 'toggle', key: 'invisible', description: 'Hide your ped from view.' },
        { label: 'Unlimited Stamina', type: 'toggle', key: 'unlimitedStamina', description: 'Continuously restore stamina.' },
        { label: 'Fast Run', type: 'toggle', key: 'fastRun', description: 'Increase run speed.' },
        { label: 'Fast Swim', type: 'toggle', key: 'fastSwim', description: 'Increase swim speed.' },
        { label: 'Super Jump', type: 'toggle', key: 'superJump', description: 'Apply super jump each frame.' },
        { label: 'No Ragdoll', type: 'toggle', key: 'noRagdoll', description: 'Prevent ragdoll reactions.' },
        { label: 'Never Wanted', type: 'toggle', key: 'neverWanted', description: 'Keep wanted level cleared.' },
        { label: 'Everyone Ignore Player', type: 'toggle', key: 'ignored', description: 'AI and police ignore you.' },
        { label: 'Stay In Vehicle', type: 'toggle', key: 'stayInVehicle', description: 'Prevent exit through common controls.' },
        { label: 'Freeze Player', type: 'toggle', key: 'freezePlayer', description: 'Freeze or unfreeze your ped.' },
        { label: 'Set Wanted Level', type: 'prompt', action: 'setWantedLevel', description: 'Choose a wanted level from 0 to 5.', fields: [{ name: 'level', label: 'Wanted level (0-5)', type: 'number', value: 0 }] },
        { label: 'Set Armor Type', submenu: 'armorTypes', description: 'Apply preset armor values.' },
        { label: 'Heal Player', type: 'action', action: 'heal', description: 'Restore your health.' },
        { label: 'Commit Suicide', type: 'action', action: 'commitSuicide', description: 'Kill your current ped.' },
        arrowEntry('Vehicle Auto Pilot Menu', 'autopilotOptions', 'Vehicle auto pilot options.'),
        arrowEntry('Player Scenarios', 'playerScenarios', 'Play a world scenario animation.'),
        { label: 'Force Stop Scenario', type: 'action', action: 'forceStopScenario', description: 'Clear your current scenario/task.' }
      ]
    }),

    armorTypes: () => ({
      title: 'Set Armor Type',
      items: [
        { label: 'No Armor', type: 'action', action: 'setArmorType', value: 0, description: 'Set armor to 0.' },
        { label: 'Light Armor', type: 'action', action: 'setArmorType', value: 25, description: 'Set armor to 25.' },
        { label: 'Medium Armor', type: 'action', action: 'setArmorType', value: 50, description: 'Set armor to 50.' },
        { label: 'Heavy Armor', type: 'action', action: 'setArmorType', value: 100, description: 'Set armor to 100.' }
      ]
    }),

    autopilotOptions: (ctx, snap) => ({
      title: 'Auto Pilot',
      items: [
        { label: `Driving Style (${snap.values?.drivingStyle ?? 786603})`, type: 'prompt', action: 'setDrivingStyle', description: 'Enter a custom GTA driving style integer.', fields: [{ name: 'style', label: 'Driving style', type: 'number', value: snap.values?.drivingStyle ?? 786603 }] },
        { label: 'Drive To Waypoint', type: 'action', action: 'driveToWaypoint', description: 'Drive your current vehicle to the waypoint.' },
        { label: 'Drive Around Randomly', type: 'action', action: 'driveRandom', description: 'Wander around with the current vehicle.' },
        { label: 'Stop Driving', type: 'action', action: 'stopDriving', description: 'Clear the ped task.' },
        { label: 'Force Stop Driving', type: 'action', action: 'stopDriving', description: 'Immediately clear the ped task.' },
        { label: 'Custom Driving Style', type: 'prompt', action: 'setDrivingStyle', description: 'Enter a custom GTA driving style integer.', fields: [{ name: 'style', label: 'Driving style', type: 'number', value: snap.values?.drivingStyle ?? 786603 }] }
      ]
    }),

    playerScenarios: () => ({
      title: 'Player Scenarios',
      items: [
        ...commonScenarioEntries.map(([label, scenario]) => ({ label, type: 'action', action: 'startScenario', value: scenario, description: scenario })),
        { label: 'Force Stop Scenario', type: 'action', action: 'forceStopScenario', description: 'Stop the active scenario.' }
      ]
    }),

    playerAppearance: () => ({
      title: 'Player Appearance',
      items: [
        arrowEntry('Ped Customization', 'pedCustomization', 'Change or spawn the current ped model.'),
        arrowEntry('Ped Collections', 'addonPeds', 'Browse addon peds from addons.json.'),
        { label: 'Save Ped', type: 'prompt', action: 'savePed', description: 'Save your current ped model for later.', fields: [{ name: 'name', label: 'Save name', value: 'My Ped' }] },
        arrowEntry('Saved Peds', 'savedPeds', 'Spawn, rename, replace, or delete saved peds.'),
        arrowEntry('Spawn Peds', 'spawnPeds', 'Browse ped categories to spawn.'),
        arrowEntry('Walking Style', 'walkingStyle', 'Apply a preset walking style.'),
        { label: 'Use Server Clothing Resource', type: 'info', description: 'For serious RP, clothing edits should stay inside your clothing/appearance resource. AMenu only saves and loads ped/character snapshots.' }
      ]
    }),

    pedCustomization: () => ({
      title: 'Ped Customization',
      items: [
        { label: 'Spawn By Name', type: 'prompt', action: 'spawnPed', description: 'Enter a ped model name.', fields: [{ name: 'model', label: 'Ped model', value: DATA.pedSuggestions?.[0] || 'mp_m_freemode_01' }] },
        ...(DATA.pedSuggestions || []).map(model => ({ label: prettyPedLabel(model), type: 'action', action: 'spawnPedQuick', value: model, description: model }))
      ]
    }),

    spawnPeds: () => ({
      title: 'Spawn Peds',
      items: [
        arrowEntry('Addon Peds', 'addonPeds', 'Spawn peds from addons.json.'),
        arrowEntry('Spawn By Name', 'pedCustomization', 'Enter a ped model name directly.'),
        arrowEntry('Main Peds', 'spawnPedsMain', 'Spawn freemode peds.'),
        arrowEntry('Animals', 'spawnPedsAnimals', 'Spawn animal peds.'),
        arrowEntry('Male Peds', 'spawnPedsMale', 'Spawn male peds.'),
        arrowEntry('Female Peds', 'spawnPedsFemale', 'Spawn female peds.'),
        arrowEntry('Other Peds', 'spawnPedsOther', 'Spawn uncategorized peds.')
      ]
    }),

    spawnPedsMain: () => ({ title: 'Main Peds', items: pedItemsForKind('main') }),
    spawnPedsAnimals: () => ({ title: 'Animals', items: pedItemsForKind('animals') }),
    spawnPedsMale: () => ({ title: 'Male Peds', items: pedItemsForKind('male') }),
    spawnPedsFemale: () => ({ title: 'Female Peds', items: pedItemsForKind('female') }),
    spawnPedsOther: () => ({ title: 'Other Peds', items: pedItemsForKind('other') }),

    savedPeds: (ctx, snap) => ({
      title: 'Saved Peds',
      items: (snap.savedPeds || []).length
        ? (snap.savedPeds || []).map((ped, index) => ({ label: ped.name, submenu: 'savedPedActions', context: { pedIndex: index, pedName: ped.name }, description: ped.model || 'Saved ped entry.' }))
        : [{ label: 'No saved peds', type: 'info', description: 'Use Save Ped first.' }]
    }),

    savedPedActions: (ctx) => ({
      title: String(ctx.pedName || 'Saved Ped'),
      items: [
        { label: 'Spawn Saved Ped', type: 'action', action: 'loadPed', value: ctx.pedIndex, description: 'Spawn this saved ped.' },
        { label: 'Clone Saved Ped', type: 'action', action: 'clonePed', value: ctx.pedIndex, context: ctx, description: 'Create a copy of this saved ped.' },
        { label: 'Rename Saved Ped', type: 'prompt', action: 'renamePed', context: ctx, description: 'Rename this saved ped.', fields: [{ name: 'name', label: 'New name', value: String(ctx.pedName || 'Saved Ped') }] },
        { label: 'Replace Saved Ped', type: 'action', action: 'replacePed', value: ctx.pedIndex, context: ctx, description: 'Replace this entry with your current ped model.' },
        { label: 'Delete Saved Ped', type: 'action', action: 'deletePed', value: ctx.pedIndex, description: 'Delete this saved ped.' }
      ]
    }),

    mpPedCustomization: (ctx, snap) => ({
      title: 'MP Ped Customization',
      items: [
        { label: 'Create Male Character', type: 'action', action: 'spawnPedQuick', value: 'mp_m_freemode_01', description: 'Spawn the male freemode ped.' },
        { label: 'Create Female Character', type: 'action', action: 'spawnPedQuick', value: 'mp_f_freemode_01', description: 'Spawn the female freemode ped.' },
        arrowEntry('Saved Characters', 'savedCharacters', 'Create, edit, save and load multiplayer characters.'),
        arrowEntry('Character Tools', 'characterEditor', 'Open serious-RP character save/load tools.')
      ]
    }),

    characterEditor: () => ({
      title: 'Character Editor',
      items: [
        { label: 'Randomize Character', type: 'action', action: 'randomizeCharacter', description: 'Randomize clothing and props on the current freemode ped.' },
        { label: 'Character Inheritance', type: 'info', description: 'For serious RP, head-blend inheritance should stay inside your dedicated clothing/appearance resource. You can still randomize or save/load character snapshots here.' },
        { label: 'Character Appearance', type: 'info', description: 'Detailed facial features should be handled by your clothing/appearance resource. Saved character snapshots are supported here.' },
        { label: 'Character Face Shape Options', type: 'info', description: 'Use your clothing/appearance resource for face shape sliders.' },
        { label: 'Character Tattoo Options', type: 'info', description: 'Tattoo editing is not included in this build.' },
        { label: 'Character Clothes', type: 'info', description: 'Use your server clothing resource, then save or update the current character here.' },
        { label: 'Character Props', type: 'info', description: 'Use your server clothing resource, then save or update the current character here.' },
        { label: 'Facial Expression', type: 'info', description: 'Facial expression editing is not included in this build.' },
        { label: 'Save Character', type: 'prompt', action: 'saveCharacter', description: 'Save the current freemode ped as a character entry.', fields: [{ name: 'name', label: 'Character name', value: 'Character 1' }] },
        disabledEntry('Exit Without Saving', 'Use Back to leave this submenu.')
      ]
    }),

    savedCharacters: (ctx, snap) => ({
      title: 'Saved Characters',
      items: (snap.savedOutfits || []).length
        ? (snap.savedOutfits || []).map((outfit, index) => ({ label: outfit.name, submenu: 'savedCharacterActions', context: { outfitIndex: index, outfitName: outfit.name }, description: 'Saved MP outfit/character entry.' }))
        : [{ label: 'No saved characters', type: 'info', description: 'Use the existing outfit save flow to populate this list.' }]
    }),

    savedCharacterActions: (ctx) => ({
      title: String(ctx.outfitName || 'Saved Character'),
      items: [
        { label: 'Spawn Character', type: 'action', action: 'loadOutfit', value: ctx.outfitIndex, description: 'Load this saved character/outfit.' },
        { label: 'Edit Character', type: 'action', action: 'loadOutfit', value: ctx.outfitIndex, description: 'Load this character for editing.' },
        { label: 'Clone Character', type: 'prompt', action: 'cloneOutfit', context: ctx, description: 'Clone this character entry.', fields: [{ name: 'name', label: 'Clone name', value: `${String(ctx.outfitName || 'Character')} Copy` }] },
        { label: 'Set Category', type: 'info', description: 'Character categories are not used in this build.' },
        { label: 'Set As Default', type: 'action', action: 'setDefaultOutfit', value: ctx.outfitIndex, context: ctx, description: 'Mark this character as the default saved character.' },
        { label: 'Rename Character', type: 'prompt', action: 'renameOutfit', context: ctx, description: 'Rename this saved character.', fields: [{ name: 'name', label: 'New name', value: String(ctx.outfitName || 'Character') }] },
        { label: 'Update Clothing', type: 'action', action: 'updateOutfit', value: ctx.outfitIndex, context: ctx, description: 'Save your current look back into this character.' },
        { label: 'Delete Character', type: 'action', action: 'deleteOutfit', value: ctx.outfitIndex, description: 'Delete this saved character/outfit.' }
      ]
    }),

    weaponOptions: () => ({
      title: 'Weapon Options',
      items: [
        { label: 'Get All Weapons', type: 'action', action: 'giveAllWeapons', description: 'Grant the full generated weapon list.' },
        { label: 'Remove All Weapons', type: 'action', action: 'removeAllWeapons', description: 'Remove every weapon from your ped.' },
        { label: 'Unlimited Ammo', type: 'toggle', key: 'unlimitedAmmo', description: 'Keep selected weapon ammo full.' },
        { label: 'No Reload', type: 'toggle', key: 'noReload', description: 'Use infinite clip ammo.' },
        { label: 'Set All Ammo Count', type: 'prompt', action: 'setAllAmmoCount', description: 'Set ammo on every owned weapon.', fields: [{ name: 'count', label: 'Ammo count', type: 'number', value: 999 }] },
        { label: 'Refill All Ammo', type: 'action', action: 'refillAmmo', description: 'Refill ammo for the selected weapon slot.' },
        { label: 'Spawn Weapon By Name', type: 'prompt', action: 'giveWeapon', description: 'Spawn a weapon by model name.', fields: [{ name: 'weapon', label: 'Weapon name', value: DATA.allWeaponNames?.[0] || 'WEAPON_PISTOL' }] },
        arrowEntry('Addon Weapons', 'addonWeapons', 'Equip/Remove addon weapons.'),
        arrowEntry('Parachute Options', 'parachuteOptions', 'Parachute options.'),
        arrowEntry('Handguns', 'weaponCategoryExact', 'Equip/remove handguns.', { category: 'Handguns' }),
        arrowEntry('Assault Rifles', 'weaponCategoryExact', 'Equip/remove assault rifles.', { category: 'Assault Rifles' }),
        arrowEntry('Shotguns', 'weaponCategoryExact', 'Equip/remove shotguns.', { category: 'Shotguns' }),
        arrowEntry('Sub-/Light Machine Guns', 'weaponCategoryExact', 'Equip/remove SMGs and MGs.', { category: 'Sub-/Light Machine Guns' }),
        arrowEntry('Throwables', 'weaponCategoryExact', 'Equip/remove throwables.', { category: 'Throwables' }),
        arrowEntry('Melee', 'weaponCategoryExact', 'Equip/remove melee weapons.', { category: 'Melee' }),
        arrowEntry('Heavy Weapons', 'weaponCategoryExact', 'Equip/remove heavy weapons.', { category: 'Heavy Weapons' }),
        arrowEntry('Sniper Rifles', 'weaponCategoryExact', 'Equip/remove sniper rifles.', { category: 'Sniper Rifles' })
      ]
    }),

    weaponCategoryExact: (ctx) => ({
      title: String(ctx.category || 'Weapons'),
      items: buildWeaponCategoryItems(ctx)
    }),

    weaponEntryActions: (ctx) => ({
      title: String(ctx.weaponLabel || 'Weapon'),
      items: [
        { label: 'Equip/Remove Weapon', type: 'action', action: 'giveWeapon', value: ctx.weapon, description: ctx.weapon },
        { label: 'Re-fill Ammo', type: 'action', action: 'refillAmmo', description: 'Refill ammo for the selected weapon.' },
        { label: 'Tints', type: 'prompt', action: 'setWeaponTint', context: ctx, description: 'Set a weapon tint index.', fields: [{ name: 'tint', label: 'Tint index', type: 'number', value: 0 }] },
        { label: 'Components', type: 'prompt', action: 'giveWeaponComponent', context: ctx, description: 'Add a weapon component by name.', fields: [{ name: 'component', label: 'Component name', value: 'COMPONENT_AT_PI_FLSH' }] }
      ]
    }),

    parachuteOptions: () => ({
      title: 'Parachute Options',
      items: [
        { label: 'Toggle Primary Parachute', type: 'action', action: 'togglePrimaryParachute', value: 'GADGET_PARACHUTE', description: 'Give or remove the primary parachute.' },
        { label: 'Enable Reserve Parachute', type: 'toggle', key: 'reserveParachute', description: 'Enable or disable the reserve parachute.' },
        { label: 'Primary Chute Style', type: 'prompt', action: 'setPrimaryParachuteStyle', description: 'Set the primary parachute tint index.', fields: [{ name: 'tint', label: 'Tint index', type: 'number', value: 0 }] },
        { label: 'Reserve Chute Style', type: 'prompt', action: 'setReserveParachuteStyle', description: 'Set the reserve parachute tint index.', fields: [{ name: 'tint', label: 'Tint index', type: 'number', value: 0 }] },
        { label: 'Unlimited Parachutes', type: 'toggle', key: 'parachuteUnlimited', description: 'Continuously keep a parachute equipped.' },
        { label: 'Auto Equip Parachutes', type: 'toggle', key: 'parachuteAutoEquip', description: 'Auto-equip a parachute when needed.' },
        { label: 'Smoke Trail Color', type: 'prompt', action: 'setParachuteSmokeTrailColor', description: 'Set parachute smoke trail color.', fields: [{ name: 'r', label: 'Red', type: 'number', value: 255 }, { name: 'g', label: 'Green', type: 'number', value: 255 }, { name: 'b', label: 'Blue', type: 'number', value: 255 }] }
      ]
    }),

    weaponLoadouts: (ctx, snap) => ({
      title: 'Weapon Loadouts',
      items: [
        { label: 'Save Loadout', type: 'prompt', action: 'saveLoadout', description: 'Save your current detected weapons.', fields: [{ name: 'name', label: 'Loadout name', value: `Loadout ${(snap.loadouts || []).length + 1}` }] },
        arrowEntry('Manage Loadouts', 'manageLoadouts', 'Manage existing weapon loadouts.'),
        { label: 'Restore Default Loadout On Respawn', type: 'info', description: `Current default: ${(snap.values?.defaultLoadoutIndex ?? -1) >= 0 ? 'Enabled' : 'Disabled'}` }
      ]
    }),

    manageLoadouts: (ctx, snap) => ({
      title: 'Manage Loadouts',
      items: (snap.loadouts || []).length
        ? (snap.loadouts || []).map((loadout, index) => ({ label: loadout.name, submenu: 'loadoutActions', context: { loadoutIndex: index, loadoutName: loadout.name }, description: `${loadout.weapons?.length || 0} stored weapons.` }))
        : [{ label: 'No saved loadouts', type: 'info', description: 'Use Save Loadout first.' }]
    }),

    loadoutActions: (ctx) => ({
      title: String(ctx.loadoutName || 'Loadout'),
      items: [
        { label: 'Equip Loadout', type: 'action', action: 'equipLoadout', value: ctx.loadoutIndex, description: 'Equip this weapon loadout.' },
        { label: 'Rename Loadout', type: 'prompt', action: 'renameLoadout', context: ctx, description: 'Rename this loadout.', fields: [{ name: 'name', label: 'New name', value: String(ctx.loadoutName || 'Loadout') }] },
        { label: 'Clone Loadout', type: 'action', action: 'cloneLoadout', value: ctx.loadoutIndex, context: ctx, description: 'Clone this loadout.' },
        { label: 'Set As Default Loadout', type: 'action', action: 'setDefaultLoadout', value: ctx.loadoutIndex, context: ctx, description: 'Set this as the default respawn loadout.' },
        { label: 'Replace Loadout', type: 'action', action: 'replaceLoadout', value: ctx.loadoutIndex, context: ctx, description: 'Replace this loadout with your current weapons.' },
        { label: 'Delete Loadout', type: 'action', action: 'deleteLoadout', value: ctx.loadoutIndex, description: 'Delete this loadout.' }
      ]
    }),

    vehicleRelated: () => ({
      title: 'Vehicle Related Options',
      items: [
        arrowEntry('Vehicle Options', 'vehicleOptions', 'Here you can change common vehicle options, as well as tune & style your vehicle.'),
        arrowEntry('Vehicle Spawner', 'vehicleSpawner', 'Spawn a vehicle by name or choose one from a specific category.'),
        arrowEntry('Saved Vehicles', 'savedVehicles', 'Save new vehicles, or spawn or delete already saved vehicles.'),
        arrowEntry('Personal Vehicle', 'personalVehicle', 'Set a vehicle as your personal vehicle, and control some things about that vehicle when you are not inside.')
      ]
    }),

    vehicleOptions: (ctx, snap) => ({
      title: 'Vehicle Options',
      items: [
        arrowEntry('God Mode Options', 'vehicleGodModeOptions', 'Vehicle Godmode Options.'),
        { label: 'Vehicle God Mode', type: 'toggle', key: 'vehicleGod', description: 'Make the current vehicle invincible.' },
        { label: 'Keep Vehicle Clean', type: 'toggle', key: 'keepClean', description: 'Continuously clean the current vehicle.' },
        { label: 'Bike Seatbelt', type: 'toggle', key: 'bikeSeatbelt', description: 'Reduce the chance of being knocked off motorcycles.' },
        { label: 'Engine Always On', type: 'toggle', key: 'engineAlwaysOn', description: 'Keep the engine running.' },
        { label: 'Disable Plane Turbulence', type: 'toggle', key: 'planeTurbulence', description: 'Reduce plane turbulence while flying.' },
        { label: 'Disable Helicopter Turbulence', type: 'toggle', key: 'heliTurbulence', description: 'Reduce helicopter turbulence while flying.' },
        { label: 'Anchor Boat', type: 'toggle', key: 'anchoredBoat', description: 'Toggle anchor state on boats.' },
        { label: 'Disable Siren', type: 'toggle', key: 'sirenOff', description: 'Force the current siren off.' },
        { label: 'No Bike Helmet', type: 'toggle', key: 'noBikeHelmet', description: 'Prevent automatic bike helmets.' },
        { label: 'Freeze Vehicle', type: 'toggle', key: 'vehicleFreeze', description: 'Freeze the current vehicle in place.' },
        { label: 'Enable Torque Multiplier', type: 'prompt', action: 'setEngineTorqueMultiplier', description: 'Set an engine torque multiplier.', fields: [{ name: 'value', label: 'Torque multiplier', type: 'number', value: 1.0 }] },
        { label: 'Enable Power Multiplier', type: 'prompt', action: 'setEnginePowerMultiplier', description: 'Set an engine power multiplier.', fields: [{ name: 'value', label: 'Power multiplier', type: 'number', value: 1.0 }] },
        { label: 'Flash Highbeams On Honk', type: 'toggle', key: 'flashHighbeamsOnHonk', description: 'Flash highbeams while the horn is active.' },
        { label: 'Show Vehicle Health', type: 'toggle', key: 'showVehicleHealth', description: 'Draw engine and body health on-screen.' },
        { label: 'Infinite Fuel', type: 'toggle', key: 'infiniteFuel', description: 'Keep vehicle fuel level full.' },
        { label: 'Enable Default Radio Station', type: 'toggle', key: 'defaultRadio', description: 'Keep the selected radio station active.' },
        { label: 'Repair Vehicle', type: 'action', action: 'repairVehicle', description: 'Repair the current vehicle.' },
        { label: 'Wash Vehicle', type: 'action', action: 'washVehicle', description: 'Wash the current vehicle.' },
        { label: 'Toggle Engine On/Off', type: 'action', action: 'toggleEngine', description: 'Turn the engine on or off.' },
        { label: 'Set License Plate Text', type: 'prompt', action: 'setPlate', description: 'Change the current plate text.', fields: [{ name: 'plate', label: 'Plate text', value: 'VMENU' }] },
        arrowEntry('Mod Menu', 'vehicleMods', 'Vehicle Mods'),
        arrowEntry('Vehicle Doors', 'vehicleDoors', 'Vehicle Doors Management'),
        arrowEntry('Vehicle Windows', 'vehicleWindows', 'Vehicle window controls.'),
        arrowEntry('Vehicle Extras', 'vehicleExtras', 'Toggle extra parts on the current vehicle.'),
        arrowEntry('Vehicle Liveries', 'vehicleLiveries', 'Apply vehicle liveries.'),
        arrowEntry('Vehicle Colors', 'vehicleColors', 'Primary, secondary, pearlescent, wheel, dashboard and interior colors.'),
        arrowEntry('Vehicle Neon Kits', 'vehicleNeons', 'Configure neon positions and colors.'),
        { label: 'Toggle Vehicle Visibility', type: 'toggle', key: 'vehicleInvisible', description: 'Hide the current vehicle.' },
        { label: 'Flip Vehicle', type: 'action', action: 'flipVehicle', description: 'Set the current vehicle upright.' },
        { label: 'Toggle Vehicle Alarm', type: 'action', action: 'alarmVehicle', description: 'Start the vehicle alarm.' },
        { label: 'Cycle Through Vehicle Seats', type: 'action', action: 'cycleVehicleSeat', description: 'Move to the next free seat.' },
        arrowEntry('Vehicle Lights', 'vehicleLighting', 'Vehicle lights, xenon, tire smoke and neon.'),
        { label: 'Set Default Radio Station', type: 'prompt', action: 'setRadioStation', description: 'Set the default radio station name.', fields: [{ name: 'station', label: 'Station', value: 'OFF' }] },
        arrowEntry('Fix / Destroy Tires', 'tireOptions', 'Repair or burst tires on the current vehicle.'),
        { label: 'Destroy Engine', type: 'action', action: 'destroyEngine', description: 'Destroy the current engine.' },
        { label: 'Delete Vehicle', type: 'action', action: 'deleteVehicle', description: 'Delete the current vehicle.' },
        { label: 'Set Dirt Level', type: 'prompt', action: 'setVehicleDirtLevel', description: 'Enter a dirt level from 0.0 to 15.0.', fields: [{ name: 'dirt', label: 'Dirt level', type: 'number', value: 0 }] },
        { label: 'License Plate Type', type: 'prompt', action: 'setPlateType', description: 'Set the plate style index.', fields: [{ name: 'index', label: 'Plate style index', type: 'number', value: 0 }] },
        { label: 'Set Engine Torque Multiplier', type: 'prompt', action: 'setEngineTorqueMultiplier', description: 'Enter a torque multiplier.', fields: [{ name: 'value', label: 'Torque multiplier', type: 'number', value: 1.0 }] },
        { label: 'Set Engine Power Multiplier', type: 'prompt', action: 'setEnginePowerMultiplier', description: 'Enter a power multiplier.', fields: [{ name: 'value', label: 'Power multiplier', type: 'number', value: 1.0 }] },
        { label: 'Speed Limiter', type: 'prompt', action: 'speedLimiter', description: 'Set max speed in mph. Enter 0 to clear.', fields: [{ name: 'speed', label: 'Max speed (mph, 0 disables)', type: 'number', value: ((snap.values || {}).speedLimitMph) || 0 }] }
      ]
    }),

    vehicleGodModeOptions: () => ({
      title: 'Vehicle Godmode',
      items: [
        { label: 'Invincible', type: 'toggle', key: 'vehicleGod', description: 'Use Vehicle God Mode above to toggle this option.' },
        { label: 'Engine Damage', type: 'toggle', key: 'protectEngineDamage', description: 'Block engine damage while active.' },
        { label: 'Visual Damage', type: 'toggle', key: 'protectVisualDamage', description: 'Continuously repair visual damage while active.' },
        { label: 'Strong Wheels', type: 'toggle', key: 'strongWheels', description: 'Make tires more resilient.' },
        { label: 'Ramp Damage', type: 'toggle', key: 'rampDamageProtection', description: 'Reduce ramp-style collision damage.' },
        { label: 'Auto Repair', type: 'toggle', key: 'autoRepairVehicle', description: 'Continuously repair the current vehicle.' }
      ]
    }),

    vehicleSpawner: (ctx, snap) => ({
      title: 'Vehicle Spawner',
      items: [
        { label: 'Spawn Vehicle By Model Name', type: 'prompt', action: 'spawnVehicle', description: 'Spawn any valid vehicle model.', fields: [{ name: 'model', label: 'Vehicle model', value: 'adder' }] },
        { label: 'Spawn Inside Vehicle', type: 'toggle', key: 'spawnInsideVehicle', description: 'Put yourself into newly spawned vehicles.' },
        { label: 'Replace Previous Vehicle', type: 'toggle', key: 'replaceOldVehicle', description: 'Delete your last personal vehicle before spawning a new one.' },
        ...(((((snap.addons || {}).vehicleCategories || []).length || ((snap.addons || {}).vehicles || []).length) ? [arrowEntry('Addon Vehicles', 'addonVehicles', 'Spawn an addon vehicle.')] : [])),
        ...(snap.vehicleCatalog || []).filter(group => group.id !== 'Addon Vehicles').map(group => ({ label: group.label, submenu: 'vehicleClass', context: { classId: group.id }, description: `${group.count} registered vehicle models.` })),
        ...(snap.vehicleCatalog || []).filter(group => group.id === 'Addon Vehicles' && !(((snap.addons || {}).vehicleCategories || []).length || ((snap.addons || {}).vehicles || []).length)).map(group => ({ label: 'Unavailable Vehicles', submenu: 'vehicleClass', context: { classId: group.id }, description: `${group.count} unavailable vehicle models.` }))
      ]
    }),

    savedVehicles: (ctx, snap) => ({
      title: 'Saved Vehicles',
      items: [
        { label: 'Save Current Vehicle', type: 'prompt', action: 'saveVehicle', description: 'Save the vehicle you are in or near.', fields: [{ name: 'name', label: 'Save name', value: `Vehicle ${(snap.savedVehicles || []).length + 1}` }] },
        { label: 'Import Old .dll AMenu Vehicles', type: 'action', action: 'importLegacyAMenuVehicles', description: 'Pulls old TomGrobbe/AMenu saved vehicles from client KVP entries named veh_*. Safe to press more than once.' },
        arrowEntry('Vehicle Class', 'savedVehicleClasses', 'Browse saved vehicles by GTA vehicle class.'),
        arrowEntry('Vehicle Category', 'savedVehicleCategories', 'Browse, rename, delete, and move saved vehicle categories.'),
        { label: 'Create Category', type: 'prompt', action: 'createSavedVehicleCategory', description: 'Create a saved vehicle category. You can move vehicles into it from each saved vehicle action menu.', fields: [{ name: 'name', label: 'Category name', value: 'Personal' }] },
        arrowEntry('Unavailable Saved Vehicles', 'savedVehicleUnavailable', 'Saved vehicles whose model is currently missing or unavailable.'),
        ...((snap.savedVehicles || []).map((vehicle, index) => savedVehicleRow(vehicle, index))),
        ...(!(snap.savedVehicles || []).length ? [{ label: 'No saved vehicles', type: 'info', description: 'Use Save Current Vehicle first, or import your old .dll AMenu saves.' }] : [])
      ]
    }),

    savedVehicleClasses: (ctx, snap) => ({
      title: 'Vehicle Class',
      items: (snap.savedVehicleClasses || []).length
        ? (snap.savedVehicleClasses || []).map(group => arrowEntry(`${group.label} (${group.count || 0})`, 'savedVehicleClass', `Open ${group.count || 0} saved vehicles in ${group.label}.`, { classId: group.id, classLabel: group.label }))
        : [{ label: 'No saved vehicle classes', type: 'info', description: 'Save or import vehicles first.' }]
    }),

    savedVehicleClass: (ctx, snap) => {
      const group = (snap.savedVehicleClasses || []).find(g => String(g.id) === String(ctx.classId)) || { label: ctx.classLabel || 'Class', vehicles: [] };
      return {
        title: String(group.label || 'Vehicle Class'),
        items: (group.vehicles || []).length
          ? (group.vehicles || []).map((vehicle, index) => savedVehicleRow(vehicle, index))
          : [{ label: 'No vehicles in this class', type: 'info', description: 'No saved vehicles are currently assigned to this vehicle class.' }]
      };
    },

    savedVehicleCategories: (ctx, snap) => ({
      title: 'Vehicle Category',
      items: [
        { label: 'Create Category', type: 'prompt', action: 'createSavedVehicleCategory', description: 'Create a new saved vehicle category.', fields: [{ name: 'name', label: 'Category name', value: 'Personal' }] },
        ...((snap.savedVehicleCategoryGroups || []).map(group => arrowEntry(`${group.label} (${group.count || 0})`, 'savedVehicleCategory', `Open and manage ${group.label}.`, { category: group.id, categoryLabel: group.label }))),
        ...(!(snap.savedVehicleCategoryGroups || []).length ? [{ label: 'No categories', type: 'info', description: 'Create a category or save/import vehicles first.' }] : [])
      ]
    }),

    savedVehicleCategory: (ctx, snap) => {
      const group = (snap.savedVehicleCategoryGroups || []).find(g => String(g.id).toLowerCase() === String(ctx.category || ctx.categoryLabel || '').toLowerCase()) || { label: ctx.categoryLabel || ctx.category || 'Category', vehicles: [] };
      const isDefault = String(group.label || '').toLowerCase() === 'uncategorized';
      return {
        title: String(group.label || 'Category'),
        items: [
          ...(isDefault ? [] : [
            { label: 'Rename Category', type: 'prompt', action: 'renameSavedVehicleCategory', context: { category: group.label }, description: 'Rename this category and update all vehicles inside it.', fields: [{ name: 'name', label: 'New category name', value: String(group.label || '') }] },
            { label: 'Delete Category', type: 'action', action: 'deleteSavedVehicleCategory', value: group.label, context: { category: group.label }, description: 'Remove this category and move its vehicles to Uncategorized.' }
          ]),
          ...((group.vehicles || []).map((vehicle, index) => savedVehicleRow(vehicle, index))),
          ...(!(group.vehicles || []).length ? [{ label: 'No vehicles in this category', type: 'info', description: 'Move a saved vehicle into this category from the vehicle action menu.' }] : [])
        ]
      };
    },

    savedVehicleUnavailable: (ctx, snap) => ({
      title: 'Unavailable Saved Vehicles',
      items: (snap.unavailableSavedVehicles || []).length
        ? (snap.unavailableSavedVehicles || []).map((vehicle, index) => savedVehicleRow(vehicle, index))
        : [{ label: 'No unavailable vehicles', type: 'info', description: 'All saved vehicles currently have valid models loaded.' }]
    }),

    savedVehicleActions: (ctx) => ({
      title: String(ctx.vehicleName || 'Saved Vehicle'),
      items: [
        { label: 'Spawn Vehicle', type: 'action', action: 'spawnSavedVehicle', value: ctx.vehicleIndex, description: savedVehicleDescription(ctx) },
        { label: 'Rename Vehicle', type: 'prompt', action: 'renameSavedVehicle', context: ctx, description: 'Rename this saved vehicle.', fields: [{ name: 'name', label: 'New name', value: String(ctx.vehicleName || 'Vehicle') }] },
        { label: 'Set Category', type: 'prompt', action: 'setSavedVehicleCategory', context: ctx, description: 'Move this vehicle into a saved vehicle category.', fields: [{ name: 'category', label: 'Category', value: String(ctx.category || 'Uncategorized') }] },
        { label: 'Clear Category', type: 'action', action: 'clearSavedVehicleCategory', value: ctx.vehicleIndex, context: ctx, description: 'Move this vehicle back to Uncategorized.' },
        { label: 'Replace Vehicle', type: 'action', action: 'replaceSavedVehicle', value: ctx.vehicleIndex, context: ctx, description: 'Replace this entry with your current vehicle.' },
        { label: 'Delete Vehicle', type: 'action', action: 'deleteSavedVehicle', value: ctx.vehicleIndex, description: 'Delete this saved vehicle.' }
      ]
    }),

    personalVehicle: (ctx, snap) => ({
      title: 'Personal Vehicle',
      items: [
        { label: 'Set Vehicle', type: 'action', action: 'setPersonalVehicle', description: 'Mark your current vehicle as personal.' },
        { label: 'Toggle Engine', type: 'action', action: 'togglePersonalEngine', description: 'Toggle the personal vehicle engine.' },
        { label: 'Set Vehicle Lights', type: 'action', action: 'togglePersonalLights', description: 'Flash or toggle personal vehicle lights.' },
        { label: 'Vehicle Stance', type: 'prompt', action: 'setVehicleStance', description: 'Set suspension height. Lower is more slammed.', fields: [{ name: 'height', label: 'Suspension height', type: 'number', value: 0.0 }] },
        { label: 'Kick Passengers', type: 'action', action: 'kickPassengers', description: 'Kick non-driver occupants from the personal vehicle.' },
        { label: 'Lock Vehicle Doors', type: 'action', action: 'lockPersonalVehicle', description: 'Lock or unlock the personal vehicle.' },
        { label: 'Unlock Vehicle Doors', type: 'action', action: 'lockPersonalVehicle', description: 'Lock or unlock the personal vehicle.' },
        arrowEntry('Vehicle Doors', 'personalVehicleDoors', 'Vehicle Doors Management'),
        { label: 'Sound Horn', type: 'action', action: 'hornPersonalVehicle', description: 'Sound the horn.' },
        { label: 'Toggle Alarm Sound', type: 'action', action: 'alarmPersonalVehicle', description: 'Trigger the alarm.' },
        { label: 'Add Blip For Personal Vehicle', type: 'action', action: 'togglePersonalBlip', description: 'Toggle a map blip for your personal vehicle.' },
        { label: 'Exclusive Driver', type: 'toggle', key: 'exclusiveDriver', description: 'Keep other players out of the personal vehicle.' }
      ]
    }),

    personalVehicleDoors: () => ({
      title: 'Vehicle Doors',
      items: [
        { label: 'Open All Doors', type: 'action', action: 'openAllDoors', description: 'Open every door on the current vehicle.' },
        { label: 'Close All Doors', type: 'action', action: 'closeAllDoors', description: 'Close every door on the current vehicle.' },
        { label: 'Left Front Door', type: 'action', action: 'toggleDoor', value: 0, description: 'Toggle the left front door.' },
        { label: 'Right Front Door', type: 'action', action: 'toggleDoor', value: 1, description: 'Toggle the right front door.' },
        { label: 'Left Rear Door', type: 'action', action: 'toggleDoor', value: 2, description: 'Toggle the left rear door.' },
        { label: 'Right Rear Door', type: 'action', action: 'toggleDoor', value: 3, description: 'Toggle the right rear door.' },
        { label: 'Hood', type: 'action', action: 'toggleDoor', value: 4, description: 'Toggle the hood.' },
        { label: 'Trunk', type: 'action', action: 'toggleDoor', value: 5, description: 'Toggle the trunk.' },
        { label: 'Extra 1', type: 'action', action: 'toggleDoor', value: 6, description: 'Toggle extra door 1.' },
        { label: 'Extra 2', type: 'action', action: 'toggleDoor', value: 7, description: 'Toggle extra door 2.' },
        { label: 'Bomb Bay', type: 'action', action: 'toggleDoor', value: 8, description: 'Toggle bomb bay if available.' },
        { label: 'Remove Door', type: 'prompt', action: 'removeDoor', description: 'Break a specific vehicle door.', fields: [{ name: 'door', label: 'Door index', type: 'number', value: 0 }] },
        { label: 'Delete Removed Doors', type: 'action', action: 'restoreDoors', description: 'Repair the vehicle to restore removed doors.' }
      ]
    }),

    walkingStyle: () => ({
      title: 'Walking Style',
      items: [
        { label: 'Default', type: 'action', action: 'setWalkingStyle', value: 'default', description: 'Reset to the normal movement clipset.' },
        { label: 'Brave', type: 'action', action: 'setWalkingStyle', value: 'move_m@brave', description: 'Apply the brave walking style.' },
        { label: 'Casual', type: 'action', action: 'setWalkingStyle', value: 'move_m@casual@a', description: 'Apply the casual walking style.' },
        { label: 'Hurry', type: 'action', action: 'setWalkingStyle', value: 'move_m@hurry@a', description: 'Apply the hurry walking style.' },
        { label: 'Business', type: 'action', action: 'setWalkingStyle', value: 'move_m@business@a', description: 'Apply the business walking style.' },
        { label: 'Grooving', type: 'action', action: 'setWalkingStyle', value: 'move_m@gangster@generic', description: 'Apply a more swagger-heavy walking style.' },
        { label: 'Femme', type: 'action', action: 'setWalkingStyle', value: 'move_f@femme@', description: 'Apply the femme walking style.' }
      ]
    }),

    tireOptions: () => ({
      title: 'Fix / Destroy Tires',
      items: [
        { label: 'Fix Tires', type: 'action', action: 'fixTires', description: 'Repair all burst tires.' },
        { label: 'Destroy Tires', type: 'action', action: 'destroyTires', description: 'Burst every tire on the current vehicle.' }
      ]
    }),

    worldRelated: (ctx, snap) => ({
      title: 'World Related Options',
      items: (snap.config?.worldControlsEnabled === false)
        ? [{ label: 'World controls disabled', type: 'info', description: 'Enable Config.World.manageSync and Config.World.allowMenuControls if you want this resource to control time/weather.' }]
        : [
            arrowEntry('Time Options', 'timeOptions', 'Change the time, and edit other time related options.'),
            arrowEntry('Weather Options', 'weatherOptions', 'Change all weather related options here.')
          ]
    }),

    timeOptions: () => ({
      title: 'Time Options',
      items: [
        { label: 'Freeze/Unfreeze Time', type: 'toggle', key: 'freezeTime', description: 'Freeze synced server time.' },
        { label: 'Early Morning', type: 'action', action: 'setTime', value: { hour: 6, minute: 0 }, description: 'Set time to early morning.' },
        { label: 'Morning', type: 'action', action: 'setTime', value: { hour: 9, minute: 0 }, description: 'Set time to morning.' },
        { label: 'Noon', type: 'action', action: 'setTime', value: { hour: 12, minute: 0 }, description: 'Set time to noon.' },
        { label: 'Early Afternoon', type: 'action', action: 'setTime', value: { hour: 14, minute: 0 }, description: 'Set time to early afternoon.' },
        { label: 'Afternoon', type: 'action', action: 'setTime', value: { hour: 17, minute: 0 }, description: 'Set time to afternoon.' },
        { label: 'Evening', type: 'action', action: 'setTime', value: { hour: 19, minute: 0 }, description: 'Set time to evening.' },
        { label: 'Midnight', type: 'action', action: 'setTime', value: { hour: 0, minute: 0 }, description: 'Set time to midnight.' },
        { label: 'Night', type: 'action', action: 'setTime', value: { hour: 22, minute: 0 }, description: 'Set time to night.' },
        { label: 'Set Custom Hour', type: 'prompt', action: 'setTime', description: 'Set a custom hour.', fields: [{ name: 'hour', label: 'Hour', type: 'number', value: 12 }, { name: 'minute', label: 'Minute', type: 'number', value: 0 }] },
        { label: 'Set Custom Minute', type: 'prompt', action: 'setTime', description: 'Set a custom minute.', fields: [{ name: 'hour', label: 'Hour', type: 'number', value: 12 }, { name: 'minute', label: 'Minute', type: 'number', value: 0 }] }
      ]
    }),

    weatherOptions: () => ({
      title: 'Weather Options',
      items: [
        { label: 'Toggle Dynamic Weather', type: 'toggle', key: 'dynamicWeather', description: 'Cycle synced weather every few minutes.' },
        { label: 'Toggle Blackout', type: 'toggle', key: 'blackout', description: 'Toggle synced blackout state.' },
        { label: 'Toggle Vehicle Lights Blackout', type: 'toggle', key: 'vehicleLightsBlackout', description: 'Toggle vehicle light blackout state.' },
        { label: 'Enable Snow Effects', type: 'toggle', key: 'snowEffects', description: 'Force snow footprints and vehicle trails.' },
        { label: 'Extra Sunny', type: 'action', action: 'setWeather', value: 'EXTRASUNNY', description: 'Set weather to EXTRASUNNY.' },
        { label: 'Clear', type: 'action', action: 'setWeather', value: 'CLEAR', description: 'Set weather to CLEAR.' },
        { label: 'Neutral', type: 'action', action: 'setWeather', value: 'NEUTRAL', description: 'Set weather to NEUTRAL.' },
        { label: 'Smog', type: 'action', action: 'setWeather', value: 'SMOG', description: 'Set weather to SMOG.' },
        { label: 'Foggy', type: 'action', action: 'setWeather', value: 'FOGGY', description: 'Set weather to FOGGY.' },
        { label: 'Cloudy', type: 'action', action: 'setWeather', value: 'CLOUDS', description: 'Set weather to CLOUDS.' },
        { label: 'Overcast', type: 'action', action: 'setWeather', value: 'OVERCAST', description: 'Set weather to OVERCAST.' },
        { label: 'Clearing', type: 'action', action: 'setWeather', value: 'CLEARING', description: 'Set weather to CLEARING.' },
        { label: 'Rainy', type: 'action', action: 'setWeather', value: 'RAIN', description: 'Set weather to RAIN.' },
        { label: 'Thunder', type: 'action', action: 'setWeather', value: 'THUNDER', description: 'Set weather to THUNDER.' },
        { label: 'Blizzard', type: 'action', action: 'setWeather', value: 'BLIZZARD', description: 'Set weather to BLIZZARD.' },
        { label: 'Snow', type: 'action', action: 'setWeather', value: 'SNOW', description: 'Set weather to SNOW.' },
        { label: 'Light Snow', type: 'action', action: 'setWeather', value: 'SNOWLIGHT', description: 'Set weather to SNOWLIGHT.' },
        { label: 'X-MAS Snow', type: 'action', action: 'setWeather', value: 'XMAS', description: 'Set weather to XMAS.' },
        { label: 'Halloween', type: 'action', action: 'setWeather', value: 'HALLOWEEN', description: 'Set weather to HALLOWEEN.' },
        { label: 'Remove All Clouds', type: 'action', action: 'removeClouds', description: 'Clear cloud hats like AMenu.' },
        { label: 'Randomize Clouds', type: 'action', action: 'randomizeClouds', description: 'Pick a random cloud pattern like AMenu.' }
      ]
    }),

    voiceOptions: () => ({
      title: 'Voice Chat Settings',
      items: [
        { label: 'Enable Voice Chat', type: 'toggle', key: 'voiceEnabled', description: 'Enable or disable voice chat.' },
        { label: 'Show Current Speaker', type: 'toggle', key: 'showCurrentSpeaker', description: 'Shows who is currently talking.' },
        { label: 'Voice Chat Proximity', type: 'cycle', key: 'voiceRangeIndex', options: ['5 m', '10 m', '20 m'], description: 'Set the voice chat receiving proximity.' },
        { label: 'Voice Chat Channel', type: 'prompt', action: 'setVoiceChannel', description: 'Set a numeric voice channel. Use 0 for public.', fields: [{ name: 'channel', label: 'Channel', type: 'number', value: 0 }] },
        { label: 'Show Microphone Status', type: 'toggle', key: 'showMicStatus', description: 'Draw a microphone status indicator.' }
      ]
    }),

    recordingOptions: () => ({
      title: 'Recording Options',
      items: [
        { label: 'Take Photo', type: 'action', action: 'takePhoto', description: 'Take a photo and save it to the Pause Menu gallery.' },
        { label: 'Open Gallery', type: 'action', action: 'openGallery', description: 'Open the Pause Menu gallery.' },
        { label: 'Start Recording', type: 'action', action: 'startRecording', description: 'Start a new game recording using GTA V built-in recording.' },
        { label: 'Stop Recording', type: 'action', action: 'stopRecording', description: 'Stop and save your current recording.' },
        { label: 'Rockstar Editor', type: 'action', action: 'openEditor', description: 'Open the Rockstar Editor.' }
      ]
    }),

    miscSettings: (ctx, snap) => ({
      title: 'Misc Settings',
      items: [
        arrowEntry('Teleport Options', 'teleportOptions', 'Teleport utilities and presets.'),
        arrowEntry('Developer Tools', 'developerTools', 'Coords, entity spawner, and clear-area tools.'),
        arrowEntry('Menu Settings', 'menuSettings', 'Move the menu, switch theme, and use banner config.'),
        arrowEntry('Keybind Settings', 'keybindSettings', 'Menu key and NoClip key information.'),
        { label: 'Right Align Menu', type: 'toggle', key: 'rightAlign', description: 'Move the menu to the right side of the screen.' },
        { label: 'Disable Private Messages', type: 'toggle', key: 'disablePrivateMessages', description: 'Block incoming private messages from this resource.' },
        { label: 'Disable Controller Support', type: 'toggle', key: 'disableControllerSupport', description: 'Ignore controller navigation for this UI.' },
        { label: 'Show Speed KM/H', type: 'toggle', key: 'showSpeedKmh', description: 'Show vehicle speed in km/h.' },
        { label: 'Show Speed MPH', type: 'toggle', key: 'showSpeedMph', description: 'Show vehicle speed in mph.' },
        { label: 'Show Coordinates', type: 'toggle', key: 'showCoords', description: 'Draw your vector4 coordinates on-screen.' },
        { label: 'Hide Radar', type: 'toggle', key: 'hideRadar', description: 'Hide or show the radar.' },
        { label: 'Hide Hud', type: 'toggle', key: 'hideHud', description: 'Hide or show HUD elements.' },
        { label: 'Location Display', type: 'toggle', key: 'locationDisplay', description: 'Draw your current street/location on-screen.' },
        { label: 'Show Time On Screen', type: 'toggle', key: 'showTime', description: 'Draw the current time on-screen.' },
        disabledEntry('Save Personal Settings', 'Personal settings in this Lua build are saved automatically.'),
        { label: 'Join / Quit Notifications', type: 'toggle', key: 'joinQuitNotifications', description: 'Show server join and leave notifications.' },
        { label: 'Death Notifications', type: 'toggle', key: 'deathNotifications', description: 'Show nearby player death notifications.' },
        { label: 'Toggle Night Vision', type: 'toggle', key: 'nightVision', description: 'Toggle night vision.' },
        { label: 'Toggle Thermal Vision', type: 'toggle', key: 'thermalVision', description: 'Toggle thermal vision.' },
        { label: 'Location Blips', type: 'toggle', key: 'locationBlips', description: 'Show teleport preset blips on the map.' },
        { label: 'Show Player Blips', type: 'toggle', key: 'playerBlips', description: 'Show player blips on the map.' },
        { label: 'Show Player Names', type: 'toggle', key: 'overheadNames', description: 'Draw overhead player names nearby.' },
        { label: 'Respawn As Default MP Character', type: 'toggle', key: 'respawnDefaultMp', description: 'Respawn as the default freemode character.' },
        { label: 'Restore Player Appearance', type: 'action', action: 'restoreAppearance', description: 'Restore the saved player appearance.' },
        { label: 'Restore Player Weapons', type: 'action', action: 'restoreWeapons', description: 'Restore the saved weapon set.' },
        arrowEntry('Connection Options', 'connectionOptions', 'Session and game connection options.')
      ]
    }),

    keybindSettings: () => ({
      title: 'Keybind Settings',
      items: [
        { label: 'Menu Toggle Key', type: 'info', description: 'M' },
        { label: 'NoClip Toggle Key', type: 'info', description: 'F2' },
        { label: 'Controller Toggle Key', type: 'info', description: 'Set this through FiveM keybind settings or change the RegisterKeyMapping line in client.lua.' }
      ]
    }),

    teleportOptions: (ctx, snap) => ({
      title: 'Teleport Options',
      items: [
        { label: 'Teleport To Waypoint', type: 'action', action: 'teleportToWaypoint', description: 'Teleport to your active waypoint.' },
        { label: 'Teleport To Coords', type: 'prompt', action: 'teleportToVector', description: 'Teleport to vector3 or vector4 coordinates.', fields: [{ name: 'coords', label: 'Coords', value: 'vector4(0.0, 0.0, 72.0, 0.0)' }] },
        { label: 'Save Teleport Location', type: 'action', action: 'copyCoordsV4', description: 'Copy your current vector4 for saving as a teleport preset.' },
        ...((DATA.teleportPresets || []).length ? [{ label: 'Teleport Locations', submenu: 'teleportLocations', description: 'Quick teleport to preset locations.' }] : [])
      ]
    }),

    teleportLocations: () => ({
      title: 'Teleport Locations',
      items: (DATA.teleportPresets || []).map(entry => ({ label: entry.label, type: 'action', action: 'teleportPreset', value: entry.coords, description: `Teleport to ${entry.label}.` }))
    }),

    developerTools: () => ({
      title: 'Developer Tools',
      items: [
        { label: 'Show Vehicle Dimensions', type: 'action', action: 'showEntityDebug', value: 'vehicle', description: 'Show model, handle, owner, coords and dimensions for the current/nearby vehicle.' },
        { label: 'Show Prop Dimensions', type: 'action', action: 'showEntityDebug', value: 'object', description: 'Show model, handle, coords and dimensions for the closest object.' },
        { label: 'Show Ped Dimensions', type: 'action', action: 'showEntityDebug', value: 'ped', description: 'Show model, handle, coords and dimensions for your ped.' },
        { label: 'Show Entity Handles', type: 'action', action: 'showEntityDebug', value: 'entity', description: 'Show current ped and vehicle entity handles.' },
        { label: 'Show Entity Models', type: 'action', action: 'showEntityDebug', value: 'models', description: 'Show current ped and vehicle model hashes.' },
        { label: 'Show Network Owners', type: 'action', action: 'showEntityDebug', value: 'owners', description: 'Show network owner/debug info for the current vehicle when available.' },
        { label: 'Clear Area', type: 'action', action: 'clearArea', description: 'Clear peds and vehicles nearby.' },
        { label: 'Lock Camera Horizontal Rotation', type: 'toggle', key: 'cameraLockH', description: 'Lock left/right look controls.' },
        { label: 'Lock Camera Vertical Rotation', type: 'toggle', key: 'cameraLockV', description: 'Lock up/down look controls.' },
        { label: '3D MP Ped Preview', type: 'action', action: 'showEntityDebug', value: 'ped', description: 'Shows current MP ped debug details; use your clothing resource for live RP appearance edits.' },
        arrowEntry('Entity Spawner', 'entitySpawner', 'Spawn new entities by model name.')
      ]
    }),

    entitySpawner: () => ({
      title: 'Entity Spawner',
      items: [
        { label: 'Spawn New Entity', type: 'prompt', action: 'spawnEntity', description: 'Spawn an object by model name.', fields: [{ name: 'model', label: 'Object model', value: DATA.entitySuggestions?.[0] || 'prop_barrier_work05' }] },
        ...(DATA.entitySuggestions || []).map(model => ({ label: model, type: 'action', action: 'spawnEntityQuick', value: model, description: `Spawn ${model}.` })),
        { label: 'Confirm Entity Position', type: 'info', description: 'Entities spawn directly in front of you and are placed on the ground.' },
        { label: 'Confirm Entity Position And Duplicate', type: 'info', description: 'Spawn the entity again to duplicate it at your current facing direction.' },
        { label: 'Cancel', type: 'info', description: 'Use Backspace, Arrow Left, right click, or ESC to leave entity spawning.' }
      ]
    }),

    connectionOptions: () => ({
      title: 'Connection Options',
      items: [
        { label: 'Quit Session', type: 'action', action: 'quitSession', description: 'Leave the current GTA Online style session.' },
        { label: 'Re-join Session', type: 'action', action: 'rejoinSession', description: 'Reconnect to the current server.' },
        { label: 'Quit Game', type: 'action', action: 'quitGame', description: 'Request the game to quit.' },
        { label: 'Disconnect From Server', type: 'action', action: 'disconnectFromServer', description: 'Disconnect from the current server.' }
      ]
    }),

    onlinePlayers: (ctx, snap) => ({
      title: 'Online Players',
      items: (snap.players || []).length
        ? (snap.players || []).map(player => ({ label: `[${player.id}] ${player.name}`, submenu: 'singlePlayer', context: { playerId: player.id, playerName: player.name }, description: 'Open player action menu.' }))
        : [{ label: 'No online players', type: 'info', description: 'There are no online players right now.' }]
    }),

    singlePlayer: (ctx) => ({
      title: String(ctx.playerName || 'Player'),
      items: [
        { label: 'Send Private Message', type: 'prompt', action: 'sendPrivateMessage', context: ctx, description: 'Send a private message to this player.', fields: [{ name: 'message', label: 'Message', value: 'Hello' }] },
        { label: 'Teleport To Player', type: 'action', action: 'teleportToPlayer', value: ctx.playerId, description: 'Teleport to this player.' },
        { label: 'Teleport Into Player Vehicle', type: 'action', action: 'teleportIntoPlayerVehicle', value: ctx.playerId, description: 'Move into the player\'s vehicle if possible.' },
        { label: 'Summon Player', type: 'action', action: 'summonPlayer', value: ctx.playerId, description: 'Bring this player to you.' },
        { label: 'Toggle GPS', type: 'action', action: 'toggleGPS', value: ctx.playerId, description: 'Set or clear a GPS waypoint for this player.' },
        { label: 'Spectate Player', type: 'action', action: 'spectatePlayer', value: ctx.playerId, description: 'Toggle spectator mode.' },
        { label: 'Print Identifiers', type: 'action', action: 'identifiers', value: ctx.playerId, description: 'Open this player\'s identifiers.' },
        { label: 'Kill Player', type: 'action', action: 'killPlayer', value: ctx.playerId, description: 'Kill this player.' },
        { label: 'Kick Player', type: 'prompt', action: 'kickPlayer', context: ctx, description: 'Kick this player with a reason.', fields: [{ name: 'reason', label: 'Kick reason', value: 'Rule violation' }] },
        { label: 'Ban Player Permanently', type: 'prompt', action: 'permBanPlayer', context: ctx, description: 'Ban this player permanently.', fields: [{ name: 'reason', label: 'Ban reason', value: 'Rule violation' }] },
        { label: 'Ban Player Temporarily', type: 'prompt', action: 'tempBanPlayer', context: ctx, description: 'Temp ban this player.', fields: [{ name: 'minutes', label: 'Ban length (minutes)', type: 'number', value: 60 }, { name: 'reason', label: 'Ban reason', value: 'Rule violation' }] }
      ]
    }),

    bannedPlayers: (ctx, snap) => ({
      title: 'Banned Players',
      items: (snap.bans || []).length
        ? (snap.bans || []).map((ban, index) => ({ label: ban.playerName || `Ban ${index + 1}`, submenu: 'bannedPlayerDetails', context: { banIndex: index }, description: ban.reason || 'No reason' }))
        : [{ label: 'No bans loaded', type: 'info', description: 'There may be no active bans or you may not have permission.' }]
    }),

    bannedPlayerDetails: (ctx, snap) => {
      const ban = (snap.bans || [])[ctx.banIndex] || {};
      const expiresAt = ban.expiresAt && Number(ban.expiresAt) > 0 ? new Date(Number(ban.expiresAt) * 1000).toLocaleString() : 'Permanent';
      return {
        title: String(ban.playerName || 'Banned Player'),
        items: [
          { label: 'Player Name', type: 'info', description: ban.playerName || 'Unknown' },
          { label: 'Banned By', type: 'info', description: ban.bannedBy || 'Unknown' },
          { label: 'Banned Until', type: 'info', description: expiresAt },
          { label: 'Player Identifiers', type: 'info', description: (ban.identifiers || []).join('\n') || 'No identifiers' },
          { label: 'Banned For', type: 'info', description: ban.reason || 'No reason' },
          { label: 'Unban', type: 'action', action: 'unbanPlayer', value: ctx.banIndex, description: 'Remove this ban entry.' }
        ]
      };
    }
  });

  Object.assign(baseMenus, {
    main: (ctx, snap) => {
      const fw = frameworkInfo(snap);
      return {
      title: 'Main Menu',
      items: [
        arrowEntry('Civilian Player Menu', 'civilianOptions', 'No-permission civilian tools: message players, pay players, and RP actions.'),
        arrowEntry('Vehicle Controls', 'civilianVehicleControls', 'Normal car controls that are always available and require no permissions.'),
        arrowEntry('Resource Commands', 'resourceCommands', 'Auto-detected registered commands from started resources.'),
        arrowEntry('Online Players', 'onlinePlayers', 'All currently connected players and staff tools.'),
        arrowEntry(fw.menuLabel, 'qbcoreManagement', `${fw.label} staff management: jobs, money, duty, revive, heal, and keys.`),
        arrowEntry('Banned Players', 'bannedPlayers', 'View and manage all banned players in this menu.'),
        arrowEntry('Player Related Options', 'playerRelated', 'Open this submenu for player related subcategories.'),
        arrowEntry('Vehicle Related Options', 'vehicleRelated', 'Open this submenu for vehicle related subcategories.'),
        arrowEntry('World Related Options', 'worldRelated', 'Open this submenu for world related subcategories.'),
        arrowEntry('Voice Chat Settings', 'voiceOptions', 'Change voice chat options here.'),
        arrowEntry('Recording Options', 'recordingOptions', 'In-game recording options.'),
        arrowEntry('Misc Settings', 'miscSettings', 'Miscellaneous AMenu options/settings can be configured here. You can also save your settings in this menu.'),
        arrowEntry('About AMenu', 'about', 'Information about AMenu.')
      ]
      };
    },

    civilianOptions: () => ({
      title: 'Civilian Player Menu',
      items: [
        arrowEntry('Online Players / Pay Player', 'civilianPlayers', 'Message players or give them cash/bank money. No staff permissions required.'),
        arrowEntry('Self / RP Actions', 'civilianSelfOptions', 'Hands up, ragdoll, clear tasks, and serious RP scenarios.'),
        arrowEntry('GPS Requests', 'civilianGpsRequests', 'Accept or deny GPS waypoint requests from other players.'),
        arrowEntry('Quick Scenarios', 'civilianAnimations', 'Start common lore-friendly civilian scenarios.'),
        { label: 'Clear Current Task', type: 'action', action: 'forceStopScenario', description: 'Stop your current animation/scenario.' },
        { label: 'Hands Up', type: 'action', action: 'civHandsUp', description: 'Play a hands-up RP animation.' },
        { label: 'Ragdoll / Trip', type: 'action', action: 'civRagdoll', description: 'Briefly ragdoll your character.' }
      ]
    }),

    civilianPlayers: (ctx, snap) => {
      const playerList = (snap.players || []).filter(player => Number(player.id) !== Number(snap.myServerId || 0));
      return {
        title: 'Civilian Online Players',
        items: playerList.length
          ? playerList.map(player => ({
              label: `[${player.id}] ${player.name}`,
              submenu: 'civilianPlayerActions',
              context: { playerId: player.id, playerName: player.name },
              description: 'Open no-permission player interactions.'
            }))
          : [{ label: 'No other online players', type: 'info', description: 'There are no other online players right now.' }]
      };
    },

    civilianPlayerActions: (ctx, snap) => {
      const targetId = Number(ctx.playerId || 0);
      const blocked = !!(((snap || {}).blockedPlayers || {})[String(targetId)]);
      return {
        title: String(ctx.playerName || 'Player'),
        items: [
          { label: 'Send Private Message', type: 'prompt', action: 'civPrivateMessage', context: ctx, description: blocked ? 'Unblock this player before messaging them.' : 'Send this player a normal no-permission private message.', fields: [{ name: 'message', label: 'Message', value: 'Hey!' }] },
          { label: blocked ? 'Unblock Messages' : 'Block Messages', type: 'action', action: 'civTogglePmBlock', value: targetId, description: blocked ? 'Allow this player to private message you again.' : 'Block private messages from this player.' },
          { label: 'Give Cash', type: 'prompt', action: 'civGiveMoney', context: ctx, description: 'Transfer cash from your active framework character to this player.', fields: [{ name: 'account', label: 'Account', value: 'cash' }, { name: 'amount', label: 'Amount', type: 'number', value: 100 }] },
          { label: 'Give Bank Money', type: 'prompt', action: 'civGiveMoney', context: ctx, description: 'Transfer bank money from your active framework character to this player.', fields: [{ name: 'account', label: 'Account', value: 'bank' }, { name: 'amount', label: 'Amount', type: 'number', value: 100 }] },
          { label: 'Request GPS Waypoint', type: 'action', action: 'civRequestGPS', value: targetId, description: 'Ask this player to share their location. They must accept before your waypoint is set.' }
        ]
      };
    },

    civilianGpsRequests: (ctx, snap) => ({
      title: 'GPS Requests',
      items: ((snap.gpsRequests || []).length)
        ? (snap.gpsRequests || []).map(req => ({
            label: `${req.name || 'Player'} [${req.requester}]`,
            submenu: 'civilianGpsRequestActions',
            context: req,
            description: 'This player wants a one-time GPS waypoint to your current location.'
          }))
        : [{ label: 'No pending GPS requests', type: 'info', description: 'GPS requests will show here when another player asks for your location.' }]
    }),

    civilianGpsRequestActions: (ctx) => ({
      title: `GPS Request: ${ctx.name || 'Player'}`,
      items: [
        { label: 'Accept GPS Request', type: 'action', action: 'civRespondGPS', value: { requester: ctx.requester, accepted: true }, description: 'Share your current location one time with this player.' },
        { label: 'Deny GPS Request', type: 'action', action: 'civRespondGPS', value: { requester: ctx.requester, accepted: false }, description: 'Deny this location request.' }
      ]
    }),

    civilianSelfOptions: () => ({
      title: 'Self / RP Actions',
      items: [
        { label: 'Hands Up', type: 'action', action: 'civHandsUp', description: 'Play a hands-up RP animation.' },
        { label: 'Ragdoll / Trip', type: 'action', action: 'civRagdoll', description: 'Briefly ragdoll your character.' },
        { label: 'Clear Current Task', type: 'action', action: 'forceStopScenario', description: 'Stop your current animation/scenario.' }
      ]
    }),

    civilianAnimations: () => ({
      title: 'Quick Scenarios',
      items: [
        ['Smoke', 'WORLD_HUMAN_SMOKING'],
        ['Clipboard', 'WORLD_HUMAN_CLIPBOARD'],
        ['Lean', 'WORLD_HUMAN_LEANING'],
        ['Cheer', 'WORLD_HUMAN_CHEERING'],
        ['Binoculars', 'WORLD_HUMAN_BINOCULARS'],
        ['Sit Bench', 'PROP_HUMAN_SEAT_BENCH'],
        ['Sit Chair', 'PROP_HUMAN_SEAT_CHAIR'],
        ['Mobile Film', 'WORLD_HUMAN_MOBILE_FILM_SHOCKING']
      ].map(([label, scenario]) => ({ label, type: 'action', action: 'startScenario', value: scenario, description: scenario })).concat([
        { label: 'Stop Scenario', type: 'action', action: 'forceStopScenario', description: 'Stop the active scenario.' }
      ])
    }),

    vehicleRelated: () => ({
      title: 'Vehicle Related Options',
      items: [
        arrowEntry('Vehicle Controls', 'civilianVehicleControls', 'Normal car controls that are always available and require no permissions.'),
        arrowEntry('Vehicle Options', 'vehicleOptions', 'Here you can change common vehicle options, as well as tune & style your vehicle.'),
        arrowEntry('Vehicle Spawner', 'vehicleSpawner', 'Spawn a vehicle by name or choose one from a specific category.'),
        arrowEntry('Saved Vehicles', 'savedVehicles', 'Save new vehicles, or spawn or delete already saved vehicles.'),
        arrowEntry('Personal Vehicle', 'personalVehicle', 'Set a vehicle as your personal vehicle, and control some things about that vehicle when you are not inside.')
      ]
    }),

    civilianVehicleControls: (ctx, snap) => ({
      title: 'Vehicle Controls',
      items: [
        { label: 'Toggle Engine', type: 'action', action: 'toggleEngine', description: 'Turn your current/nearby vehicle engine on or off.' },
        { label: 'Lock / Unlock Doors', type: 'action', action: 'lockVehicle', description: 'Lock or unlock the current/nearby vehicle.' },
        { label: 'Honk Horn', type: 'action', action: 'honkVehicle', description: 'Tap the horn.' },
        { label: 'Cycle Seats', type: 'action', action: 'cycleVehicleSeat', description: 'Move to the next free seat.' },
        arrowEntry('Seat Menu', 'civilianVehicleSeats', 'Move to a specific seat in your vehicle.'),
        arrowEntry('Doors / Hood / Trunk', 'civilianVehicleDoors', 'Open and close normal vehicle doors.'),
        arrowEntry('Windows', 'civilianVehicleWindows', 'Roll windows up/down.'),
        arrowEntry('Lights / Indicators', 'civilianVehicleLights', 'Headlights, high beams, blinkers, hazards and interior light.'),
        { label: 'Engine Always On', type: 'toggle', key: 'engineAlwaysOn', description: 'Keep the current vehicle engine running.' },
        { label: 'Anchor Boat', type: 'toggle', key: 'anchoredBoat', description: 'Toggle boat anchor when you are in a boat.' },
        { label: 'Speed Limiter', type: 'prompt', action: 'speedLimiter', description: 'Set max speed in mph. Enter 0 to clear.', fields: [{ name: 'speed', label: 'Max speed (mph, 0 disables)', type: 'number', value: ((snap.values || {}).speedLimitMph) || 0 }] },
        { label: 'Show Vehicle Health', type: 'toggle', key: 'showVehicleHealth', description: 'Draw engine and body health on-screen.' }
      ]
    }),

    civilianVehicleSeats: () => ({
      title: 'Seat Menu',
      items: [
        { label: 'Driver Seat', type: 'action', action: 'switchVehicleSeat', value: -1, description: 'Move to the driver seat if open.' },
        { label: 'Front Passenger', type: 'action', action: 'switchVehicleSeat', value: 0, description: 'Move to the front passenger seat if open.' },
        { label: 'Rear Left', type: 'action', action: 'switchVehicleSeat', value: 1, description: 'Move to rear left if open.' },
        { label: 'Rear Right', type: 'action', action: 'switchVehicleSeat', value: 2, description: 'Move to rear right if open.' },
        { label: 'Cycle Seats', type: 'action', action: 'cycleVehicleSeat', description: 'Move to the next free seat.' }
      ]
    }),

    civilianVehicleDoors: () => ({
      title: 'Doors / Hood / Trunk',
      items: [
        { label: 'Open All Doors', type: 'action', action: 'openAllDoors', description: 'Open all normal vehicle doors.' },
        { label: 'Close All Doors', type: 'action', action: 'closeAllDoors', description: 'Close all normal vehicle doors.' },
        { label: 'Toggle Driver Door', type: 'action', action: 'toggleDoor', value: 0, description: 'Open or close the driver door.' },
        { label: 'Toggle Passenger Door', type: 'action', action: 'toggleDoor', value: 1, description: 'Open or close the passenger door.' },
        { label: 'Toggle Rear Left Door', type: 'action', action: 'toggleDoor', value: 2, description: 'Open or close the rear left door.' },
        { label: 'Toggle Rear Right Door', type: 'action', action: 'toggleDoor', value: 3, description: 'Open or close the rear right door.' },
        { label: 'Toggle Hood', type: 'action', action: 'toggleDoor', value: 4, description: 'Open or close the hood.' },
        { label: 'Toggle Trunk', type: 'action', action: 'toggleDoor', value: 5, description: 'Open or close the trunk.' }
      ]
    }),

    civilianVehicleWindows: () => ({
      title: 'Windows',
      items: [
        { label: 'Roll All Windows Down', type: 'action', action: 'rollAllWindowsDown', description: 'Roll down all windows.' },
        { label: 'Roll All Windows Up', type: 'action', action: 'rollAllWindowsUp', description: 'Roll up all windows.' },
        { label: 'Toggle Driver Window', type: 'action', action: 'toggleWindow', value: 0, description: 'Roll driver window up/down.' },
        { label: 'Toggle Passenger Window', type: 'action', action: 'toggleWindow', value: 1, description: 'Roll passenger window up/down.' },
        { label: 'Toggle Rear Left Window', type: 'action', action: 'toggleWindow', value: 2, description: 'Roll rear left window up/down.' },
        { label: 'Toggle Rear Right Window', type: 'action', action: 'toggleWindow', value: 3, description: 'Roll rear right window up/down.' }
      ]
    }),

    civilianVehicleLights: () => ({
      title: 'Lights / Indicators',
      items: [
        { label: 'Toggle Headlights', type: 'action', action: 'toggleHeadlights', description: 'Toggle headlights.' },
        { label: 'Toggle High Beams', type: 'action', action: 'toggleHighbeams', description: 'Toggle high beams.' },
        { label: 'Toggle Left Blinker', type: 'action', action: 'toggleLeftIndicator', description: 'Toggle left indicator.' },
        { label: 'Toggle Right Blinker', type: 'action', action: 'toggleRightIndicator', description: 'Toggle right indicator.' },
        { label: 'Toggle Hazards', type: 'action', action: 'toggleHazards', description: 'Toggle both indicators.' },
        { label: 'Toggle Interior Light', type: 'action', action: 'toggleInteriorLight', description: 'Toggle interior light.' },
        { label: 'Disable Siren', type: 'toggle', key: 'sirenOff', description: 'Force the siren off on emergency vehicles.' },
        { label: 'Flash Highbeams On Honk', type: 'toggle', key: 'flashHighbeamsOnHonk', description: 'Flash highbeams while the horn is active.' }
      ]
    })
  });

  const commandGroups = window.AZURE_RESOURCE_COMMANDS || {};
  function canSeeStaffCommands(snap) {
    return !!(snap?.qb?.canAccessMenu || snap?.permissions?.canEdit);
  }
  function commandEntry(cmd) {
    const baseDescription = `${cmd.description || 'Resource information.'}${cmd.resource ? '\nResource: ' + cmd.resource : ''}`;
    if (cmd.type === 'info' || cmd.info || !cmd.command) {
      return {
        label: cmd.label || 'Information',
        type: 'info',
        description: baseDescription
      };
    }
    const usage = `/${cmd.command}${cmd.defaultArgs ? ' ' + cmd.defaultArgs : ''}`;
    const sourceText = cmd.source ? `\nSource: ${cmd.source}` : '';
    const restrictedText = cmd.restricted ? '\nRestricted: yes' : '';
    const description = `${cmd.description || 'Run resource command.'}\nResource: ${cmd.resource || 'unknown'}${sourceText}${restrictedText}\nUsage: ${usage}`;
    const context = { ...cmd };
    if (cmd.argsLabel || cmd.defaultArgs) {
      return {
        label: cmd.label || `/${cmd.command}`,
        type: 'prompt',
        action: 'runResourceCommand',
        context,
        description,
        fields: [{ name: 'args', label: cmd.argsLabel || 'Command arguments', value: cmd.defaultArgs || '' }]
      };
    }
    return {
      label: cmd.label || `/${cmd.command}`,
      type: 'action',
      action: 'runResourceCommand',
      value: context,
      description
    };
  }
  function commandGroupItems(groupId, snap) {
    const group = commandGroups[groupId] || { items: [] };
    if (group.staffOnly && !canSeeStaffCommands(snap)) {
      return [{ label: 'Staff Only', type: 'info', description: 'This command category is hidden unless you have framework/staff permissions.' }];
    }
    const items = (group.items || []).map(commandEntry);
    if (!items.length) return [{ label: 'No commands found', type: 'info', description: 'No commands were added to this category.' }];
    return items;
  }

  function registeredCommands(snap) {
    const commands = Array.isArray(snap?.registeredCommands) ? snap.registeredCommands : [];
    const seen = new Set();
    return commands
      .filter(cmd => cmd && (cmd.command || cmd.name || cmd.label))
      .map(cmd => {
        const name = String(cmd.command || cmd.name || cmd.label || '').replace(/^\/+/, '');
        const source = String(cmd.source || 'unknown');
        const resource = String(cmd.resource || source || 'unknown');
        return {
          ...cmd,
          name,
          command: name,
          label: cmd.label || `/${name}`,
          resource,
          source,
          restricted: cmd.restricted === true,
          argsLabel: cmd.argsLabel || 'Optional arguments',
          defaultArgs: cmd.defaultArgs || ''
        };
      })
      .filter(cmd => {
        if (!cmd.name) return false;
        const key = `${cmd.source}:${cmd.resource}:${cmd.name}`;
        if (seen.has(key)) return false;
        seen.add(key);
        return true;
      })
      .sort((a, b) => {
        const ar = String(a.resource || '').localeCompare(String(b.resource || ''));
        if (ar !== 0) return ar;
        return String(a.name || '').localeCompare(String(b.name || ''));
      });
  }

  function registeredCommandGroups(snap) {
    const map = new Map();
    registeredCommands(snap).forEach(cmd => {
      const key = cmd.resource || cmd.source || 'unknown';
      if (!map.has(key)) map.set(key, []);
      map.get(key).push(cmd);
    });
    return Array.from(map.entries())
      .map(([resource, items]) => ({
        resource,
        count: items.length,
        sources: Array.from(new Set(items.map(i => i.source || 'unknown'))).join(', ')
      }))
      .sort((a, b) => a.resource.localeCompare(b.resource));
  }

  function registeredCommandsForResource(resource, snap) {
    const items = registeredCommands(snap)
      .filter(cmd => String(cmd.resource || cmd.source || 'unknown') === String(resource || 'unknown'))
      .map(cmd => commandEntry({
        ...cmd,
        label: `/${cmd.name}`,
        command: cmd.name,
        argsLabel: 'Optional arguments',
        defaultArgs: '',
        description: cmd.description || `Auto-detected ${cmd.source || 'registered'} command.`
      }));
    if (!items.length) return [{ label: 'No commands found', type: 'info', description: 'No currently registered commands were found for this resource.' }];
    return items;
  }

  function fallbackResourceCommandMenu(snap) {
    return [
      arrowEntry('Citizen / Civilian', 'resourceCommandsCitizen', 'Marketplace, lottery, daily, updates, skills, MORS, emotes and civilian commands.'),
      arrowEntry('Housing / Real Estate', 'resourceCommandsHousing', 'Housing portal, owner/seller tools, admin placement, and quick usage guides.'),
      arrowEntry('Hunting / Fishing / Outdoors', 'resourceCommandsOutdoors', 'MyODFW, warden lookup, hunting harvests, fishing, fish finder, and boat anchor.'),
      arrowEntry('Public Works / SADOT / SAG&E', 'resourceCommandsPublicWorks', 'Unified public works dispatch, citizen reports, utility calls, repair flow, and SADOT legacy commands.'),
      arrowEntry('Drugs / Illegal RP Systems', 'resourceCommandsDrugs', 'Drug processing help and safe cleanup commands without bypassing serious RP item/location checks.'),
      arrowEntry('Jobs / Work', 'resourceCommandsJobs', 'Trucking, VU, weapon shop, emergency spawner and work commands.'),
      arrowEntry('Police / EMS / Government', 'resourceCommandsLaw', 'MDT, complaint, outdoors enforcement, lockdown, radar and emergency light commands.'),
      arrowEntry('Vehicles / Offroad / Mechanic', 'resourceCommandsVehicles', 'Suspension, winch, offroad, plates, indicators and traffic tools.'),
      arrowEntry('Camping / RP Props', 'resourceCommandsCamping', 'Tent, campfire, chair and camping cleanup commands.'),
      ...(canSeeStaffCommands(snap) ? [arrowEntry('Admin / Staff', 'resourceCommandsAdmin', 'Admin/debug commands found in the resource pack.')] : [{ label: 'Admin / Staff', type: 'info', description: 'Hidden until you have staff/framework management permissions.' }])
    ];
  }

  Object.assign(baseMenus, {
    resourceCommands: (ctx, snap) => {
      const groups = registeredCommandGroups(snap);
      if (!groups.length) {
        return { title: 'Resource Commands', items: fallbackResourceCommandMenu(snap) };
      }
      return {
        title: 'Resource Commands',
        items: groups.map(group => ({
          label: group.resource,
          submenu: 'registeredCommandResource',
          context: { resource: group.resource },
          description: `${group.count} registered command${group.count === 1 ? '' : 's'} detected. Source: ${group.sources}.`
        }))
      };
    },
    registeredCommandResource: (ctx, snap) => ({
      title: String(ctx.resource || 'Registered Commands'),
      items: registeredCommandsForResource(ctx.resource, snap)
    }),
    resourceCommandsCitizen: (ctx, snap) => ({ title: commandGroups.citizen?.title || 'Citizen Commands', items: commandGroupItems('citizen', snap) }),
    resourceCommandsHousing: (ctx, snap) => ({ title: commandGroups.housing?.title || 'Housing Commands', items: commandGroupItems('housing', snap) }),
    resourceCommandsOutdoors: (ctx, snap) => ({ title: commandGroups.outdoors?.title || 'Outdoors Commands', items: commandGroupItems('outdoors', snap) }),
    resourceCommandsPublicWorks: (ctx, snap) => ({ title: commandGroups.publicworks?.title || 'Public Works Commands', items: commandGroupItems('publicworks', snap) }),
    resourceCommandsDrugs: (ctx, snap) => ({ title: commandGroups.drugs?.title || 'Drug System Commands', items: commandGroupItems('drugs', snap) }),
    resourceCommandsCamping: (ctx, snap) => ({ title: commandGroups.camping?.title || 'Camping Commands', items: commandGroupItems('camping', snap) }),
    resourceCommandsJobs: (ctx, snap) => ({ title: commandGroups.jobs?.title || 'Job Commands', items: commandGroupItems('jobs', snap) }),
    resourceCommandsLaw: (ctx, snap) => ({ title: commandGroups.law?.title || 'Law Commands', items: commandGroupItems('law', snap) }),
    resourceCommandsVehicles: (ctx, snap) => ({ title: commandGroups.vehicles?.title || 'Vehicle Commands', items: commandGroupItems('vehicles', snap) }),
    resourceCommandsAdmin: (ctx, snap) => ({ title: commandGroups.admin?.title || 'Admin Commands', items: commandGroupItems('admin', snap) })
  });

  function getCurrentEntry() {
    if (!Array.isArray(state.stack) || !state.stack.length) state.stack = [{ id: 'main', selected: 0 }];
    const entry = state.stack[state.stack.length - 1] || { id: 'main', selected: 0 };
    if (typeof entry.selected !== 'number' || Number.isNaN(entry.selected)) entry.selected = 0;
    return entry;
  }

  function syncSelectedToStack() {
    const entry = getCurrentEntry();
    entry.selected = state.selected || 0;
  }

  function getMenu(entry = state.stack[state.stack.length - 1]) {
    const snap = getSnapshot();
    const fn = baseMenus[entry.id] || baseMenus.main;
    return fn(entry.context || {}, snap);
  }

  function decorateItem(item) {
    const snap = getSnapshot();
    const out = { ...item };
    if (item.type === 'toggle') out.right = ((snap.toggles || {})[item.key]) ? '☑' : '☐';
    else if (item.type === 'cycle') {
      const index = Number((((snap.values || {})[item.key]) != null ? ((snap.values || {})[item.key]) : 0)) || 0;
      out.right = ((item.options || [])[index]) || `${index}`;
    } else if (item.submenu) out.right = '>>>';
    else if (item.right) out.right = item.right;
    else out.right = '';
    return out;
  }

  function getCurrentItems() {
    const menu = getMenu();
    return (menu.items || []).map(item => decorateItem(item));
  }

  function hashMenuId(value) {
    const str = String(value || 'main');
    let hash = 0;
    for (let i = 0; i < str.length; i += 1) hash = ((hash << 5) - hash) + str.charCodeAt(i);
    return Math.abs(hash);
  }

  function getBannerImageForCurrentMenu(ui, preset) {
    const map = ui.menuBanners || {};
    const cycle = Array.isArray(ui.bannerCycle) ? ui.bannerCycle : [];
    const entry = getCurrentEntry();
    const menuId = entry?.id || 'main';
    if (map[menuId]) return map[menuId];
    const stack = Array.isArray(state.stack) ? state.stack : [];
    for (let i = stack.length - 1; i >= 0; i -= 1) {
      const stackId = stack[i]?.id;
      if (stackId && map[stackId]) return map[stackId];
    }
    if (cycle.length) return cycle[hashMenuId(menuId) % cycle.length];
    return preset.bannerImage || ui.bannerImage || '';
  }

  const effectClassPrefix = 'effect-';

  function applyUiSettings() {
    const snap = getSnapshot();
    const ui = snap.ui || {};
    const presetMap = buildPresetMap(snap);
    const presetKey = ui.preset || ui.theme || Object.keys(presetMap)[0] || 'blue';
    const preset = presetMap[presetKey] || presetMap.blue || Object.values(presetMap)[0];

    document.documentElement.style.setProperty('--theme-1', preset.t1);
    document.documentElement.style.setProperty('--theme-2', preset.t2);
    document.documentElement.style.setProperty('--theme-3', preset.t3);
    document.documentElement.style.setProperty('--title', preset.title);
    document.documentElement.style.setProperty('--count', preset.count);
    document.documentElement.style.setProperty('--list-bg', preset.listBg);
    document.documentElement.style.setProperty('--row-bg', preset.rowBg);
    document.documentElement.style.setProperty('--text', preset.text);
    document.documentElement.style.setProperty('--active-bg', preset.activeBg);
    document.documentElement.style.setProperty('--active-text', preset.activeText);
    document.documentElement.style.setProperty('--panel-border', preset.border);
    document.documentElement.style.setProperty('--panel-border-strong', preset.borderStrong);
    document.documentElement.style.setProperty('--header-overlay', preset.headerOverlay);
    document.documentElement.style.setProperty('--shadow', preset.glow || 'none');
    document.documentElement.style.setProperty('--shadow-strong', preset.glowStrong || preset.glow || 'none');
    document.documentElement.style.setProperty('--scroll-track', preset.scrollTrack || 'rgba(8, 12, 18, 0.72)');
    document.documentElement.style.setProperty('--scroll-thumb', preset.scrollThumb || preset.t2 || 'rgba(255,255,255,0.22)');
    document.documentElement.style.setProperty('--scroll-thumb-active', preset.scrollThumbActive || preset.t3 || preset.t2 || 'rgba(255,255,255,0.34)');
    document.documentElement.style.setProperty('--input-bg', preset.inputBg || 'rgba(255,255,255,0.06)');
    document.documentElement.style.setProperty('--input-border', preset.inputBorder || preset.borderStrong || 'rgba(255,255,255,0.12)');
    document.documentElement.style.setProperty('--input-text', preset.inputText || preset.text || '#ffffff');
    document.documentElement.style.setProperty('--modal-bg', preset.modalBg || 'rgba(0,0,0,0.94)');

    brandText.textContent = preset.brandText || ui.brandText || 'AMenu';
    const scale = Number(ui.scale || 1);
    shell.style.transform = `scale(${scale})`;
    shell.style.top = `${Number(ui.offsetY ?? 18)}px`;
    if (ui.rightAlign || snap.toggles?.rightAlign) {
      shell.classList.add('right');
      shell.classList.remove('left');
      shell.style.right = `${Number(ui.offsetX ?? 18)}px`;
      shell.style.left = 'auto';
    } else {
      shell.classList.add('left');
      shell.classList.remove('right');
      shell.style.left = `${Number(ui.offsetX ?? 18)}px`;
      shell.style.right = 'auto';
    }

    const effectName = String(preset.effect || '').trim().toLowerCase().replace(/[^a-z0-9_-]/g, '-');
    Array.from(shell.classList).filter(name => name.startsWith(effectClassPrefix)).forEach(name => shell.classList.remove(name));
    if (effectName && effectName !== 'classic') shell.classList.add(`${effectClassPrefix}${effectName}`);

    const bannerImage = getBannerImageForCurrentMenu(ui, preset);
    const bannerLogoValue = preset.bannerLogo || ui.bannerLogo;
    const headerHeight = Number(ui.headerHeight || 112);
    const bannerFitMode = String(ui.bannerFitMode || 'contain').toLowerCase();
    const bannerPosition = String(ui.bannerPosition || 'center center');
    const overlayOpacity = Math.max(0, Math.min(0.60, Number(ui.bannerOverlayOpacity ?? 0.04)));
    const fitCss = bannerFitMode === 'cover' ? 'cover' : (bannerFitMode === 'stretch' ? '100% 100%' : 'contain');

    document.documentElement.style.setProperty('--header-height', `${headerHeight}px`);
    menuHeader.classList.toggle('has-banner', !!bannerImage);
    if (bannerImage) {
      menuHeader.style.backgroundImage = `linear-gradient(180deg, rgba(0,0,0,${overlayOpacity}), rgba(0,0,0,${overlayOpacity})), url('${bannerImage}')`;
      menuHeader.style.backgroundSize = `100% 100%, ${fitCss}`;
      menuHeader.style.backgroundPosition = `center center, ${bannerPosition}`;
      menuHeader.style.backgroundRepeat = 'no-repeat, no-repeat';
    } else {
      menuHeader.style.backgroundImage = `linear-gradient(180deg, var(--theme-1), var(--theme-2))`;
      menuHeader.style.backgroundSize = '100% 100%';
      menuHeader.style.backgroundPosition = 'center center';
      menuHeader.style.backgroundRepeat = 'no-repeat';
    }
    if (bannerLogoValue) {
      bannerLogo.src = bannerLogoValue;
      bannerLogo.classList.remove('hidden');
    } else {
      bannerLogo.classList.add('hidden');
      bannerLogo.removeAttribute('src');
    }
  }

  function updateSelectedVisual(forceTop = false) {
    const items = getCurrentItems();
    if (!items.length) return render();
    state.selected = Math.max(0, Math.min(state.selected, items.length - 1));

    const selected = items[state.selected];
    menuCountEl.textContent = `${state.selected + 1} / ${items.length}`;
    descriptionTextEl.textContent = (selected && selected.description) || 'No option selected.';

    const rows = menuListEl.querySelectorAll('.menu-item');
    rows.forEach((row, idx) => row.classList.toggle('active', idx === state.selected));

    const active = rows[state.selected];
    if (active) {
      if (forceTop || state.selected === 0) menuListEl.scrollTop = 0;
      active.scrollIntoView({ block: 'nearest' });
    }
  }

  function setSelected(index) {
    const items = getCurrentItems();
    if (!items.length) return render();
    state.selected = Math.max(0, Math.min(index, items.length - 1));
    syncSelectedToStack();
    persistNavState();
    updateSelectedVisual(state.selected === 0);
  }

  async function refreshSnapshot() {
    const res = await nui('getState', {});
    if (res?.ok) {
      state.snapshot = res.state;
      applyUiSettings();
      render();
    }
  }

  function render() {
    applyUiSettings();
    const menu = getMenu();
    const items = getCurrentItems();
    if (state.selected > items.length - 1) state.selected = Math.max(0, items.length - 1);
    syncSelectedToStack();
    const selected = items[state.selected];
    menuTitleEl.textContent = menu.title || 'MENU';
    menuCountEl.textContent = items.length ? `${state.selected + 1} / ${items.length}` : '0 / 0';
    descriptionTextEl.textContent = (selected && selected.description) || 'No option selected.';
    menuListEl.innerHTML = items.map((item, index) => `
      <div class="menu-item ${index === state.selected ? 'active' : ''} ${item.disabled ? 'disabled' : ''}" data-index="${index}">
        <div class="label">${item.label}</div>
        <div class="${item.submenu ? 'arrow' : item.type === 'toggle' ? 'check' : 'value'}">${item.right || ''}</div>
      </div>
    `).join('');
    scrollActiveIntoView(state.selected === 0);
  }

  async function handleResponse(res) {
    if (res?.state) state.snapshot = res.state;
    applyUiSettings();
    render();
    if (res?.extra?.displayText) {
      openDisplayModal({
        title: res.extra.title || 'Details',
        text: res.extra.displayText,
        copyText: res.extra.copyText || ''
      });
    }
    showToast(res?.message || 'Done');
  }

  async function execute(item) {
    if (!item || item.disabled || item.type === 'info') return;
    if (item.submenu) {
      syncSelectedToStack();
      state.stack.push({ id: item.submenu, context: item.context || {}, selected: 0 });
      state.selected = 0;
      persistNavState();
      setNavGuard(120);
      return render();
    }
    if (item.type === 'prompt') {
      const result = await requestPromptInput({ title: item.label, fields: item.fields || [] });
      if (!result) return;
      const res = await nui('exec', { action: item.action, value: result, context: item.context || null });
      return handleResponse(res);
    }
    if (item.type === 'toggle') {
      const res = await nui('exec', { action: 'toggle', key: item.key });
      return handleResponse(res);
    }
    if (item.type === 'cycle') {
      const snap = getSnapshot();
      const current = Number((((snap.values || {})[item.key]) != null ? ((snap.values || {})[item.key]) : 0)) || 0;
      const next = (current + 1) % item.options.length;
      const res = await nui('exec', { action: 'setValue', key: item.key, value: next });
      return handleResponse(res);
    }
    const res = await nui('exec', { action: item.action, value: (item.value != null ? item.value : null), context: item.context || null });
    return handleResponse(res);
  }

  function back() {
    if (state.modalOpen) return closeModal(false);
    if (state.stack.length > 1) {
      state.stack.pop();
      state.selected = Math.max(0, Number(getCurrentEntry().selected || 0));
      persistNavState();
      setNavGuard(120);
      render();
    } else {
      closeUi();
    }
  }

  function persistNavState() {
    syncSelectedToStack();
    try { localStorage.setItem('amenu_ui_last_stack', JSON.stringify(state.stack || [{ id: 'main', selected: 0 }])); } catch (e) {}
  }

  function loadNavState() {
    try {
      const raw = localStorage.getItem('amenu_ui_last_stack');
      if (!raw) return [{ id: 'main', selected: 0 }];
      const parsed = JSON.parse(raw);
      if (!Array.isArray(parsed) || !parsed.length) return [{ id: 'main', selected: 0 }];
      return parsed.map(entry => ({
        id: entry?.id || 'main',
        context: entry?.context || {},
        selected: Math.max(0, Number(entry?.selected || 0))
      }));
    } catch (e) {
      return [{ id: 'main', selected: 0 }];
    }
  }

  async function openUi() {
    state.open = true;
    state.stack = [{ id: 'main', selected: 0 }];
    state.selected = 0;
    menuListEl.scrollTop = 0;
    setNavGuard(150);
    shell.classList.add('open');
    shell.classList.remove('hidden');
    await refreshSnapshot();
    persistNavState();
  }

  function closeUi(notify = true) {
    persistNavState();
    state.open = false;
    state.modalOpen = false;
    modal.classList.add('hidden');
    if (typeof GetParentResourceName === 'function') nui('setModalInputMode', { enabled: false });
    shell.classList.remove('open');
    shell.classList.add('hidden');
    if (notify) nui('close', {});
  }

  window.addEventListener('message', (event) => {
    const data = event.data || {};
    if (data.action === 'open') openUi();
    if (data.action === 'close') closeUi(false);
    if (data.action === 'menuWheel') {
      if (!state.open || state.modalOpen || navGuardActive()) return;
      const direction = Number(data.direction || 0);
      if (direction > 0) setSelected(state.selected + 1);
      else if (direction < 0) setSelected(state.selected - 1);
    }
    if (data.action === 'menuPress') {
      if (!state.open || state.modalOpen || navGuardActive()) return;
      const items = getCurrentItems();
      if (data.press === 'enter') void execute(items[state.selected]);
      else if (data.press === 'back') back();
    }
  });

  document.addEventListener('keydown', async (event) => {
    if (!state.open) return;
    if (navGuardActive()) return;
    if (state.modalOpen) {
      if (event.key === 'Escape') { event.preventDefault(); closeModal(false); }
      if (event.key === 'Enter' && state.modalMode === 'form') { event.preventDefault(); closeModal(true); }
      return;
    }
    const items = getCurrentItems();
    if (event.key.toLowerCase() === 'm') { event.preventDefault(); return closeUi(); }
    if (event.key === 'Escape') { event.preventDefault(); return closeUi(); }
    if (event.key === 'Backspace' || event.key === 'ArrowLeft') { event.preventDefault(); return back(); }
    if (event.key === 'ArrowUp') { event.preventDefault(); return setSelected(state.selected - 1); }
    if (event.key === 'ArrowDown') { event.preventDefault(); return setSelected(state.selected + 1); }
    if (event.key === 'Enter' || event.key === 'ArrowRight') { event.preventDefault(); return execute(items[state.selected]); }
  });

  shell.addEventListener('wheel', (event) => {
    if (!state.open || state.modalOpen || navGuardActive()) return;
    event.preventDefault();
    if (event.deltaY > 0) setSelected(state.selected + 1);
    else if (event.deltaY < 0) setSelected(state.selected - 1);
  }, { passive: false });

  shell.addEventListener('contextmenu', (event) => {
    if (!state.open) return;
    event.preventDefault();
    if (!state.modalOpen) back();
  });

  shell.addEventListener('mousedown', async (event) => {
    if (!state.open || state.modalOpen || navGuardActive()) return;
    if (event.button === 0 && !event.target.closest('.menu-item')) {
      event.preventDefault();
      await execute(getCurrentItems()[state.selected]);
    } else if (event.button === 2) {
      event.preventDefault();
      back();
    }
  });

  menuListEl.addEventListener('click', async (event) => {
    if (navGuardActive()) return;
    const row = event.target.closest('.menu-item');
    if (!row) return;
    setSelected(Number(row.dataset.index || 0));
    await execute(getCurrentItems()[state.selected]);
  });
})();
