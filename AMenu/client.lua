local uiOpen = false
local pending = {}
local reqId = 0
local personalBlip = nil
local playerBlips = {}
local presetLocationBlips = {}
local lastKnownDeathState = {}
local spectatingTarget = nil
local dynamicWeatherIndex = 1
local dynamicWeatherTimer = 0
local dynamicWeatherList = { 'CLEAR', 'EXTRASUNNY', 'CLOUDS', 'OVERCAST', 'RAIN', 'THUNDER', 'FOGGY', 'SMOG' }
local currentWorld = { hour = 12, minute = 0, freezeTime = false, weather = 'CLEAR', dynamicWeather = false, blackout = false, clouds = 'default' }
local vehicleCatalogDirty = true
local vehicleCatalogBuilt = false
local buildVehicleCatalog
local awaitServer
local state
local noclipState = { entity = 0, isVehicle = false, speedIndex = 3, followCam = true, lastToggle = 0 }

local function invalidateVehicleCatalog()
  vehicleCatalogDirty = true
end

local function ensureVehicleCatalog(force)
  if not force and vehicleCatalogBuilt and not vehicleCatalogDirty and state and state.vehicleCatalog and state.vehicleModelLookup then return end
  if buildVehicleCatalog then buildVehicleCatalog() end
end

local function worldSyncEnabled()
  return Config and Config.World and Config.World.manageSync == true
end

local function worldControlsEnabled()
  return Config and Config.World and Config.World.allowMenuControls == true
end
local voiceRanges = { 2.5, 8.0, 20.0 }
local vehicleClassNames = {
  [0] = 'Compacts',
  [1] = 'Sedans',
  [2] = 'SUVs',
  [3] = 'Coupes',
  [4] = 'Muscle',
  [5] = 'Sports Classics',
  [6] = 'Sports',
  [7] = 'Super',
  [8] = 'Motorcycles',
  [9] = 'Off-road',
  [10] = 'Industrial',
  [11] = 'Utility',
  [12] = 'Vans',
  [13] = 'Cycles',
  [14] = 'Boats',
  [15] = 'Helicopters',
  [16] = 'Planes',
  [17] = 'Service',
  [18] = 'Emergency',
  [19] = 'Military',
  [20] = 'Commercial',
  [21] = 'Trains',
  [22] = 'Open Wheel'
}

local b64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

state = {
  serverName = GetConvar('sv_hostname', 'AMenu'),
  serverText = 'Custom FiveM resource',
  toggles = {
    rightAlign = (Config and Config.UI and Config.UI.defaultRightAlign) or false,
    disablePrivateMessages = false,
    disableControllerSupport = false,
    showSpeedKmh = false,
    showSpeedMph = false,
    locationDisplay = false,
    showCoords = false,
    nightVision = false,
    thermalVision = false,
    overheadNames = false,
    playerBlips = false,
    god = false,
    invisible = false,
    unlimitedStamina = false,
    fastRun = false,
    fastSwim = false,
    superJump = false,
    noRagdoll = false,
    neverWanted = false,
    ignored = false,
    stayInVehicle = false,
    freezePlayer = false,
    noclip = false,
    vehicleGod = false,
    vehicleInvisible = false,
    vehicleFreeze = false,
    keepClean = false,
    engineAlwaysOn = false,
    unlimitedAmmo = false,
    noReload = false,
    voiceEnabled = true,
    showCurrentSpeaker = false,
    staffChannel = false,
    freezeTime = false,
    dynamicWeather = false,
    blackout = false,
    replaceOldVehicle = true,
    spawnInsideVehicle = true,
    reserveParachute = false,
    parachuteAutoEquip = false,
    parachuteUnlimited = false,
    bikeSeatbelt = false,
    planeTurbulence = false,
    heliTurbulence = false,
    anchoredBoat = false,
    sirenOff = false,
    noBikeHelmet = false,
    flashHighbeamsOnHonk = false,
    showVehicleHealth = false,
    infiniteFuel = false,
    defaultRadio = false,
    vehicleLightsBlackout = false,
    snowEffects = false,
    showTime = false,
    showMicStatus = false,
    hideRadar = false,
    hideHud = false,
    joinQuitNotifications = false,
    deathNotifications = false,
    locationBlips = false,
    respawnDefaultMp = false,
    exclusiveDriver = false,
    cameraLockH = false,
    cameraLockV = false,
    autoRepairVehicle = false,
    strongWheels = false,
    protectEngineDamage = false,
    protectVisualDamage = false,
    rampDamageProtection = false,
  },
  values = {
    speedLimitMph = 0,
    voiceRangeIndex = 1,
    drivingStyle = 786603,
    timeHour = 12,
    timeMinute = 0,
    voiceChannel = 0,
    radioStation = 'OFF',
    walkingStyle = 'default',
    defaultLoadoutIndex = -1,
  },
  ui = {
    rightAlign = (Config and Config.UI and Config.UI.defaultRightAlign) or false,
    offsetX = (Config and Config.UI and Config.UI.defaultOffsetX) or 18,
    offsetY = (Config and Config.UI and Config.UI.defaultOffsetY) or 18,
    scale = (Config and Config.UI and Config.UI.defaultScale) or 1.0,
    theme = (Config and Config.UI and Config.UI.defaultTheme) or 'blue',
    preset = (Config and Config.UI and Config.UI.defaultPreset) or ((Config and Config.UI and Config.UI.defaultTheme) or 'blue'),
    allowThemeSelection = not (Config and Config.UI and Config.UI.allowUserThemeSelection == false),
    allowPositioning = not (Config and Config.UI and Config.UI.allowUserPositioning == false),
    allowBannerEditing = not (Config and Config.UI and Config.UI.allowUserBannerEditing == false),
    brandText = (Config and Config.UI and Config.UI.brandText) or 'AMenu',
    bannerImage = (Config and Config.UI and Config.UI.bannerImage) or '',
    bannerLogo = (Config and Config.UI and Config.UI.bannerLogo) or '',
    headerHeight = tonumber((Config and Config.UI and Config.UI.headerHeight) or 112) or 112,
    bannerFitMode = tostring((Config and Config.UI and Config.UI.bannerFitMode) or 'contain'),
    bannerPosition = tostring((Config and Config.UI and Config.UI.bannerPosition) or 'center center'),
    bannerOverlayOpacity = tonumber((Config and Config.UI and Config.UI.bannerOverlayOpacity) or 0.04) or 0.04,
    presets = (Config and Config.UI and Config.UI.presets) or {},
    menuBanners = (Config and Config.UI and Config.UI.menuBanners) or {},
    bannerCycle = (Config and Config.UI and Config.UI.bannerCycle) or {},
  },
  savedVehicles = {},
  savedVehicleCategories = {},
  savedVehicleClasses = {},
  savedVehicleCategoryGroups = {},
  unavailableSavedVehicles = {},
  savedPeds = {},
  savedOutfits = {},
  loadouts = {},
  blockedPlayers = {},
  pendingGpsRequests = {},
  gpsRequests = {},
  players = {},
  bans = {},
  permissions = { canEdit = false, principals = {}, aces = {}, commonGroups = {} },
  qb = { enabled = false, coreStarted = false, canAccessMenu = false, players = {} },
  registeredCommands = {},
  vehicle = { extras = {} },
  addons = { vehicles = {}, vehicleEntries = {}, vehicleCategories = {}, peds = {}, weapons = {}, weapon_components = {} },
  personalVehicle = nil,
  restore = { appearance = nil, weapons = nil },
  vehicleCatalog = nil,
  vehicleModelLookup = {},
}

local weaponList = {
  'WEAPON_PISTOL','WEAPON_COMBATPISTOL','WEAPON_APPISTOL','WEAPON_PISTOL50','WEAPON_HEAVYPISTOL','WEAPON_SNSPISTOL','WEAPON_VINTAGEPISTOL','WEAPON_MARKSMANPISTOL','WEAPON_MACHINEPISTOL','WEAPON_PISTOL_MK2',
  'WEAPON_REVOLVER','WEAPON_DOUBLEACTION','WEAPON_NAVYREVOLVER','WEAPON_CERAMICPISTOL','WEAPON_GADGETPISTOL','WEAPON_PISTOLXM3','WEAPON_MICROSMG','WEAPON_MINISMG','WEAPON_SMG','WEAPON_SMG_MK2','WEAPON_ASSAULTSMG','WEAPON_COMBATPDW','WEAPON_MG','WEAPON_COMBATMG','WEAPON_COMBATMG_MK2',
  'WEAPON_ASSAULTRIFLE','WEAPON_ASSAULTRIFLE_MK2','WEAPON_CARBINERIFLE','WEAPON_CARBINERIFLE_MK2','WEAPON_ADVANCEDRIFLE','WEAPON_SPECIALCARBINE','WEAPON_SPECIALCARBINE_MK2','WEAPON_BULLPUPRIFLE','WEAPON_BULLPUPRIFLE_MK2','WEAPON_COMPACTRIFLE','WEAPON_HEAVYRIFLE','WEAPON_MILITARYRIFLE','WEAPON_TACTICALRIFLE','WEAPON_SERVICECARBINE','WEAPON_BATTLERIFLE',
  'WEAPON_PUMPSHOTGUN','WEAPON_PUMPSHOTGUN_MK2','WEAPON_SAWNOFFSHOTGUN','WEAPON_BULLPUPSHOTGUN','WEAPON_ASSAULTSHOTGUN','WEAPON_MUSKET','WEAPON_HEAVYSHOTGUN','WEAPON_DBSHOTGUN','WEAPON_AUTOSHOTGUN','WEAPON_COMBATSHOTGUN',
  'WEAPON_SNIPERRIFLE','WEAPON_HEAVYSNIPER','WEAPON_HEAVYSNIPER_MK2','WEAPON_MARKSMANRIFLE','WEAPON_MARKSMANRIFLE_MK2','WEAPON_PRECISIONRIFLE',
  'WEAPON_GRENADE','WEAPON_STICKYBOMB','WEAPON_SMOKEGRENADE','WEAPON_BZGAS','WEAPON_MOLOTOV','WEAPON_FLARE','WEAPON_PROXMINE','WEAPON_PIPEBOMB','WEAPON_SNOWBALL',
  'WEAPON_RPG','WEAPON_MINIGUN','WEAPON_GRENADELAUNCHER','WEAPON_COMPACTLAUNCHER','WEAPON_HOMINGLAUNCHER','WEAPON_RAILGUN','WEAPON_EMPLAUNCHER','WEAPON_FIREWORK',
  'WEAPON_KNIFE','WEAPON_NIGHTSTICK','WEAPON_HAMMER','WEAPON_BAT','WEAPON_GOLFCLUB','WEAPON_CROWBAR','WEAPON_BOTTLE','WEAPON_DAGGER','WEAPON_HATCHET','WEAPON_MACHETE','WEAPON_SWITCHBLADE','WEAPON_KNUCKLE','WEAPON_POOLCUE','WEAPON_WRENCH','WEAPON_STONE_HATCHET','WEAPON_CANDYCANE','WEAPON_STUNROD',
  'WEAPON_FIREEXTINGUISHER','WEAPON_PETROLCAN','WEAPON_HAZARDCAN','WEAPON_FERTILIZERCAN','GADGET_PARACHUTE','WEAPON_STUNGUN','WEAPON_STUNGUN_MP','WEAPON_RAYPISTOL','WEAPON_RAYCARBINE','WEAPON_RAYMINIGUN','WEAPON_TECPISTOL'
}

local function notify(msg)
  BeginTextCommandThefeedPost('STRING')
  AddTextComponentSubstringPlayerName(msg)
  EndTextCommandThefeedPostTicker(false, false)
end

local function trimString(value)
  return tostring(value or ''):gsub('^%s+', ''):gsub('%s+$', '')
end

local QBCoreClient = nil

local function qbConfig()
  return (Config and Config.QBCore) or {}
end

local function qbEnabled()
  return qbConfig().Enabled == true
end

local function loadQBCoreClient()
  if not qbEnabled() then return nil end
  if QBCoreClient then return QBCoreClient end
  local resource = qbConfig().CoreResource or 'qb-core'
  if GetResourceState(resource) ~= 'started' then return nil end
  local ok, core = pcall(function()
    return exports[resource]:GetCoreObject()
  end)
  if ok and core then QBCoreClient = core end
  return QBCoreClient
end

local function qbNotify(message, msgType, length)
  local core = loadQBCoreClient()
  if core and core.Functions and core.Functions.Notify then
    core.Functions.Notify(message, msgType or 'primary', length or 5000)
  else
    notify(message)
  end
end

local function getCurrentOrClosestPlateForQB()
  local currentPed = PlayerPedId()
  local vehicle = GetVehiclePedIsIn(currentPed, false)
  if vehicle == 0 or not DoesEntityExist(vehicle) then
    local coords = GetEntityCoords(currentPed)
    vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 7.5, 0, 70)
  end
  if vehicle == 0 or not DoesEntityExist(vehicle) then return nil, 0 end
  local plate = trimString(GetVehicleNumberPlateText(vehicle))
  if plate == '' then return nil, vehicle end
  return plate, vehicle
end

local function giveQBCoreVehicleKeys(plate)
  if not qbEnabled() then return false end
  local keys = qbConfig().Keys or {}
  plate = trimString(plate)
  if plate == '' then return false end
  if keys.ClientSetOwnerEvent and keys.ClientSetOwnerEvent ~= '' then
    TriggerEvent(keys.ClientSetOwnerEvent, plate)
  end
  if keys.UseServerAcquireEvent and keys.ServerAcquireEvent and keys.ServerAcquireEvent ~= '' then
    TriggerServerEvent(keys.ServerAcquireEvent, plate)
  end
  return true
end

local function applyQBCoreSpawnedVehicle(vehicle, plate, cost)
  if not qbEnabled() or vehicle == 0 or not DoesEntityExist(vehicle) then return end
  plate = trimString(plate)
  if plate == '' then plate = trimString(GetVehicleNumberPlateText(vehicle)) end
  SetVehicleHasBeenOwnedByPlayer(vehicle, true)
  SetVehicleNeedsToBeHotwired(vehicle, false)
  SetVehicleIsStolen(vehicle, false)
  SetVehicleDoorsLocked(vehicle, 1)
  SetVehicleDoorsLockedForAllPlayers(vehicle, false)
  if plate ~= '' then
    SetVehicleNumberPlateText(vehicle, plate)
    giveQBCoreVehicleKeys(plate)
  end
  if GetPedInVehicleSeat(vehicle, -1) == PlayerPedId() then
    SetVehicleEngineOn(vehicle, true, true, false)
  end
  cost = tonumber(cost) or 0
  if cost > 0 then
    qbNotify(('AMenu vehicle spawned. Keys assigned. Charged $%s.'):format(cost), 'success')
  elseif plate ~= '' then
    qbNotify('AMenu vehicle spawned. Keys assigned.', 'success')
  end
end

RegisterNetEvent('amenu_ui:qbPlayerAction', function(action)
  action = tostring(action or ''):lower()
  local currentPed = PlayerPedId()
  if action == 'heal' then
    local maxHealth = GetEntityMaxHealth(currentPed)
    SetEntityHealth(currentPed, maxHealth)
    ClearPedBloodDamage(currentPed)
    ResetPedVisibleDamage(currentPed)
    ClearPedLastWeaponDamage(currentPed)
    qbNotify('You were healed by staff.', 'success')
  elseif action == 'revive' then
    TriggerEvent('hospital:client:Revive')
    TriggerEvent('qb-ambulancejob:client:Revive')
    TriggerEvent('qb-ambulancejob:client:revive')
    SetEntityHealth(currentPed, GetEntityMaxHealth(currentPed))
    ClearPedBloodDamage(currentPed)
    qbNotify('You were revived by staff.', 'success')
  end
end)

RegisterNetEvent('amenu_ui:qbForceServerAcquire', function(plate)
  local keys = qbConfig().Keys or {}
  if keys.UseServerAcquireEvent and keys.ServerAcquireEvent and keys.ServerAcquireEvent ~= '' then
    TriggerServerEvent(keys.ServerAcquireEvent, trimString(plate))
  end
end)

local function sanitizeUiAssetPath(raw)
  local value = trimString(raw)
  if value == '' then return true, '' end
  local lowered = value:lower()
  if lowered:match('^javascript:') or lowered:match('^data:') or lowered:match('^vbscript:') then
    return false, 'Only direct http(s) URLs or local html/ paths are allowed'
  end
  if lowered:match('^[a-z][a-z0-9+.-]*:') then
    if not lowered:match('^https?://') then
      return false, 'Only direct http(s) URLs or local html/ paths are allowed'
    end
    return true, value
  end
  return true, value
end

local function loadJsonKvp(key)
  local raw = GetResourceKvpString(key)
  if not raw or raw == '' then return {} end
  local ok, decoded = pcall(function() return json.decode(raw) end)
  if ok and type(decoded) == 'table' then return decoded end
  return {}
end

local function saveJsonKvp(key, data)
  SetResourceKvp(key, json.encode(data))
end

local function loadPersistentState()
  state.savedVehicles = loadJsonKvp('amenu_ui_saved_vehicles')
  state.savedVehicleCategories = loadJsonKvp('amenu_ui_saved_vehicle_categories')
  if type(state.savedVehicleCategories) ~= 'table' then state.savedVehicleCategories = {} end
  state.savedPeds = loadJsonKvp('amenu_ui_saved_peds')
  state.savedOutfits = loadJsonKvp('amenu_ui_saved_outfits')
  state.loadouts = loadJsonKvp('amenu_ui_loadouts')
  state.blockedPlayers = loadJsonKvp('amenu_ui_blocked_players')

  local ui = loadJsonKvp('amenu_ui_ui_settings')
  if type(ui) == 'table' then
    if state.ui.allowPositioning then
      if ui.offsetX ~= nil then state.ui.offsetX = tonumber(ui.offsetX) or state.ui.offsetX end
      if ui.offsetY ~= nil then state.ui.offsetY = tonumber(ui.offsetY) or state.ui.offsetY end
      if ui.scale ~= nil then state.ui.scale = tonumber(ui.scale) or state.ui.scale end
      if ui.rightAlign ~= nil then state.ui.rightAlign = ui.rightAlign == true end
    end
    if state.ui.allowThemeSelection then
      if ui.theme then state.ui.theme = tostring(ui.theme) end
      if ui.preset then state.ui.preset = tostring(ui.preset) end
    end
    if state.ui.allowBannerEditing then
      if ui.brandText ~= nil then state.ui.brandText = tostring(ui.brandText) end
      if ui.bannerImage ~= nil then state.ui.bannerImage = tostring(ui.bannerImage) end
      if ui.bannerLogo ~= nil then state.ui.bannerLogo = tostring(ui.bannerLogo) end
      if ui.headerHeight ~= nil then state.ui.headerHeight = math.min(180, math.max(80, tonumber(ui.headerHeight) or state.ui.headerHeight)) end
      if ui.bannerFitMode ~= nil then state.ui.bannerFitMode = tostring(ui.bannerFitMode) end
      if ui.bannerPosition ~= nil then state.ui.bannerPosition = tostring(ui.bannerPosition) end
      if ui.bannerOverlayOpacity ~= nil then state.ui.bannerOverlayOpacity = math.min(0.60, math.max(0.0, tonumber(ui.bannerOverlayOpacity) or state.ui.bannerOverlayOpacity)) end
    end
  end

  local toggleSettings = loadJsonKvp('amenu_ui_toggle_settings')
  if type(toggleSettings) == 'table' then
    for key, val in pairs(toggleSettings) do
      if state.toggles[key] ~= nil then state.toggles[key] = val == true end
    end
    if toggleSettings.voiceChannel ~= nil then state.values.voiceChannel = tonumber(toggleSettings.voiceChannel) or 0 end
    if toggleSettings.radioStation ~= nil then state.values.radioStation = tostring(toggleSettings.radioStation) end
    if toggleSettings.walkingStyle ~= nil then state.values.walkingStyle = tostring(toggleSettings.walkingStyle) end
    if toggleSettings.defaultLoadoutIndex ~= nil then state.values.defaultLoadoutIndex = tonumber(toggleSettings.defaultLoadoutIndex) or -1 end
  end

  state.toggles.rightAlign = state.ui.rightAlign
  MumbleSetVoiceChannel(state.values.voiceChannel or 0)
end

local function savePersistentState()
  saveJsonKvp('amenu_ui_saved_vehicles', state.savedVehicles)
  saveJsonKvp('amenu_ui_saved_vehicle_categories', state.savedVehicleCategories or {})
  saveJsonKvp('amenu_ui_saved_peds', state.savedPeds)
  saveJsonKvp('amenu_ui_saved_outfits', state.savedOutfits)
  saveJsonKvp('amenu_ui_loadouts', state.loadouts)
  saveJsonKvp('amenu_ui_blocked_players', state.blockedPlayers or {})
  saveJsonKvp('amenu_ui_ui_settings', {
    offsetX = state.ui.offsetX,
    offsetY = state.ui.offsetY,
    scale = state.ui.scale,
    theme = state.ui.theme,
    preset = state.ui.preset,
    rightAlign = state.ui.rightAlign,
    brandText = state.ui.brandText,
    bannerImage = state.ui.bannerImage,
    bannerLogo = state.ui.bannerLogo,
    headerHeight = state.ui.headerHeight,
    bannerFitMode = state.ui.bannerFitMode,
    bannerPosition = state.ui.bannerPosition,
    bannerOverlayOpacity = state.ui.bannerOverlayOpacity,
  })
  saveJsonKvp('amenu_ui_toggle_settings', {
    replaceOldVehicle = state.toggles.replaceOldVehicle == true,
    spawnInsideVehicle = state.toggles.spawnInsideVehicle == true,
    reserveParachute = state.toggles.reserveParachute == true,
    parachuteAutoEquip = state.toggles.parachuteAutoEquip == true,
    parachuteUnlimited = state.toggles.parachuteUnlimited == true,
    bikeSeatbelt = state.toggles.bikeSeatbelt == true,
    planeTurbulence = state.toggles.planeTurbulence == true,
    heliTurbulence = state.toggles.heliTurbulence == true,
    anchoredBoat = state.toggles.anchoredBoat == true,
    sirenOff = state.toggles.sirenOff == true,
    noBikeHelmet = state.toggles.noBikeHelmet == true,
    flashHighbeamsOnHonk = state.toggles.flashHighbeamsOnHonk == true,
    showVehicleHealth = state.toggles.showVehicleHealth == true,
    infiniteFuel = state.toggles.infiniteFuel == true,
    defaultRadio = state.toggles.defaultRadio == true,
    vehicleLightsBlackout = state.toggles.vehicleLightsBlackout == true,
    snowEffects = state.toggles.snowEffects == true,
    showTime = state.toggles.showTime == true,
    showMicStatus = state.toggles.showMicStatus == true,
    hideRadar = state.toggles.hideRadar == true,
    hideHud = state.toggles.hideHud == true,
    joinQuitNotifications = state.toggles.joinQuitNotifications == true,
    deathNotifications = state.toggles.deathNotifications == true,
    locationBlips = state.toggles.locationBlips == true,
    respawnDefaultMp = state.toggles.respawnDefaultMp == true,
    exclusiveDriver = state.toggles.exclusiveDriver == true,
    cameraLockH = state.toggles.cameraLockH == true,
    cameraLockV = state.toggles.cameraLockV == true,
    autoRepairVehicle = state.toggles.autoRepairVehicle == true,
    strongWheels = state.toggles.strongWheels == true,
    protectEngineDamage = state.toggles.protectEngineDamage == true,
    protectVisualDamage = state.toggles.protectVisualDamage == true,
    rampDamageProtection = state.toggles.rampDamageProtection == true,
    voiceChannel = state.values.voiceChannel or 0,
    radioStation = state.values.radioStation or 'OFF',
    walkingStyle = state.values.walkingStyle or 'default',
    defaultLoadoutIndex = state.values.defaultLoadoutIndex or -1,
  })
end

local function ped() return PlayerPedId() end
local function pid() return PlayerId() end

local function requestAnimDictSafe(dict, timeoutMs)
  dict = tostring(dict or '')
  if dict == '' then return false end
  if HasAnimDictLoaded(dict) then return true end
  RequestAnimDict(dict)
  local timeout = GetGameTimer() + (tonumber(timeoutMs) or 1200)
  while not HasAnimDictLoaded(dict) and GetGameTimer() < timeout do
    Wait(0)
  end
  return HasAnimDictLoaded(dict)
end

local function playCivilianHandsUp()
  local p = ped()
  local dict = 'random@mugging3'
  if requestAnimDictSafe(dict, 1400) then
    ClearPedTasks(p)
    TaskPlayAnim(p, dict, 'handsup_standing_base', 8.0, -8.0, -1, 49, 0.0, false, false, false)
    return true, 'Hands up'
  end
  return false, 'Hands up animation failed'
end

local function prettyModelName(model)
  local name = tostring(model or 'unknown')
  name = name:gsub('^%l', string.upper)
  name = name:gsub('([a-z])([A-Z])', '%1 %2')
  name = name:gsub('_', ' ')
  return name
end

local function normalizePlateText(plate)
  return tostring(plate or ''):gsub('%s+', ''):upper()
end

local function iterateMixedTable(tbl, callback)
  if type(tbl) ~= 'table' then return end
  if #tbl > 0 then
    for index, value in ipairs(tbl) do
      callback(index, value)
    end
  else
    for key, value in pairs(tbl) do
      callback(key, value)
    end
  end
end

local function ensureModel(model)
  local hash = type(model) == 'string' and GetHashKey(model) or model
  if not IsModelInCdimage(hash) then return nil, 'Invalid model' end
  RequestModel(hash)
  local timeout = GetGameTimer() + 7000
  while not HasModelLoaded(hash) and GetGameTimer() < timeout do Wait(0) end
  if not HasModelLoaded(hash) then return nil, 'Model load timeout' end
  return hash
end

local function buildPlayers()
  local out = {}
  for _, ply in ipairs(GetActivePlayers()) do
    table.insert(out, { id = GetPlayerServerId(ply), name = GetPlayerName(ply) })
  end
  table.sort(out, function(a, b) return a.id < b.id end)
  return out
end

local function buildAddonVehicleCategories(entries)
  local grouped = {}
  local order = {}
  for _, entry in ipairs(entries or {}) do
    local model = type(entry.model) == 'string' and entry.model or nil
    if model and model ~= '' then
      local hash = GetHashKey(model)
      local fallbackCategory = 'Other Addons'
      if IsModelInCdimage(hash) and IsModelAVehicle(hash) then
        local classId = GetVehicleClassFromName(hash)
        fallbackCategory = vehicleClassNames[classId] or fallbackCategory
      end
      local category = tostring(entry.category or fallbackCategory)
      if not grouped[category] then
        grouped[category] = {}
        order[#order + 1] = category
      end
      table.insert(grouped[category], {
        model = model,
        label = tostring(entry.label or prettyModelName(model)),
        description = tostring(entry.description or model)
      })
    end
  end

  local categories = {}
  for _, category in ipairs(order) do
    local models = grouped[category] or {}
    table.insert(categories, {
      id = category,
      label = category,
      count = #models,
      models = models
    })
  end

  return categories
end

local function normalizeAddonVehicleEntries(rawVehicles)
  local entries = {}

  local function push(model, category, label, description)
    if type(model) ~= 'string' or model == '' then return end
    table.insert(entries, {
      model = model,
      category = category,
      label = label,
      description = description
    })
  end

  local function digest(item, inheritedCategory)
    if type(item) == 'string' then
      push(item, inheritedCategory, nil, nil)
    elseif type(item) == 'table' then
      local model = item.model or item.spawnName or item.name
      local category = item.category or item.group or inheritedCategory
      if type(model) == 'string' and model ~= '' then
        push(model, category, item.label, item.description)
      else
        local nested = item.vehicles or item.models or item.items
        if type(nested) == 'table' then
          local nestedCategory = category or item.label or item.name or item.title
          iterateMixedTable(nested, function(key, value)
            if type(key) == 'string' and type(value) == 'table' and (value.model or value.spawnName or value.name or value.vehicles or value.models or value.items) then
              digest(value, key)
            else
              digest(value, nestedCategory)
            end
          end)
        else
          iterateMixedTable(item, function(key, value)
            if type(key) == 'string' and (type(value) == 'string' or type(value) == 'table') then
              digest(value, key)
            end
          end)
        end
      end
    end
  end

  if type(rawVehicles) == 'table' then
    iterateMixedTable(rawVehicles, function(key, value)
      if type(key) == 'string' and type(value) == 'table' then
        digest(value, key)
      else
        digest(value, nil)
      end
    end)
  end

  return entries
end

local function loadAddonsCatalog()
  local path = (Config and Config.Addons and Config.Addons.file) or 'addons.json'
  local raw = LoadResourceFile(GetCurrentResourceName(), path)
  if not raw or raw == '' then return end
  local ok, decoded = pcall(function() return json.decode(raw) end)
  if not ok or type(decoded) ~= 'table' then return end

  state.addons.vehicleEntries = normalizeAddonVehicleEntries(decoded.vehicles)
  state.addons.vehicleCategories = buildAddonVehicleCategories(state.addons.vehicleEntries)
  state.addons.vehicles = {}
  for _, entry in ipairs(state.addons.vehicleEntries or {}) do
    table.insert(state.addons.vehicles, entry.model)
  end

  state.addons.peds = type(decoded.peds) == 'table' and decoded.peds or {}
  state.addons.weapons = type(decoded.weapons) == 'table' and decoded.weapons or {}
  state.addons.weapon_components = type(decoded.weapon_components) == 'table' and decoded.weapon_components or {}
  invalidateVehicleCatalog()
end

local function getVehicleFromPlayerOrNear()
  local veh = GetVehiclePedIsIn(ped(), false)
  if veh ~= 0 then return veh end
  local coords = GetEntityCoords(ped())
  return GetClosestVehicle(coords.x, coords.y, coords.z, 6.0, 0, 71)
end

local function getPersonalVehicleEntity()
  if state.personalVehicle and state.personalVehicle.handle and DoesEntityExist(state.personalVehicle.handle) then
    return state.personalVehicle.handle
  end
  if state.personalVehicle and state.personalVehicle.netId then
    local vehicle = NetToVeh(state.personalVehicle.netId)
    if vehicle ~= 0 and DoesEntityExist(vehicle) then
      if state.personalVehicle then state.personalVehicle.handle = vehicle end
      return vehicle
    end
  end
  if state.personalVehicle and state.personalVehicle.plate and GetGamePool then
    local wantedPlate = normalizePlateText(state.personalVehicle.plate)
    local wantedModel = tonumber(state.personalVehicle.modelHash) or 0
    for _, vehicle in ipairs(GetGamePool('CVehicle')) do
      if DoesEntityExist(vehicle) and normalizePlateText(GetVehicleNumberPlateText(vehicle)) == wantedPlate then
        if wantedModel == 0 or GetEntityModel(vehicle) == wantedModel then
          if state.personalVehicle then
            state.personalVehicle.handle = vehicle
            if NetworkGetEntityIsNetworked(vehicle) then
              local netId = VehToNet(vehicle)
              state.personalVehicle.netId = (netId and netId ~= 0) and netId or nil
            end
          end
          return vehicle
        end
      end
    end
  end
  return 0
end

local function getTrackedPreviousVehicle()
  local vehicle = getPersonalVehicleEntity()
  if vehicle ~= 0 and DoesEntityExist(vehicle) then return vehicle end
  return 0
end

local function setPersonalVehicle(vehicle)
  if vehicle and vehicle ~= 0 and DoesEntityExist(vehicle) then
    local modelHash = GetEntityModel(vehicle)
    local displayName = GetLabelText(GetDisplayNameFromVehicleModel(modelHash))
    if not displayName or displayName == '' or displayName == 'NULL' then
      displayName = GetDisplayNameFromVehicleModel(modelHash) or 'Vehicle'
    end
    local plate = GetVehicleNumberPlateText(vehicle)
    local netId = NetworkGetEntityIsNetworked(vehicle) and VehToNet(vehicle) or nil
    state.personalVehicle = {
      handle = vehicle,
      netId = (netId and netId ~= 0) and netId or nil,
      plate = plate,
      modelHash = modelHash,
      label = tostring(displayName or 'Vehicle') .. ' [' .. plate .. ']'
    }
  else
    state.personalVehicle = nil
  end
end

local function currentVehicleOrPersonal()
  local veh = getVehicleFromPlayerOrNear()
  if veh == 0 then veh = getPersonalVehicleEntity() end
  return veh
end

local function syncPmBlocksToServer()
  if not awaitServer then return end
  local payload = {}
  for key, enabled in pairs(state.blockedPlayers or {}) do
    if enabled == true then payload[tostring(key)] = true end
  end
  pcall(function() awaitServer('civSyncPmBlocks', { blocked = payload }) end)
end

local function isPmBlocked(serverId)
  return (state.blockedPlayers or {})[tostring(tonumber(serverId) or serverId)] == true
end

local function setPmBlocked(serverId, enabled)
  serverId = tonumber(serverId) or 0
  if serverId <= 0 then return false, 'Player not found' end
  state.blockedPlayers = state.blockedPlayers or {}
  if enabled then state.blockedPlayers[tostring(serverId)] = true else state.blockedPlayers[tostring(serverId)] = nil end
  savePersistentState()
  local result = awaitServer('civSetPmBlock', { target = serverId, blocked = enabled == true })
  return result and result.ok == true, result and result.message or (enabled and 'Player blocked' or 'Player unblocked')
end

local function hasVehicleKeysFor(vehicle)
  if vehicle == 0 or not DoesEntityExist(vehicle) then return false, 'No vehicle found' end
  local plate = normalizePlateText(GetVehicleNumberPlateText(vehicle))
  if plate == '' then return false, 'Vehicle has no plate' end
  local resources = {}
  local cfgRes = Config and Config.QBCore and Config.QBCore.VehicleKeysResource or nil
  if cfgRes and cfgRes ~= '' then table.insert(resources, cfgRes) end
  table.insert(resources, 'qb-vehiclekeys')
  table.insert(resources, 'qbx_vehiclekeys')
  table.insert(resources, 'Renewed-Vehiclekeys')
  local checked = {}
  for _, resource in ipairs(resources) do
    if resource and resource ~= '' and not checked[resource] then
      checked[resource] = true
      if GetResourceState(resource) == 'started' then
        local exportNames = { 'HasKeys', 'HasKey', 'hasKeys', 'hasKey' }
        for _, exportName in ipairs(exportNames) do
          local ok, result = pcall(function()
            if exports[resource] and exports[resource][exportName] then
              return exports[resource][exportName](plate)
            end
            return nil
          end)
          if ok and result ~= nil then
            return result == true, result == true and nil or ('You do not have keys for plate %s'):format(plate)
          end
        end
      end
    end
  end
  return false, 'No supported vehicle key export found for lock/unlock'
end

local function setCoordsSafe(x, y, z)
  if IsPedInAnyVehicle(ped(), false) then
    SetPedCoordsKeepVehicle(ped(), x + 0.0, y + 0.0, z + 0.0)
  else
    SetEntityCoordsNoOffset(ped(), x + 0.0, y + 0.0, z + 0.0, false, false, false)
  end
end

local function teleportToWaypoint()
  local waypoint = GetFirstBlipInfoId(8)
  if waypoint == 0 then return false, 'No waypoint set' end
  local coords = GetBlipCoords(waypoint)
  local found, groundZ = false, 0.0
  for height = 1, 1000, 25 do
    RequestCollisionAtCoord(coords.x, coords.y, height + 0.0)
    found, groundZ = GetGroundZFor_3dCoord(coords.x + 0.0, coords.y + 0.0, height + 0.0, 0)
    if found then break end
    Wait(0)
  end
  if not found then groundZ = coords.z end
  setCoordsSafe(coords.x, coords.y, groundZ + 1.0)
  return true, 'Teleported to waypoint'
end

local function requestEntityControl(entity, timeoutMs)
  if entity == 0 or not DoesEntityExist(entity) then return false end
  if NetworkGetEntityIsNetworked(entity) then
    NetworkRequestControlOfEntity(entity)
  end
  local timeout = GetGameTimer() + (timeoutMs or 1500)
  while DoesEntityExist(entity) and not NetworkHasControlOfEntity(entity) and GetGameTimer() < timeout do
    Wait(0)
    NetworkRequestControlOfEntity(entity)
  end
  return not NetworkGetEntityIsNetworked(entity) or NetworkHasControlOfEntity(entity)
end

local function deleteTrackedVehicle(vehicle)
  if vehicle == 0 or not DoesEntityExist(vehicle) then
    setPersonalVehicle(nil)
    return true
  end

  local myPed = ped()
  if IsPedInVehicle(myPed, vehicle, false) then
    TaskLeaveVehicle(myPed, vehicle, 16)
    local leaveTimeout = GetGameTimer() + 2500
    while IsPedInVehicle(myPed, vehicle, false) and GetGameTimer() < leaveTimeout do
      Wait(0)
    end
  end

  local hasControl = requestEntityControl(vehicle, 2200)
  SetEntityAsMissionEntity(vehicle, true, true)
  SetVehicleHasBeenOwnedByPlayer(vehicle, false)
  SetVehicleOnGroundProperly(vehicle)
  DeleteVehicle(vehicle)
  if DoesEntityExist(vehicle) then
    DeleteEntity(vehicle)
  end
  if DoesEntityExist(vehicle) then
    SetEntityCoordsNoOffset(vehicle, 0.0, 0.0, -200.0, false, false, false)
    Wait(0)
    DeleteVehicle(vehicle)
    if DoesEntityExist(vehicle) then
      DeleteEntity(vehicle)
    end
  end

  local deleted = not DoesEntityExist(vehicle)
  if deleted then
    if personalBlip and DoesBlipExist(personalBlip) then
      RemoveBlip(personalBlip)
      personalBlip = nil
    end
    setPersonalVehicle(nil)
    return true
  end

  if not hasControl then
    return false
  end
  return false
end

local function spawnVehicle(model)
  local hash, err = ensureModel(model)
  if not hash then return false, err end

  local vehicleClass = GetVehicleClassFromName(hash)
  local spawnCost = 0

  if qbEnabled() and awaitServer then
    local okQb, result = pcall(function()
      return awaitServer('qbCanSpawnVehicle', {
        model = tostring(model),
        modelHash = tostring(hash),
        vehicleClass = vehicleClass
      })
    end)
    if okQb and result and result.ok == false then
      SetModelAsNoLongerNeeded(hash)
      return false, result.message or 'QBCore blocked this vehicle spawn'
    elseif okQb and result and result.ok then
      spawnCost = tonumber(result.cost) or 0
    end
  end

  local oldVehicle = getTrackedPreviousVehicle()
  if state.toggles.replaceOldVehicle and oldVehicle ~= 0 and DoesEntityExist(oldVehicle) then
    if not deleteTrackedVehicle(oldVehicle) then
      SetModelAsNoLongerNeeded(hash)
      return false, 'Failed to delete previous vehicle'
    end
  end

  local coords = GetOffsetFromEntityInWorldCoords(ped(), 0.0, 4.0, 0.0)
  local vehicle = CreateVehicle(hash, coords.x, coords.y, coords.z, GetEntityHeading(ped()), true, false)
  if vehicle == 0 or not DoesEntityExist(vehicle) then
    SetModelAsNoLongerNeeded(hash)
    return false, 'Vehicle spawn failed'
  end

  SetEntityAsMissionEntity(vehicle, true, true)
  SetVehicleHasBeenOwnedByPlayer(vehicle, true)
  SetVehicleOnGroundProperly(vehicle)
  SetVehRadioStation(vehicle, 'OFF')
  if state.toggles.spawnInsideVehicle then SetPedIntoVehicle(ped(), vehicle, -1) end
  SetVehicleEngineOn(vehicle, true, true, false)
  SetModelAsNoLongerNeeded(hash)
  setPersonalVehicle(vehicle)

  local plate = trimString(GetVehicleNumberPlateText(vehicle))
  applyQBCoreSpawnedVehicle(vehicle, plate, spawnCost)
  if qbEnabled() and awaitServer then
    local netId = VehToNet(vehicle)
    pcall(function()
      awaitServer('qbVehicleSpawned', {
        netId = netId,
        plate = plate,
        modelHash = tostring(hash),
        vehicleClass = vehicleClass,
        cost = spawnCost
      })
    end)
  end

  local costText = spawnCost > 0 and (' | charged $%s'):format(spawnCost) or ''
  return true, state.toggles.replaceOldVehicle and ('Spawned %s (previous removed)%s'):format(tostring(model), costText) or ('Spawned %s%s'):format(tostring(model), costText)
end

local function getVehicleDisplayName(modelHash, modelName)
  local displayName = GetDisplayNameFromVehicleModel(modelHash)
  local label = displayName and GetLabelText(displayName) or ''
  if label and label ~= '' and label ~= 'NULL' and label ~= 'CARNOTFOUND' then
    return label
  end
  if displayName and displayName ~= '' and displayName ~= 'CARNOTFOUND' then
    return displayName
  end
  return prettyModelName(modelName)
end

buildVehicleCatalog = function()
  local raw = GetAllVehicleModels()
  local grouped = {}
  local lookup = {}
  local seen = {}

  local function addVehicleName(name, forcedGroup)
    if type(name) ~= 'string' or name == '' then return end
    local hash = GetHashKey(name)
    if not IsModelInCdimage(hash) or not IsModelAVehicle(hash) then return end
    if seen[name] then return end
    seen[name] = true
    local classId = GetVehicleClassFromName(hash)
    local className = forcedGroup or vehicleClassNames[classId] or ('Class ' .. tostring(classId))
    grouped[className] = grouped[className] or {}
    local label = getVehicleDisplayName(hash, name)
    table.insert(grouped[className], { label = label, model = name })
    lookup[tostring(hash)] = name
  end

  for _, name in ipairs(raw or {}) do addVehicleName(name, nil) end
  for _, entry in ipairs((state.addons and state.addons.vehicleEntries) or {}) do addVehicleName(entry.model, 'Addon Vehicles') end

  local catalog = {}
  if grouped['Addon Vehicles'] and #grouped['Addon Vehicles'] > 0 then
    table.sort(grouped['Addon Vehicles'], function(a, b) if a.label == b.label then return a.model < b.model end return a.label < b.label end)
    table.insert(catalog, { id = 'Addon Vehicles', label = 'Addon Vehicles', count = #grouped['Addon Vehicles'], models = grouped['Addon Vehicles'] })
  end
  for classId = 0, 22 do
    local className = vehicleClassNames[classId]
    local models = grouped[className] or {}
    table.sort(models, function(a, b)
      if a.label == b.label then return a.model < b.model end
      return a.label < b.label
    end)
    if #models > 0 then
      table.insert(catalog, { id = className, label = className, count = #models, models = models })
    end
  end
  state.vehicleCatalog = catalog
  state.vehicleModelLookup = lookup
  vehicleCatalogDirty = false
  vehicleCatalogBuilt = true
end

local function base64Encode(data)
  return ((data:gsub('.', function(x)
    local r, byte = '', x:byte()
    for i = 8, 1, -1 do
      r = r .. ((byte % 2^i - byte % 2^(i - 1) > 0) and '1' or '0')
    end
    return r
  end) .. '0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
    if #x < 6 then return '' end
    local c = 0
    for i = 1, 6 do
      if x:sub(i, i) == '1' then c = c + 2^(6 - i) end
    end
    return b64chars:sub(c + 1, c + 1)
  end) .. ({ '', '==', '=' })[#data % 3 + 1])
end

local function base64Decode(data)
  data = string.gsub(data, '[^' .. b64chars .. '=]', '')
  return (data:gsub('.', function(x)
    if x == '=' then return '' end
    local r, f = '', (b64chars:find(x, 1, true) or 1) - 1
    for i = 6, 1, -1 do
      r = r .. ((f % 2^i - f % 2^(i - 1) > 0) and '1' or '0')
    end
    return r
  end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
    if #x ~= 8 then return '' end
    local c = 0
    for i = 1, 8 do
      if x:sub(i, i) == '1' then c = c + 2^(8 - i) end
    end
    return string.char(c)
  end))
end

local function encodeShareCode(tbl)
  return 'AZV1:' .. base64Encode(json.encode(tbl))
end

local function decodeShareCode(code)
  if type(code) ~= 'string' or code == '' then return nil, 'No code provided' end
  code = code:gsub('%s+', '')
  code = code:gsub('^AZV1:', '')
  local ok, decoded = pcall(function() return json.decode(base64Decode(code)) end)
  if not ok or type(decoded) ~= 'table' then return nil, 'Invalid share code' end
  return decoded
end

local function captureVehicleData(veh)
  if veh == 0 then return nil end
  ensureVehicleCatalog()
  SetVehicleModKit(veh, 0)
  local modelHash = GetEntityModel(veh)
  local modelName = state.vehicleModelLookup[tostring(modelHash)] or nil
  local primary, secondary = GetVehicleColours(veh)
  local pearl, wheelColor = GetVehicleExtraColours(veh)
  local neonR, neonG, neonB = GetVehicleNeonLightsColour(veh)
  local smokeR, smokeG, smokeB = GetVehicleTyreSmokeColor(veh)
  local data = {
    version = 1,
    kind = 'vehicle',
    modelHash = modelHash,
    model = modelName,
    vehicleClass = vehicleClassNames[GetVehicleClassFromName(modelHash)] or ('Class ' .. tostring(GetVehicleClassFromName(modelHash))),
    category = 'Uncategorized',
    label = getVehicleDisplayName(modelHash, modelName),
    plate = GetVehicleNumberPlateText(veh),
    plateIndex = GetVehicleNumberPlateTextIndex(veh),
    primaryColor = primary,
    secondaryColor = secondary,
    pearlescentColor = pearl,
    wheelColor = wheelColor,
    wheelType = GetVehicleWheelType(veh),
    windowTint = GetVehicleWindowTint(veh),
    livery = GetVehicleLivery(veh),
    engineHealth = GetVehicleEngineHealth(veh),
    bodyHealth = GetVehicleBodyHealth(veh),
    neonEnabled = {},
    neonColor = { neonR, neonG, neonB },
    tyreSmoke = { smokeR, smokeG, smokeB },
    toggles = {
      turbo = IsToggleModOn(veh, 18),
      tireSmoke = IsToggleModOn(veh, 20),
      xenon = IsToggleModOn(veh, 22),
    },
    mods = {},
    extras = {},
  }

  if GetVehicleXenonLightsColor then
    local ok, val = pcall(GetVehicleXenonLightsColor, veh)
    if ok then data.xenonColor = val end
  end

  for i = 0, 3 do
    data.neonEnabled[i + 1] = IsVehicleNeonLightEnabled(veh, i)
  end

  for i = 0, 20 do
    if DoesExtraExist(veh, i) then
      data.extras[tostring(i)] = IsVehicleExtraTurnedOn(veh, i)
    end
  end

  for i = 0, 49 do
    local count = GetNumVehicleMods(veh, i)
    if count and count > 0 then
      data.mods[tostring(i)] = {
        index = GetVehicleMod(veh, i),
        custom = GetVehicleModVariation(veh, i)
      }
    end
  end

  return data
end

local function applyVehicleData(data, existingVeh)
  if type(data) ~= 'table' then return false, 'Invalid vehicle data' end
  ensureVehicleCatalog()
  local veh = existingVeh or 0
  local model = data.model or data.modelHash
  if veh == 0 or not DoesEntityExist(veh) then
    if state.toggles.replaceOldVehicle then
      local oldVehicle = getTrackedPreviousVehicle()
      if oldVehicle ~= 0 and DoesEntityExist(oldVehicle) then
        if not deleteTrackedVehicle(oldVehicle) then
          return false, 'Failed to delete previous vehicle'
        end
      end
    end
    local hash, err = ensureModel(model)
    if not hash then return false, err end
    local coords = GetOffsetFromEntityInWorldCoords(ped(), 0.0, 4.0, 0.0)
    veh = CreateVehicle(hash, coords.x, coords.y, coords.z, GetEntityHeading(ped()), true, false)
    SetEntityAsMissionEntity(veh, true, true)
    SetVehicleHasBeenOwnedByPlayer(veh, true)
    SetVehicleOnGroundProperly(veh)
    if state.toggles.spawnInsideVehicle then SetPedIntoVehicle(ped(), veh, -1) end
    SetModelAsNoLongerNeeded(hash)
  end

  SetVehicleModKit(veh, 0)
  if data.primaryColor ~= nil and data.secondaryColor ~= nil then SetVehicleColours(veh, data.primaryColor, data.secondaryColor) end
  if data.pearlescentColor ~= nil and data.wheelColor ~= nil then SetVehicleExtraColours(veh, data.pearlescentColor, data.wheelColor) end
  if data.plate then SetVehicleNumberPlateText(veh, tostring(data.plate)) end
  if data.plateIndex ~= nil then SetVehicleNumberPlateTextIndex(veh, tonumber(data.plateIndex) or 0) end
  if data.wheelType ~= nil then SetVehicleWheelType(veh, tonumber(data.wheelType) or 0) end
  if data.windowTint ~= nil then SetVehicleWindowTint(veh, tonumber(data.windowTint) or 0) end
  if data.livery ~= nil and tonumber(data.livery) and tonumber(data.livery) >= -1 then SetVehicleLivery(veh, tonumber(data.livery)) end
  if data.engineHealth then SetVehicleEngineHealth(veh, tonumber(data.engineHealth) + 0.0) end
  if data.bodyHealth then SetVehicleBodyHealth(veh, tonumber(data.bodyHealth) + 0.0) end

  for extra, enabled in pairs(data.extras or {}) do
    SetVehicleExtra(veh, tonumber(extra), enabled and 0 or 1)
  end

  if data.neonColor and #data.neonColor >= 3 then
    SetVehicleNeonLightsColour(veh, tonumber(data.neonColor[1]) or 255, tonumber(data.neonColor[2]) or 255, tonumber(data.neonColor[3]) or 255)
  end
  if data.neonEnabled then
    for i = 1, 4 do
      SetVehicleNeonLightEnabled(veh, i - 1, data.neonEnabled[i] == true)
    end
  end
  if data.tyreSmoke and #data.tyreSmoke >= 3 then
    ToggleVehicleMod(veh, 20, true)
    SetVehicleTyreSmokeColor(veh, tonumber(data.tyreSmoke[1]) or 255, tonumber(data.tyreSmoke[2]) or 255, tonumber(data.tyreSmoke[3]) or 255)
  end

  if data.toggles then
    ToggleVehicleMod(veh, 18, data.toggles.turbo == true)
    ToggleVehicleMod(veh, 20, data.toggles.tireSmoke == true)
    ToggleVehicleMod(veh, 22, data.toggles.xenon == true)
  end
  if data.xenonColor ~= nil and SetVehicleXenonLightsColor then
    pcall(SetVehicleXenonLightsColor, veh, tonumber(data.xenonColor) or 0)
  end

  if type(data.legacyColors) == 'table' then
    local lc = data.legacyColors
    local cpr, cpg, cpb = tonumber(lc.customPrimaryR), tonumber(lc.customPrimaryG), tonumber(lc.customPrimaryB)
    if cpr and cpg and cpb and cpr >= 0 and cpg >= 0 and cpb >= 0 then SetVehicleCustomPrimaryColour(veh, cpr, cpg, cpb) end
    local csr, csg, csb = tonumber(lc.customSecondaryR), tonumber(lc.customSecondaryG), tonumber(lc.customSecondaryB)
    if csr and csg and csb and csr >= 0 and csg >= 0 and csb >= 0 then SetVehicleCustomSecondaryColour(veh, csr, csg, csb) end
    local chr, chg, chb = tonumber(lc.customheadlightR), tonumber(lc.customheadlightG), tonumber(lc.customheadlightB)
    if chr and chg and chb and chr >= 0 and chg >= 0 and chb >= 0 and SetVehicleXenonLightsCustomColor then
      pcall(SetVehicleXenonLightsCustomColor, veh, chr, chg, chb)
    end
  end
  if data.legacyHeadlightColor ~= nil and SetVehicleXenonLightsColor then pcall(SetVehicleXenonLightsColor, veh, tonumber(data.legacyHeadlightColor) or 0) end
  if data.legacyBulletProofTires ~= nil then SetVehicleTyresCanBurst(veh, data.legacyBulletProofTires ~= true) end
  if data.legacyEnveffScale ~= nil and SetVehicleEnveffScale then pcall(SetVehicleEnveffScale, veh, tonumber(data.legacyEnveffScale) + 0.0) end

  for modType, info in pairs(data.mods or {}) do
    local idx = tonumber(modType)
    if idx then
      SetVehicleMod(veh, idx, tonumber(info.index) or -1, info.custom == true)
    end
  end

  SetVehicleOnGroundProperly(veh)
  setPersonalVehicle(veh)
  return true, ('Applied vehicle setup: %s'):format(data.label or data.model or 'vehicle')
end

local function saveCurrentVehicle(name)
  local veh = getVehicleFromPlayerOrNear()
  if veh == 0 then return false, 'No vehicle found' end
  local data = captureVehicleData(veh)
  data.name = tostring(name or ('Vehicle ' .. tostring(#state.savedVehicles + 1)))
  table.insert(state.savedVehicles, data)
  savePersistentState()
  return true, ('Saved vehicle: %s'):format(data.name)
end

local function spawnSavedVehicle(index)
  local data = state.savedVehicles[index + 1]
  if not data then return false, 'Saved vehicle not found' end
  return applyVehicleData(data)
end

local function normalizeSavedVehicleCategory(category)
  local value = trimString(category or '')
  if value == '' then value = 'Uncategorized' end
  return value:sub(1, 64)
end

local function sameSavedVehicleCategory(a, b)
  return normalizeSavedVehicleCategory(a):lower() == normalizeSavedVehicleCategory(b):lower()
end

local function ensureSavedVehicleCategory(category)
  category = normalizeSavedVehicleCategory(category)
  state.savedVehicleCategories = state.savedVehicleCategories or {}
  for _, existing in ipairs(state.savedVehicleCategories) do
    if sameSavedVehicleCategory(existing, category) then
      return existing
    end
  end
  if category ~= 'Uncategorized' then
    table.insert(state.savedVehicleCategories, category)
    table.sort(state.savedVehicleCategories, function(a, b) return tostring(a):lower() < tostring(b):lower() end)
  end
  return category
end

local function getSavedVehicleModelHash(entry)
  if type(entry) ~= 'table' then return 0 end
  local hash = tonumber(entry.modelHash) or 0
  if hash == 0 and entry.model and tostring(entry.model) ~= '' then hash = GetHashKey(tostring(entry.model)) end
  return hash
end

local function isSavedVehicleAvailable(entry)
  local hash = getSavedVehicleModelHash(entry)
  return hash ~= 0 and IsModelInCdimage(hash) and IsModelAVehicle(hash)
end

local function getSavedVehicleClassName(entry)
  local hash = getSavedVehicleModelHash(entry)
  if hash ~= 0 and IsModelAVehicle(hash) then
    local classId = GetVehicleClassFromName(hash)
    return vehicleClassNames[classId] or ('Class ' .. tostring(classId))
  end
  if type(entry) == 'table' and entry.vehicleClass and tostring(entry.vehicleClass) ~= '' then return tostring(entry.vehicleClass) end
  return 'Unavailable'
end

local function savedVehicleSummary(index, entry)
  local category = normalizeSavedVehicleCategory((entry and (entry.category or entry.legacyCategory)) or 'Uncategorized')
  local className = getSavedVehicleClassName(entry)
  local available = isSavedVehicleAvailable(entry)
  return {
    index = index,
    name = tostring((entry and entry.name) or ('Vehicle ' .. tostring(index + 1))),
    model = tostring((entry and (entry.model or entry.label or entry.modelHash)) or 'unknown'),
    label = tostring((entry and (entry.label or entry.model or entry.name)) or 'Saved vehicle'),
    category = category,
    legacyCategory = entry and entry.legacyCategory or nil,
    vehicleClass = className,
    available = available,
    importedFrom = entry and entry.importedFrom or nil
  }
end

local function sortedGroupArray(map)
  local out = {}
  for id, group in pairs(map or {}) do
    table.sort(group.vehicles, function(a, b) return tostring(a.name):lower() < tostring(b.name):lower() end)
    group.count = #group.vehicles
    table.insert(out, group)
  end
  table.sort(out, function(a, b) return tostring(a.label):lower() < tostring(b.label):lower() end)
  return out
end

local function rebuildSavedVehicleNavigation()
  local classes = {}
  local categories = { Uncategorized = { id = 'Uncategorized', label = 'Uncategorized', count = 0, vehicles = {} } }
  local unavailable = {}
  state.savedVehicleCategories = state.savedVehicleCategories or {}

  for _, category in ipairs(state.savedVehicleCategories) do
    local normalized = normalizeSavedVehicleCategory(category)
    categories[normalized] = categories[normalized] or { id = normalized, label = normalized, count = 0, vehicles = {} }
  end

  for i, entry in ipairs(state.savedVehicles or {}) do
    if type(entry) == 'table' then
      local index = i - 1
      local category = ensureSavedVehicleCategory(entry.category or entry.legacyCategory or 'Uncategorized')
      entry.category = category
      entry.vehicleClass = entry.vehicleClass or getSavedVehicleClassName(entry)
      local summary = savedVehicleSummary(index, entry)

      categories[category] = categories[category] or { id = category, label = category, count = 0, vehicles = {} }
      table.insert(categories[category].vehicles, summary)

      if summary.available then
        local className = summary.vehicleClass or 'Unknown'
        classes[className] = classes[className] or { id = className, label = className, count = 0, vehicles = {} }
        table.insert(classes[className].vehicles, summary)
      else
        table.insert(unavailable, summary)
      end
    end
  end

  table.sort(unavailable, function(a, b) return tostring(a.name):lower() < tostring(b.name):lower() end)
  state.savedVehicleClasses = sortedGroupArray(classes)
  state.savedVehicleCategoryGroups = sortedGroupArray(categories)
  state.unavailableSavedVehicles = unavailable
end

local function asLegacyBool(value)
  if value == true then return true end
  if type(value) == 'string' then
    local lowered = value:lower()
    return lowered == 'true' or lowered == '1' or lowered == 'yes'
  end
  return tonumber(value) == 1
end

local function asLegacyNumber(value, fallback)
  local n = tonumber(value)
  if n == nil then return fallback end
  return n
end

local function legacyDictValue(tbl, key, fallback)
  if type(tbl) ~= 'table' then return fallback end
  local value = tbl[key]
  if value == nil then value = tbl[tostring(key)] end
  if value == nil then return fallback end
  return value
end

local function legacySaveNameFromKey(key)
  key = tostring(key or '')
  if key:sub(1, 4) == 'veh_' then return key:sub(5) end
  return key
end

local function hasImportedLegacyVehicle(legacyKey)
  legacyKey = tostring(legacyKey or '')
  for _, entry in ipairs(state.savedVehicles or {}) do
    if type(entry) == 'table' and tostring(entry.legacyAMenuKey or '') == legacyKey then
      return true
    end
  end
  return false
end

local function convertLegacyAMenuVehicle(legacyKey, legacy)
  if type(legacy) ~= 'table' then return nil end
  ensureVehicleCatalog()

  local colors = type(legacy.colors) == 'table' and legacy.colors or {}
  local mods = type(legacy.mods) == 'table' and legacy.mods or {}
  local extras = type(legacy.extras) == 'table' and legacy.extras or {}
  local modelHash = asLegacyNumber(legacy.model or legacy.modelHash, 0) or 0
  if modelHash == 0 then return nil end

  local modelName = state.vehicleModelLookup[tostring(modelHash)] or nil
  local saveName = legacySaveNameFromKey(legacyKey)
  local label = tostring(legacy.name or modelName or saveName or ('Vehicle ' .. tostring(modelHash)))
  if label == '' or label == 'NULL' then label = modelName or saveName or ('Vehicle ' .. tostring(modelHash)) end

  local out = {
    version = 1,
    kind = 'vehicle',
    importedFrom = 'TomGrobbe AMenu .dll KVP',
    legacyAMenuKey = tostring(legacyKey or ''),
    legacyCategory = tostring(legacy.Category or legacy.category or 'Uncategorized'),
    category = normalizeSavedVehicleCategory(legacy.Category or legacy.category or 'Uncategorized'),
    vehicleClass = modelHash ~= 0 and (vehicleClassNames[GetVehicleClassFromName(modelHash)] or ('Class ' .. tostring(GetVehicleClassFromName(modelHash)))) or 'Unavailable',
    name = saveName ~= '' and saveName or label,
    modelHash = modelHash,
    model = modelName,
    label = label,
    plate = tostring(legacy.plateText or legacy.plate or ''),
    plateIndex = asLegacyNumber(legacy.plateStyle, 0),
    primaryColor = asLegacyNumber(legacyDictValue(colors, 'primary', nil), 0),
    secondaryColor = asLegacyNumber(legacyDictValue(colors, 'secondary', nil), 0),
    pearlescentColor = asLegacyNumber(legacyDictValue(colors, 'pearlescent', nil), 0),
    wheelColor = asLegacyNumber(legacyDictValue(colors, 'wheels', nil), 0),
    wheelType = asLegacyNumber(legacy.wheelType, 0),
    windowTint = asLegacyNumber(legacy.windowTint, 0),
    livery = asLegacyNumber(legacy.livery, -1),
    neonEnabled = {
      asLegacyBool(legacy.neonLeft),
      asLegacyBool(legacy.neonRight),
      asLegacyBool(legacy.neonFront),
      asLegacyBool(legacy.neonBack),
    },
    neonColor = {
      asLegacyNumber(legacyDictValue(colors, 'neonR', nil), 255),
      asLegacyNumber(legacyDictValue(colors, 'neonG', nil), 255),
      asLegacyNumber(legacyDictValue(colors, 'neonB', nil), 255),
    },
    tyreSmoke = {
      asLegacyNumber(legacyDictValue(colors, 'tyresmokeR', nil), 255),
      asLegacyNumber(legacyDictValue(colors, 'tyresmokeG', nil), 255),
      asLegacyNumber(legacyDictValue(colors, 'tyresmokeB', nil), 255),
    },
    toggles = {
      turbo = asLegacyBool(legacy.turbo),
      tireSmoke = asLegacyBool(legacy.tyreSmoke),
      xenon = asLegacyBool(legacy.xenonHeadlights),
    },
    legacyColors = colors,
    legacyHeadlightColor = asLegacyNumber(legacy.headlightColor, nil),
    legacyBulletProofTires = legacy.bulletProofTires ~= nil and asLegacyBool(legacy.bulletProofTires) or nil,
    legacyEnveffScale = asLegacyNumber(legacy.enveffScale, nil),
    mods = {},
    extras = {},
  }

  for modType, index in pairs(mods) do
    local idx = tonumber(modType)
    if idx then
      out.mods[tostring(idx)] = {
        index = asLegacyNumber(index, -1),
        custom = asLegacyBool(legacy.customWheels) and (idx == 23 or idx == 24)
      }
    end
  end

  for extraId, enabled in pairs(extras) do
    local idx = tonumber(extraId)
    if idx then out.extras[tostring(idx)] = asLegacyBool(enabled) end
  end

  return out
end

local function importLegacyAMenuSavedVehicles(forceNotify)
  local imported, skipped, failed = 0, 0, 0
  local prefix = (Config and Config.LegacyAMenu and Config.LegacyAMenu.vehiclePrefix) or 'veh_'
  local handle = StartFindKvp(prefix)
  if handle == -1 or handle == nil then
    return true, 'No old AMenu saved vehicles were found', { imported = 0, skipped = 0, failed = 0 }
  end

  while true do
    local key = FindKvp(handle)
    if not key or key == '' or key == 'NULL' then break end

    if hasImportedLegacyVehicle(key) then
      skipped = skipped + 1
    else
      local raw = GetResourceKvpString(key)
      local ok, legacy = pcall(function() return json.decode(raw or '') end)
      local converted = ok and convertLegacyAMenuVehicle(key, legacy) or nil
      if converted then
        table.insert(state.savedVehicles, converted)
        imported = imported + 1
      else
        failed = failed + 1
      end
    end
  end
  EndFindKvp(handle)

  if imported > 0 then savePersistentState() end
  local msg = ('Legacy .dll AMenu import: %s imported, %s already imported, %s failed.'):format(imported, skipped, failed)
  return true, msg, { imported = imported, skipped = skipped, failed = failed }
end

local function saveCurrentPed(name)
  table.insert(state.savedPeds, { name = name, model = GetEntityModel(ped()) })
  savePersistentState()
  return true, ('Saved ped: %s'):format(name)
end

local function loadSavedPed(index)
  local data = state.savedPeds[index + 1]
  if not data then return false, 'Saved ped not found' end
  local hash, err = ensureModel(data.model)
  if not hash then return false, err end
  SetPlayerModel(pid(), hash)
  SetPedDefaultComponentVariation(ped())
  SetModelAsNoLongerNeeded(hash)
  return true, ('Loaded ped: %s'):format(data.name)
end

local function spawnPed(model)
  local hash, err = ensureModel(model)
  if not hash then return false, err end
  SetPlayerModel(pid(), hash)
  SetPedDefaultComponentVariation(ped())
  SetModelAsNoLongerNeeded(hash)
  return true, ('Spawned ped: %s'):format(model)
end

local function captureOutfitData(targetPed)
  targetPed = targetPed or ped()
  local data = {
    version = 1,
    kind = 'outfit',
    modelHash = GetEntityModel(targetPed),
    components = {},
    props = {}
  }
  for i = 0, 11 do
    table.insert(data.components, {
      id = i,
      drawable = GetPedDrawableVariation(targetPed, i),
      texture = GetPedTextureVariation(targetPed, i),
      palette = GetPedPaletteVariation(targetPed, i)
    })
  end
  for i = 0, 7 do
    table.insert(data.props, {
      id = i,
      drawable = GetPedPropIndex(targetPed, i),
      texture = GetPedPropTextureIndex(targetPed, i)
    })
  end
  return data
end

local function applyOutfitData(data)
  if type(data) ~= 'table' then return false, 'Invalid outfit data' end
  if data.modelHash and GetEntityModel(ped()) ~= tonumber(data.modelHash) then
    local hash, err = ensureModel(tonumber(data.modelHash))
    if not hash then return false, err end
    SetPlayerModel(pid(), hash)
    Wait(0)
    SetModelAsNoLongerNeeded(hash)
  end
  local targetPed = ped()
  SetPedDefaultComponentVariation(targetPed)
  for _, comp in ipairs(data.components or {}) do
    SetPedComponentVariation(targetPed, tonumber(comp.id) or 0, tonumber(comp.drawable) or 0, tonumber(comp.texture) or 0, tonumber(comp.palette) or 0)
  end
  for _, prop in ipairs(data.props or {}) do
    local drawable = tonumber(prop.drawable) or -1
    if drawable < 0 then
      ClearPedProp(targetPed, tonumber(prop.id) or 0)
    else
      SetPedPropIndex(targetPed, tonumber(prop.id) or 0, drawable, tonumber(prop.texture) or 0, true)
    end
  end
  return true, 'Outfit applied'
end

local function saveCurrentOutfit(name)
  local data = captureOutfitData(ped())
  data.name = tostring(name or ('Outfit ' .. tostring(#state.savedOutfits + 1)))
  table.insert(state.savedOutfits, data)
  savePersistentState()
  return true, ('Saved outfit: %s'):format(data.name)
end

local function loadSavedOutfit(index)
  local data = state.savedOutfits[index + 1]
  if not data then return false, 'Saved outfit not found' end
  return applyOutfitData(data)
end

local function saveCurrentLoadout(name)
  local weapons = {}
  for _, weapon in ipairs(weaponList) do
    local hash = GetHashKey(weapon)
    if HasPedGotWeapon(ped(), hash, false) then
      table.insert(weapons, { weapon = weapon, ammo = GetAmmoInPedWeapon(ped(), hash) })
    end
  end
  table.insert(state.loadouts, { name = name, weapons = weapons })
  savePersistentState()
  return true, ('Saved loadout: %s'):format(name)
end

local function equipLoadout(index)
  local loadout = state.loadouts[index + 1]
  if not loadout then return false, 'Loadout not found' end
  RemoveAllPedWeapons(ped(), true)
  for _, entry in ipairs(loadout.weapons) do
    GiveWeaponToPed(ped(), GetHashKey(entry.weapon), entry.ammo or 9999, false, false)
  end
  return true, ('Equipped loadout: %s'):format(loadout.name)
end

local function deepCopy(value)
  local ok, encoded = pcall(function() return json.encode(value) end)
  if not ok then return nil end
  local ok2, decoded = pcall(function() return json.decode(encoded) end)
  if not ok2 then return nil end
  return decoded
end

local function renameSaved(listRef, index, name, noun)
  local entry = listRef[(tonumber(index) or -1) + 1]
  if not entry then return false, (noun or 'Entry') .. ' not found' end
  entry.name = tostring(name or entry.name or noun or 'Entry')
  savePersistentState()
  return true, ('%s renamed to %s'):format(noun or 'Entry', entry.name)
end

local function cloneSaved(listRef, index, noun)
  local entry = listRef[(tonumber(index) or -1) + 1]
  if not entry then return false, (noun or 'Entry') .. ' not found' end
  local copy = deepCopy(entry)
  if not copy then return false, 'Clone failed' end
  copy.name = tostring((entry.name or noun or 'Entry') .. ' Copy')
  table.insert(listRef, copy)
  savePersistentState()
  return true, ('%s cloned'):format(noun or 'Entry')
end

local function setWalkingStyle(style)
  style = tostring(style or 'default')
  state.values.walkingStyle = style
  local p = ped()
  if style == 'default' then
    ResetPedMovementClipset(p, 0.25)
    return true, 'Walking style reset'
  end
  RequestAnimSet(style)
  local timeout = GetGameTimer() + 5000
  while not HasAnimSetLoaded(style) and GetGameTimer() < timeout do Wait(0) end
  if not HasAnimSetLoaded(style) then return false, 'Walking style not found' end
  SetPedMovementClipset(p, style, 0.25)
  RemoveAnimSet(style)
  return true, ('Walking style: %s'):format(style)
end

local function setAllAmmoCount(count)
  count = math.max(0, tonumber(count) or 0)
  for _, weapon in ipairs(weaponList) do
    local hash = GetHashKey(weapon)
    if HasPedGotWeapon(ped(), hash, false) then
      SetPedAmmo(ped(), hash, count)
    end
  end
  return true, ('All weapon ammo set to %s'):format(count)
end

local function setWeaponTint(weaponName, tintIndex)
  local hash = GetHashKey(tostring(weaponName or ''))
  if not HasPedGotWeapon(ped(), hash, false) then return false, 'You do not have that weapon' end
  SetPedWeaponTintIndex(ped(), hash, tonumber(tintIndex) or 0)
  return true, ('Tint %s applied'):format(tonumber(tintIndex) or 0)
end

local function setParachuteTint(primary, reserve)
  local playerId = pid()
  if primary ~= nil and SetPlayerParachuteTintIndex then pcall(SetPlayerParachuteTintIndex, playerId, tonumber(primary) or 0) end
  if reserve ~= nil and SetPlayerReserveParachuteTintIndex then pcall(SetPlayerReserveParachuteTintIndex, playerId, tonumber(reserve) or 0) end
  return true, 'Parachute style updated'
end

local function setParachuteSmokeTrailColor(r, g, b)
  local playerId = pid()
  if SetPlayerCanLeaveParachuteSmokeTrail then pcall(SetPlayerCanLeaveParachuteSmokeTrail, playerId, true) end
  if SetPlayerParachuteSmokeTrailColor then pcall(SetPlayerParachuteSmokeTrailColor, playerId, clampRgb(r), clampRgb(g), clampRgb(b)) end
  return true, ('Parachute smoke set to RGB %s, %s, %s'):format(clampRgb(r), clampRgb(g), clampRgb(b))
end

local function setPlateType(index)
  local veh = currentVehicleOrPersonal(); if veh == 0 then return false, 'No vehicle found' end
  SetVehicleNumberPlateTextIndex(veh, tonumber(index) or 0)
  return true, ('Plate style set to %s'):format(tonumber(index) or 0)
end

local function openAllVehicleDoors()
  local veh = currentVehicleOrPersonal(); if veh == 0 then return false, 'No vehicle found' end
  for i = 0, 7 do SetVehicleDoorOpen(veh, i, false, false) end
  return true, 'All doors opened'
end

local function closeAllVehicleDoors()
  local veh = currentVehicleOrPersonal(); if veh == 0 then return false, 'No vehicle found' end
  for i = 0, 7 do SetVehicleDoorShut(veh, i, false) end
  return true, 'All doors closed'
end

local function breakVehicleDoor(index)
  local veh = currentVehicleOrPersonal(); if veh == 0 then return false, 'No vehicle found' end
  SetVehicleDoorBroken(veh, tonumber(index) or 0, true)
  return true, ('Door %s removed'):format(tonumber(index) or 0)
end

local function fixVehicleDoors()
  local veh = currentVehicleOrPersonal(); if veh == 0 then return false, 'No vehicle found' end
  SetVehicleFixed(veh)
  return true, 'Removed doors restored with repair'
end

local function cycleVehicleSeat()
  local p = ped()
  local veh = GetVehiclePedIsIn(p, false)
  if veh == 0 then return false, 'You are not in a vehicle' end
  local currentSeat = -2
  for seat = -1, GetVehicleMaxNumberOfPassengers(veh) - 1 do
    if GetPedInVehicleSeat(veh, seat) == p then currentSeat = seat break end
  end
  for offset = 1, GetVehicleMaxNumberOfPassengers(veh) + 1 do
    local seat = -1 + (((currentSeat + 1 + offset) % (GetVehicleMaxNumberOfPassengers(veh) + 1)))
    if IsVehicleSeatFree(veh, seat) then
      SetPedIntoVehicle(p, veh, seat)
      return true, ('Moved to seat %s'):format(seat)
    end
  end
  return false, 'No free seat found'
end

local function setVehicleStance(height)
  local veh = currentVehicleOrPersonal(); if veh == 0 then return false, 'No vehicle found' end
  if SetVehicleSuspensionHeight then
    pcall(SetVehicleSuspensionHeight, veh, tonumber(height) + 0.0)
    return true, ('Vehicle stance set to %.2f'):format(tonumber(height) + 0.0)
  end
  return false, 'Vehicle stance native unavailable'
end

local function renameOrCloneOutfit(index, name, clone)
  local entry = state.savedOutfits[(tonumber(index) or -1) + 1]
  if not entry then return false, 'Saved character not found' end
  if clone then
    local copy = deepCopy(entry)
    copy.name = tostring(name or ((entry.name or 'Character') .. ' Copy'))
    table.insert(state.savedOutfits, copy)
    savePersistentState()
    return true, 'Character cloned'
  end
  entry.name = tostring(name or entry.name or 'Character')
  savePersistentState()
  return true, 'Character renamed'
end

local function buildVehicleStyleInfo(veh)
  local info = {
    primaryColor = 0,
    secondaryColor = 0,
    pearlescentColor = 0,
    wheelColor = 0,
    wheelType = 0,
    windowTint = 0,
    plateType = 0,
    dirtLevel = 0.0,
    dashboardColor = 0,
    interiorColor = 0,
    primaryCustomEnabled = false,
    secondaryCustomEnabled = false,
    primaryCustomColor = { 255, 255, 255 },
    secondaryCustomColor = { 255, 255, 255 },
    frontWheelsCustom = false,
    rearWheelsCustom = false,
    bulletproofTires = false,
    lowGrip = false,
    livery = -1,
    liveryCount = 0,
    modLiveryCount = 0,
    modLiveryIndex = -1,
    xenonColor = 255,
    neonColor = { 255, 255, 255 },
    neonEnabled = { false, false, false, false },
    tyreSmoke = { 255, 255, 255 },
    toggles = { turbo = false, tireSmoke = false, xenon = false },
    mods = {},
  }
  if veh ~= 0 and DoesEntityExist(veh) then
    SetVehicleModKit(veh, 0)
    local p, s = GetVehicleColours(veh)
    local pearl, wheel = GetVehicleExtraColours(veh)
    local neonR, neonG, neonB = GetVehicleNeonLightsColour(veh)
    local smokeR, smokeG, smokeB = GetVehicleTyreSmokeColor(veh)
    info.primaryColor = p or 0
    info.secondaryColor = s or 0
    info.pearlescentColor = pearl or 0
    info.wheelColor = wheel or 0
    info.wheelType = GetVehicleWheelType(veh) or 0
    info.windowTint = GetVehicleWindowTint(veh) or 0
    info.plateType = GetVehicleNumberPlateTextIndex(veh) or 0
    info.dirtLevel = GetVehicleDirtLevel(veh) or 0.0
    do
      local okDash, dash = pcall(GetVehicleDashboardColour, veh)
      if okDash and dash ~= nil then info.dashboardColor = dash or 0 end
      local okInt, interior = pcall(GetVehicleInteriorColour, veh)
      if okInt and interior ~= nil then info.interiorColor = interior or 0 end
      local okCanBurst, canBurst = pcall(GetVehicleTyresCanBurst, veh)
      if okCanBurst then info.bulletproofTires = not canBurst end
      local okLowGrip, lowGripEnabled = pcall(GetDriftTyresEnabled, veh)
      if okLowGrip then info.lowGrip = lowGripEnabled == true end
      local okFrontCustom, frontCustom = pcall(GetVehicleModVariation, veh, 23)
      if okFrontCustom then info.frontWheelsCustom = frontCustom == true end
      local okRearCustom, rearCustom = pcall(GetVehicleModVariation, veh, 24)
      if okRearCustom then info.rearWheelsCustom = rearCustom == true end
      local okPrimaryCustom, primaryCustom = pcall(GetIsVehiclePrimaryColourCustom, veh)
      if okPrimaryCustom and primaryCustom then
        local okPrimaryRgb, pr, pg, pb = pcall(GetVehicleCustomPrimaryColour, veh)
        if okPrimaryRgb then
          info.primaryCustomEnabled = true
          info.primaryCustomColor = { pr or 255, pg or 255, pb or 255 }
        end
      end
      local okSecondaryCustom, secondaryCustom = pcall(GetIsVehicleSecondaryColourCustom, veh)
      if okSecondaryCustom and secondaryCustom then
        local okSecondaryRgb, sr, sg, sb = pcall(GetVehicleCustomSecondaryColour, veh)
        if okSecondaryRgb then
          info.secondaryCustomEnabled = true
          info.secondaryCustomColor = { sr or 255, sg or 255, sb or 255 }
        end
      end
    end
    info.livery = GetVehicleLivery(veh) or -1
    info.liveryCount = GetVehicleLiveryCount(veh) or 0
    info.modLiveryCount = GetNumVehicleMods(veh, 48) or 0
    info.modLiveryIndex = GetVehicleMod(veh, 48) or -1
    info.toggles.turbo = IsToggleModOn(veh, 18)
    info.toggles.tireSmoke = IsToggleModOn(veh, 20)
    info.toggles.xenon = IsToggleModOn(veh, 22)
    info.neonColor = { neonR or 255, neonG or 255, neonB or 255 }
    info.tyreSmoke = { smokeR or 255, smokeG or 255, smokeB or 255 }
    for i = 0, 3 do
      info.neonEnabled[i + 1] = IsVehicleNeonLightEnabled(veh, i)
    end
    if GetVehicleXenonLightsColor then
      local ok, val = pcall(GetVehicleXenonLightsColor, veh)
      if ok then info.xenonColor = val end
    end
    for _, modType in ipairs({ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46 }) do
      local count = GetNumVehicleMods(veh, modType) or 0
      if count > 0 then
        table.insert(info.mods, { type = modType, count = count, current = GetVehicleMod(veh, modType) or -1 })
      end
    end
  end
  return info
end

local function buildVehicleInfo()
  local info = { extras = {}, mods = {}, toggles = {} }
  local veh = getVehicleFromPlayerOrNear()
  if veh ~= 0 and DoesEntityExist(veh) then
    local style = buildVehicleStyleInfo(veh)
    for k, v in pairs(style) do info[k] = v end
    for i = 0, 20 do
      if DoesExtraExist(veh, i) then
        table.insert(info.extras, { id = i, enabled = IsVehicleExtraTurnedOn(veh, i) })
      end
    end
  end
  return info
end

local function captureRestoreState()
  if not state.restore.appearance then state.restore.appearance = GetEntityModel(ped()) end
  if not state.restore.weapons then
    local list = {}
    for _, weapon in ipairs(weaponList) do
      local hash = GetHashKey(weapon)
      if HasPedGotWeapon(ped(), hash, false) then
        table.insert(list, { weapon = weapon, ammo = GetAmmoInPedWeapon(ped(), hash) })
      end
    end
    state.restore.weapons = list
  end
end

awaitServer = function(action, payload)
  reqId = reqId + 1
  local p = promise.new()
  pending[reqId] = p
  TriggerServerEvent('amenu_ui:serverAction', reqId, action, payload or {})
  return Citizen.Await(p)
end

RegisterNetEvent('amenu_ui:serverResponse', function(id, response)
  if pending[id] then pending[id]:resolve(response); pending[id] = nil end
end)
RegisterNetEvent('amenu_ui:teleportToCoords', function(coords) setCoordsSafe(coords.x, coords.y, coords.z) end)
RegisterNetEvent('amenu_ui:killMe', function() SetEntityHealth(ped(), 0) end)
RegisterNetEvent('amenu_ui:privateMessage', function(fromName, msg, fromId)
  if state.toggles.disablePrivateMessages then return end
  if fromId and isPmBlocked(fromId) then return end
  notify(('PM from %s: %s'):format(fromName, msg))
end)

RegisterNetEvent('amenu_ui:gpsRequest', function(requester, requesterName, expiresAt)
  requester = tonumber(requester) or 0
  if requester <= 0 then return end
  state.pendingGpsRequests = state.pendingGpsRequests or {}
  state.pendingGpsRequests[tostring(requester)] = { requester = requester, name = requesterName or ('ID ' .. requester), expiresAt = expiresAt or 0 }
  notify(('%s requested your GPS location. Open AMenu > Civilian Player Menu > GPS Requests to accept or deny.'):format(requesterName or ('ID ' .. requester)))
end)

RegisterNetEvent('amenu_ui:gpsRequestClosed', function(requester)
  requester = tostring(tonumber(requester) or requester or '')
  if state.pendingGpsRequests then state.pendingGpsRequests[requester] = nil end
end)

RegisterNetEvent('amenu_ui:gpsAccepted', function(targetName, coords)
  if type(coords) ~= 'table' or not coords.x or not coords.y then return end
  SetNewWaypoint(coords.x + 0.0, coords.y + 0.0)
  notify(('GPS waypoint set to %s.'):format(targetName or 'player'))
end)
RegisterNetEvent('amenu_ui:playerEvent', function(kind, playerName)
  if not state.toggles.joinQuitNotifications then return end
  if kind == 'joined' then notify(('%s joined the server'):format(playerName or 'A player')) end
  if kind == 'left' then notify(('%s left the server'):format(playerName or 'A player')) end
end)

local function requestKeyboardInput(title, defaultText, maxLength)
  local entryKey = 'VMENU_UI_PROMPT'
  AddTextEntry(entryKey, tostring(title or 'Enter value'))
  DisplayOnscreenKeyboard(1, entryKey, '', tostring(defaultText or ''), '', '', '', tonumber(maxLength) or 128)

  while true do
    local status = UpdateOnscreenKeyboard()
    if status == 1 then
      return GetOnscreenKeyboardResult()
    elseif status == 2 or status == 3 then
      return nil
    end
    Wait(0)
  end
end

local function requestPromptFields(title, fields)
  local values = {}
  for _, field in ipairs(fields or {}) do
    local label = tostring((field and (field.label or field.name)) or 'Value')
    local defaultValue = field and field.value or ''
    local maxLength = field and field.maxLength or 128
    local result = requestKeyboardInput(('%s - %s'):format(tostring(title or 'Input'), label), defaultValue, maxLength)
    if result == nil then
      return nil
    end
    values[tostring(field.name or 'value')] = result
  end
  return values
end

local function previewWorldState(world)
  if type(world) ~= 'table' then return end
  currentWorld.hour = tonumber(world.hour or currentWorld.hour) or currentWorld.hour
  currentWorld.minute = tonumber(world.minute or currentWorld.minute) or currentWorld.minute
  currentWorld.freezeTime = world.freezeTime == true
  currentWorld.weather = tostring(world.weather or currentWorld.weather or 'CLEAR')
  currentWorld.dynamicWeather = world.dynamicWeather == true
  currentWorld.blackout = world.blackout == true
  currentWorld.clouds = tostring(world.clouds or currentWorld.clouds or 'default')

  state.values.timeHour = currentWorld.hour
  state.values.timeMinute = currentWorld.minute
  state.toggles.freezeTime = currentWorld.freezeTime
  state.toggles.dynamicWeather = currentWorld.dynamicWeather
  state.toggles.blackout = currentWorld.blackout
end

local function applyWorldState(world)
  if not worldSyncEnabled() or type(world) ~= 'table' then return end
  currentWorld.hour = tonumber(world.hour or currentWorld.hour) or currentWorld.hour
  currentWorld.minute = tonumber(world.minute or currentWorld.minute) or currentWorld.minute
  currentWorld.freezeTime = world.freezeTime == true
  currentWorld.weather = tostring(world.weather or currentWorld.weather or 'CLEAR')
  currentWorld.dynamicWeather = world.dynamicWeather == true
  currentWorld.blackout = world.blackout == true
  currentWorld.clouds = tostring(world.clouds or currentWorld.clouds or 'default')

  state.values.timeHour = currentWorld.hour
  state.values.timeMinute = currentWorld.minute
  state.toggles.freezeTime = currentWorld.freezeTime
  state.toggles.dynamicWeather = currentWorld.dynamicWeather
  state.toggles.blackout = currentWorld.blackout

  NetworkOverrideClockTime(currentWorld.hour, currentWorld.minute, 0)
  ClearOverrideWeather()
  ClearWeatherTypePersist()
  SetWeatherTypePersist(currentWorld.weather)
  SetWeatherTypeNowPersist(currentWorld.weather)
  SetArtificialLightsState(currentWorld.blackout)
  if currentWorld.clouds == 'clear' then
    ClearCloudHat()
  elseif currentWorld.clouds and currentWorld.clouds ~= '' and currentWorld.clouds ~= 'default' then
    SetCloudHat(currentWorld.clouds, 0.3)
  end
end

RegisterNetEvent('amenu_ui:syncWorld', function(world)
  applyWorldState(world)
end)

local function sanitizeRegisteredCommandName(value)
  value = tostring(value or ''):gsub('^/', '')
  value = value:match('^%s*(.-)%s*$') or ''
  if value == '' or value:find('[\r\n]') then return '' end
  return value
end

local function buildClientRegisteredCommands()
  local out = {}
  if type(GetRegisteredCommands) ~= 'function' then return out end
  local ok, commands = pcall(GetRegisteredCommands)
  if not ok or type(commands) ~= 'table' then return out end
  local seen = {}
  for _, cmd in ipairs(commands) do
    if type(cmd) == 'table' then
      local name = sanitizeRegisteredCommandName(cmd.name or cmd.command or cmd[1])
      if name ~= '' then
        local resource = tostring(cmd.resource or cmd.resourceName or cmd.resource_name or cmd[2] or 'client')
        if resource == '' or resource == 'nil' then resource = 'client' end
        local key = ('client:%s:%s'):format(resource, name)
        if not seen[key] then
          seen[key] = true
          out[#out + 1] = {
            name = name,
            command = name,
            label = '/' .. name,
            resource = resource,
            source = 'client',
            restricted = cmd.restricted == true or cmd.permission == true,
            description = ('Auto-detected registered client command from %s.'):format(resource),
          }
        end
      end
    end
  end
  return out
end

local function mergeRegisteredCommands(serverCommands, clientCommands)
  local out, seen = {}, {}
  local function addList(list)
    if type(list) ~= 'table' then return end
    for _, cmd in ipairs(list) do
      if type(cmd) == 'table' then
        local name = sanitizeRegisteredCommandName(cmd.name or cmd.command or cmd.label)
        if name ~= '' then
          local source = tostring(cmd.source or 'unknown')
          local resource = tostring(cmd.resource or source)
          if resource == '' or resource == 'nil' then resource = source end
          local key = ('%s:%s:%s'):format(source, resource, name)
          if not seen[key] then
            seen[key] = true
            out[#out + 1] = {
              name = name,
              command = name,
              label = cmd.label or ('/' .. name),
              resource = resource,
              source = source,
              restricted = cmd.restricted == true,
              description = cmd.description or ('Auto-detected command from ' .. resource),
            }
          end
        end
      end
    end
  end
  addList(serverCommands)
  addList(clientCommands)
  table.sort(out, function(a, b)
    local ar, br = tostring(a.resource or ''), tostring(b.resource or '')
    if ar == br then return tostring(a.name or '') < tostring(b.name or '') end
    return ar < br
  end)
  return out
end

local function buildState(fetchBans)
  captureRestoreState()
  ensureVehicleCatalog()
  state.players = buildPlayers()
  state.myServerId = GetPlayerServerId(PlayerId())
  state.vehicle = buildVehicleInfo()
  local now = GetCloudTimeAsInt and GetCloudTimeAsInt() or 0
  local gpsArray = {}
  for key, req in pairs(state.pendingGpsRequests or {}) do
    if type(req) == 'table' and (tonumber(req.expiresAt or 0) == 0 or tonumber(req.expiresAt or 0) > now) then
      table.insert(gpsArray, req)
    else
      state.pendingGpsRequests[key] = nil
    end
  end
  table.sort(gpsArray, function(a, b) return (a.requester or 0) < (b.requester or 0) end)
  state.gpsRequests = gpsArray
  state.ui.rightAlign = state.toggles.rightAlign == true
  state.ui.allowThemeSelection = not (Config and Config.UI and Config.UI.allowUserThemeSelection == false)
  state.ui.allowPositioning = not (Config and Config.UI and Config.UI.allowUserPositioning == false)
  state.ui.allowBannerEditing = not (Config and Config.UI and Config.UI.allowUserBannerEditing == false)
  state.ui.headerHeight = tonumber((Config and Config.UI and Config.UI.headerHeight) or state.ui.headerHeight or 112) or 112
  state.ui.bannerFitMode = tostring((Config and Config.UI and Config.UI.bannerFitMode) or state.ui.bannerFitMode or 'contain')
  state.ui.bannerPosition = tostring((Config and Config.UI and Config.UI.bannerPosition) or state.ui.bannerPosition or 'center center')
  state.ui.bannerOverlayOpacity = tonumber((Config and Config.UI and Config.UI.bannerOverlayOpacity) or state.ui.bannerOverlayOpacity or 0.04) or 0.04
  state.ui.presets = (Config and Config.UI and Config.UI.presets) or {}
  state.ui.menuBanners = (Config and Config.UI and Config.UI.menuBanners) or {}
  state.ui.bannerCycle = (Config and Config.UI and Config.UI.bannerCycle) or {}
  state.config = {
    worldSyncEnabled = worldSyncEnabled(),
    worldControlsEnabled = worldControlsEnabled(),
  }
  if worldSyncEnabled() and ((Config and Config.World and Config.World.syncOnOpen) == true) then
    local okWorld, worldResult = pcall(function() return awaitServer('getWorldState', {}) end)
    if okWorld and worldResult and worldResult.ok and worldResult.world then previewWorldState(worldResult.world) end
  end
  if fetchBans then
    local ok, result = pcall(function() return awaitServer('getBans', {}) end)
    if ok and result and result.ok then state.bans = result.bans or {} end
  end
  local okPermissions, permissionsResult = pcall(function() return awaitServer('getPermissionsState', {}) end)
  if okPermissions and permissionsResult and permissionsResult.ok then
    state.permissions = permissionsResult.permissions or { canEdit = false, principals = {}, aces = {}, commonGroups = {} }
  else
    state.permissions = { canEdit = false, principals = {}, aces = {}, commonGroups = {} }
  end
  local okQb, qbResult = pcall(function() return awaitServer('getQbState', {}) end)
  if okQb and qbResult and qbResult.ok then
    state.qb = qbResult.qb or { enabled = false, coreStarted = false, canAccessMenu = false, players = {} }
  else
    state.qb = { enabled = qbEnabled(), coreStarted = false, canAccessMenu = false, players = {} }
  end
  local clientCommands = buildClientRegisteredCommands()
  local serverCommands = {}
  local okCommands, commandsResult = pcall(function() return awaitServer('getRegisteredCommands', {}) end)
  if okCommands and commandsResult and commandsResult.ok then
    serverCommands = commandsResult.commands or {}
  end
  state.registeredCommands = mergeRegisteredCommands(serverCommands, clientCommands)

  rebuildSavedVehicleNavigation()
  return state
end

local function setUi(stateOpen)
  uiOpen = stateOpen == true
  SetNuiFocus(uiOpen, false)
  SetNuiFocusKeepInput(uiOpen)
  SendNUIMessage({ action = uiOpen and 'open' or 'close' })
end

local uiBlockedControls = {

  12, 13,
  14, 15,
  16, 17,
  37,
  81, 82,
  83, 84,
  85,

  24, 25,
  68, 69, 70,
  91, 92,
  257
}

local function disableUiGameControls()
  for _, control in ipairs(uiBlockedControls) do
    DisableControlAction(0, control, true)
    DisableControlAction(1, control, true)
    DisableControlAction(2, control, true)
  end
end

local function uiControlJustPressed(control)
  return IsDisabledControlJustPressed(0, control)
      or IsDisabledControlJustPressed(1, control)
      or IsDisabledControlJustPressed(2, control)
end

local function toggleVehicleDoor(index)
  local veh = currentVehicleOrPersonal(); if veh == 0 then return false, 'No vehicle found' end
  if GetVehicleDoorAngleRatio(veh, index) > 0.1 then SetVehicleDoorShut(veh, index, false) else SetVehicleDoorOpen(veh, index, false, false) end
  return true, ('Toggled door %s'):format(index)
end

local rolledDown = {}
local function toggleVehicleWindow(index)
  local veh = currentVehicleOrPersonal(); if veh == 0 then return false, 'No vehicle found' end
  local key = tostring(VehToNet(veh)) .. ':' .. tostring(index)
  if rolledDown[key] then RollUpWindow(veh, index); rolledDown[key] = nil else RollDownWindow(veh, index); rolledDown[key] = true end
  return true, ('Toggled window %s'):format(index)
end

local function toggleVehicleExtra(index)
  local veh = currentVehicleOrPersonal(); if veh == 0 then return false, 'No vehicle found' end
  if not DoesExtraExist(veh, index) then return false, 'Extra does not exist' end
  local enabled = IsVehicleExtraTurnedOn(veh, index)
  SetVehicleExtra(veh, index, enabled and 1 or 0)
  return true, ('Toggled extra %s'):format(index)
end

local function clampColorId(value)
  return math.max(0, math.min(160, tonumber(value) or 0))
end

local function clampRgb(value)
  return math.max(0, math.min(255, tonumber(value) or 0))
end

local function setVehiclePaint(primary, secondary, pearlescent, wheel)
  local veh = currentVehicleOrPersonal(); if veh == 0 then return false, 'No vehicle found' end
  local currentPrimary, currentSecondary = GetVehicleColours(veh)
  local currentPearl, currentWheel = GetVehicleExtraColours(veh)
  SetVehicleModKit(veh, 0)
  SetVehicleColours(veh, primary ~= nil and clampColorId(primary) or currentPrimary, secondary ~= nil and clampColorId(secondary) or currentSecondary)
  SetVehicleExtraColours(veh, pearlescent ~= nil and clampColorId(pearlescent) or currentPearl, wheel ~= nil and clampColorId(wheel) or currentWheel)
  return true, 'Vehicle paint updated'
end

local function setVehicleDashboardColorValue(color)
  local veh = currentVehicleOrPersonal(); if veh == 0 then return false, 'No vehicle found' end
  local colorId = clampColorId(color)
  local ok = pcall(SetVehicleDashboardColour, veh, colorId)
  return ok, ok and ('Dashboard color set to %s'):format(colorId) or 'Dashboard color native unavailable'
end

local function setVehicleInteriorColorValue(color)
  local veh = currentVehicleOrPersonal(); if veh == 0 then return false, 'No vehicle found' end
  local colorId = clampColorId(color)
  local ok = pcall(SetVehicleInteriorColour, veh, colorId)
  return ok, ok and ('Interior color set to %s'):format(colorId) or 'Interior color native unavailable'
end

local function setVehicleCustomPrimaryColorValue(r, g, b)
  local veh = currentVehicleOrPersonal(); if veh == 0 then return false, 'No vehicle found' end
  pcall(SetVehicleCustomPrimaryColour, veh, clampRgb(r), clampRgb(g), clampRgb(b))
  return true, ('Custom primary RGB set to %s, %s, %s'):format(clampRgb(r), clampRgb(g), clampRgb(b))
end

local function setVehicleCustomSecondaryColorValue(r, g, b)
  local veh = currentVehicleOrPersonal(); if veh == 0 then return false, 'No vehicle found' end
  pcall(SetVehicleCustomSecondaryColour, veh, clampRgb(r), clampRgb(g), clampRgb(b))
  return true, ('Custom secondary RGB set to %s, %s, %s'):format(clampRgb(r), clampRgb(g), clampRgb(b))
end

local function clearVehicleCustomPrimaryColorValue()
  local veh = currentVehicleOrPersonal(); if veh == 0 then return false, 'No vehicle found' end
  pcall(ClearVehicleCustomPrimaryColour, veh)
  return true, 'Custom primary RGB cleared'
end

local function clearVehicleCustomSecondaryColorValue()
  local veh = currentVehicleOrPersonal(); if veh == 0 then return false, 'No vehicle found' end
  pcall(ClearVehicleCustomSecondaryColour, veh)
  return true, 'Custom secondary RGB cleared'
end

local function toggleVehicleBulletproofTiresValue()
  local veh = currentVehicleOrPersonal(); if veh == 0 then return false, 'No vehicle found' end
  local canBurst = true
  local okBurst, burst = pcall(GetVehicleTyresCanBurst, veh)
  if okBurst then canBurst = burst == true end
  SetVehicleTyresCanBurst(veh, not canBurst)
  return true, (canBurst and 'Bullet proof tires enabled' or 'Bullet proof tires disabled')
end

local function toggleVehicleLowGripValue()
  local veh = currentVehicleOrPersonal(); if veh == 0 then return false, 'No vehicle found' end
  local enabled = false
  local okState, stateVal = pcall(GetDriftTyresEnabled, veh)
  if okState then enabled = stateVal == true end
  local okSet = pcall(SetDriftTyresEnabled, veh, not enabled)
  return okSet, okSet and ((not enabled) and 'Low grip tires enabled' or 'Low grip tires disabled') or 'Low grip tires native unavailable'
end

local function toggleVehicleWheelVariationValue(modType)
  local veh = currentVehicleOrPersonal(); if veh == 0 then return false, 'No vehicle found' end
  local mod = tonumber(modType)
  if mod ~= 23 and mod ~= 24 then return false, 'Only wheel mod slots support custom tires' end
  local current = GetVehicleMod(veh, mod)
  if current == nil or current < 0 then return false, 'Install a wheel option first' end
  local currentVariation = false
  local okVariation, variation = pcall(GetVehicleModVariation, veh, mod)
  if okVariation then currentVariation = variation == true end
  SetVehicleModKit(veh, 0)
  SetVehicleMod(veh, mod, current, not currentVariation)
  return true, ((mod == 23) and 'Front wheels' or 'Rear wheels') .. ((not currentVariation) and ' custom tire variation enabled' or ' custom tire variation disabled')
end

local function setVehicleModValue(modType, index)
  local veh = currentVehicleOrPersonal(); if veh == 0 then return false, 'No vehicle found' end
  local mod = tonumber(modType)
  local idx = tonumber(index) or -1
  if not mod then return false, 'Invalid mod type' end
  SetVehicleModKit(veh, 0)
  local customTires = false
  if mod == 23 or mod == 24 then
    local okVariation, variation = pcall(GetVehicleModVariation, veh, mod)
    if okVariation then customTires = variation == true end
  end
  SetVehicleMod(veh, mod, idx, customTires)
  return true, ('Vehicle mod %s set to %s'):format(mod, idx)
end

local function toggleVehicleModType(modType)
  local veh = currentVehicleOrPersonal(); if veh == 0 then return false, 'No vehicle found' end
  local mod = tonumber(modType)
  if not mod then return false, 'Invalid mod type' end
  SetVehicleModKit(veh, 0)

  local supportedToggleMods = {
    [18] = 'Turbo',
    [20] = 'Tire Smoke',
    [22] = 'Xenon Headlights'
  }
  local label = supportedToggleMods[mod] or ('Vehicle mod ' .. tostring(mod))

  if mod ~= 18 and mod ~= 20 and mod ~= 22 then
    return false, ('%s is not a supported toggle mod'):format(label)
  end

  local enabled = IsToggleModOn(veh, mod)
  local ok, err = pcall(function()
    ToggleVehicleMod(veh, mod, not enabled)
  end)
  if not ok then
    return false, ('Failed to toggle %s'):format(label)
  end

  return true, ('%s %s'):format(label, enabled and 'disabled' or 'enabled')
end

local function setVehicleWindowTintValue(tint)
  local veh = currentVehicleOrPersonal(); if veh == 0 then return false, 'No vehicle found' end
  SetVehicleWindowTint(veh, tonumber(tint) or 0)
  return true, ('Window tint set to %s'):format(tonumber(tint) or 0)
end

local function setVehicleWheelTypeValue(wheelType)
  local veh = currentVehicleOrPersonal(); if veh == 0 then return false, 'No vehicle found' end
  SetVehicleWheelType(veh, tonumber(wheelType) or 0)
  return true, ('Wheel type set to %s'):format(tonumber(wheelType) or 0)
end

local function setVehicleXenonColorValue(color)
  local veh = currentVehicleOrPersonal(); if veh == 0 then return false, 'No vehicle found' end
  SetVehicleModKit(veh, 0)
  ToggleVehicleMod(veh, 22, true)
  if SetVehicleXenonLightsColor then
    pcall(SetVehicleXenonLightsColor, veh, tonumber(color) or 255)
  end
  return true, ('Xenon color set to %s'):format(tonumber(color) or 255)
end

local function setVehicleTyreSmokeColorValue(r, g, b)
  local veh = currentVehicleOrPersonal(); if veh == 0 then return false, 'No vehicle found' end
  SetVehicleModKit(veh, 0)
  ToggleVehicleMod(veh, 20, true)
  SetVehicleTyreSmokeColor(veh, clampRgb(r), clampRgb(g), clampRgb(b))
  return true, ('Tire smoke color set to RGB %s, %s, %s'):format(clampRgb(r), clampRgb(g), clampRgb(b))
end

local function toggleVehicleNeonPosition(index)
  local veh = currentVehicleOrPersonal(); if veh == 0 then return false, 'No vehicle found' end
  local idx = tonumber(index) or 0
  local enabled = IsVehicleNeonLightEnabled(veh, idx)
  SetVehicleNeonLightEnabled(veh, idx, not enabled)
  return true, ('Neon position %s %s'):format(idx, enabled and 'disabled' or 'enabled')
end

local function toggleAllVehicleNeons()
  local veh = currentVehicleOrPersonal(); if veh == 0 then return false, 'No vehicle found' end
  local anyEnabled = false
  for i = 0, 3 do
    if IsVehicleNeonLightEnabled(veh, i) then anyEnabled = true break end
  end
  for i = 0, 3 do
    SetVehicleNeonLightEnabled(veh, i, not anyEnabled)
  end
  return true, anyEnabled and 'All neons disabled' or 'All neons enabled'
end

local function setVehicleNeonColorValue(r, g, b)
  local veh = currentVehicleOrPersonal(); if veh == 0 then return false, 'No vehicle found' end
  SetVehicleNeonLightsColour(veh, clampRgb(r), clampRgb(g), clampRgb(b))
  return true, ('Neon color set to RGB %s, %s, %s'):format(clampRgb(r), clampRgb(g), clampRgb(b))
end

local function setVoiceRange(index)
  local idx = (tonumber(index) or 0) + 1
  if idx < 1 or idx > #voiceRanges then idx = 1 end
  state.values.voiceRangeIndex = idx - 1
  MumbleSetTalkerProximity(voiceRanges[idx])
  return true, ('Voice range: %s m'):format(voiceRanges[idx])
end

local function serverModeration(action, payload)
  local result = awaitServer(action, payload)
  return result and result.ok, result and result.message or 'Server action failed'
end

local function playerByServerId(serverId)
  local player = GetPlayerFromServerId(serverId)
  if player == -1 then return nil end
  return player
end

local function parseVectorText(text)
  if type(text) ~= 'string' then return nil end
  text = text:gsub('[Vv][Ee][Cc][Tt][Oo][Rr]%d?%s*%(', ''):gsub('%)', '')
  local nums = {}
  for num in text:gmatch('[-]?%d+%.?%d*') do
    nums[#nums + 1] = tonumber(num)
  end
  if #nums >= 3 then
    return { x = nums[1], y = nums[2], z = nums[3], h = nums[4] }
  end
  return nil
end

local function currentCoordsStrings()
  local p = ped()
  local c = GetEntityCoords(p)
  local h = GetEntityHeading(p)
  return ('vector3(%.3f, %.3f, %.3f)'):format(c.x, c.y, c.z), ('vector4(%.3f, %.3f, %.3f, %.3f)'):format(c.x, c.y, c.z, h)
end

local noclipSpeeds = { 0.35, 0.8, 1.6, 3.0, 5.5, 9.0, 14.0, 22.0 }

local function getNoclipTarget()
  local playerPed = ped()
  if IsPedInAnyVehicle(playerPed, false) then
    local veh = GetVehiclePedIsIn(playerPed, false)
    if veh ~= 0 and GetPedInVehicleSeat(veh, -1) == playerPed then
      return veh, true
    end
  end
  return playerPed, false
end

local function restoreNoclipEntity(entity, isVehicle)
  if entity == 0 or not DoesEntityExist(entity) then return end
  SetEntityCollision(entity, true, true)
  SetEntityVelocity(entity, 0.0, 0.0, 0.0)
  ResetEntityAlpha(entity)
  if isVehicle then
    SetEntityVisible(entity, not state.toggles.vehicleInvisible, false)
    FreezeEntityPosition(entity, state.toggles.vehicleFreeze == true)
    SetEntityInvincible(entity, state.toggles.vehicleGod == true)
  else
    SetEntityVisible(entity, not state.toggles.invisible, false)
    if not state.toggles.freezePlayer then FreezeEntityPosition(entity, false) else FreezeEntityPosition(entity, true) end
    SetEntityInvincible(entity, state.toggles.god == true)
    SetPlayerInvincible(pid(), state.toggles.god == true)
    SetEntityCanBeDamaged(entity, state.toggles.god ~= true)
  end
  SetLocalPlayerVisibleLocally(true)
end

local function deactivateNoclip()
  if noclipState.entity ~= 0 then
    restoreNoclipEntity(noclipState.entity, noclipState.isVehicle)
  else
    restoreNoclipEntity(ped(), false)
  end
  noclipState.entity = 0
  noclipState.isVehicle = false
  state.toggles.noclip = false
end

local function setNoclipState(enabled)
  local now = GetGameTimer()
  if (now - (noclipState.lastToggle or 0)) < 180 then
    return false, 'NoClip toggle is cooling down'
  end
  noclipState.lastToggle = now
  if enabled then
    if IsPedInAnyVehicle(ped(), false) then
      local veh = GetVehiclePedIsIn(ped(), false)
      if veh ~= 0 and GetPedInVehicleSeat(veh, -1) ~= ped() then
        return false, 'You must be the driver to use vehicle noclip'
      end
    end
    local entity, isVehicle = getNoclipTarget()
    noclipState.entity = entity
    noclipState.isVehicle = isVehicle
    state.toggles.noclip = true
    return true, isVehicle and 'Vehicle noclip enabled' or 'NoClip enabled'
  end
  deactivateNoclip()
  return true, 'NoClip disabled'
end

local function handleToggle(key)
  if state.toggles[key] == nil then return false, 'Unknown toggle' end
  if key == 'noclip' then
    local ok, msg = setNoclipState(not state.toggles.noclip)
    savePersistentState()
    return ok, msg
  end
  if key == 'rightAlign' and state.ui.allowPositioning == false then
    state.toggles.rightAlign = state.ui.rightAlign
    return false, 'Menu positioning is locked by server config'
  end
  state.toggles[key] = not state.toggles[key]
  if key == 'rightAlign' then
    state.ui.rightAlign = state.toggles.rightAlign
  end
  if key == 'showSpeedKmh' and state.toggles.showSpeedKmh then state.toggles.showSpeedMph = false end
  if key == 'showSpeedMph' and state.toggles.showSpeedMph then state.toggles.showSpeedKmh = false end
  if key == 'voiceEnabled' then NetworkSetVoiceActive(state.toggles.voiceEnabled) end
  if key == 'staffChannel' then MumbleSetVoiceChannel(state.toggles.staffChannel and 99 or 0) end
  if key == 'nightVision' then SetNightvision(state.toggles.nightVision) end
  if key == 'thermalVision' then SetSeethrough(state.toggles.thermalVision) end
  if key == 'freezePlayer' then FreezeEntityPosition(ped(), state.toggles.freezePlayer) end
  if key == 'reserveParachute' and SetPlayerHasReserveParachute then pcall(SetPlayerHasReserveParachute, pid(), state.toggles.reserveParachute) end
  if key == 'showCurrentSpeaker' and state.toggles.showCurrentSpeaker then state.toggles.showMicStatus = false end
  if key == 'showMicStatus' and state.toggles.showMicStatus then state.toggles.showCurrentSpeaker = false end
  savePersistentState()
  return true, key .. (state.toggles[key] and ' enabled' or ' disabled')
end

local function resolveQbManagementTarget(target)
  target = tonumber(target) or 0
  if target > 0 then return target end

  local players = state.snapshot and state.snapshot.qb and state.snapshot.qb.players or {}
  if type(players) == 'table' and #players == 1 then
    local only = tonumber(players[1].source or players[1].id) or 0
    if only > 0 then return only end
  end

  return 0
end

local function runQbManagementAction(actionName, target, args)
  if not awaitServer then return false, 'Server bridge is not ready', nil end

  actionName = tostring(actionName or ''):gsub('^%s+', ''):gsub('%s+$', ''):lower()
  local resolvedTarget = resolveQbManagementTarget(target)
  args = type(args) == 'table' and args or (args ~= nil and { args } or {})

  local valuePayload = {}
  if actionName == 'setjob' then
    valuePayload = { job = tostring(args[1] or 'unemployed'), grade = tonumber(args[2] or 0) or 0 }
  elseif actionName == 'addmoney' or actionName == 'removemoney' then
    valuePayload = { account = tostring(args[1] or 'cash'), amount = tonumber(args[2] or 0) or 0 }
  elseif actionName == 'keys' then
    valuePayload = { plate = tostring(args[1] or '') }
  elseif actionName == 'duty' then
    valuePayload = { duty = tostring(args[1] or 'true') }
  elseif actionName == 'kick' then
    valuePayload = { reason = tostring(args[1] or 'Kicked by staff.') }
  end

  local result = awaitServer('azRunPlayerAction', {
    action = actionName,
    target = resolvedTarget,
    targetId = resolvedTarget,
    args = args,
    value = valuePayload,
    context = { source = resolvedTarget, target = resolvedTarget, targetId = resolvedTarget }
  })

  local extra = nil
  if result and result.displayText then
    extra = { title = result.title or 'Azure Framework Details', displayText = result.displayText, copyText = result.displayText }
  end
  return result and result.ok == true, result and result.message or 'Azure Framework action failed', extra
end

local function commandTrim(value)
  value = tostring(value or '')
  return value:match('^%s*(.-)%s*$') or ''
end

local function runResourceCommand(payload)
  if type(payload) ~= 'table' then return false, 'Invalid command payload', nil end
  local command = commandTrim(payload.command or payload.cmd or '')
  local args = commandTrim(payload.args or '')
  local wrapper = commandTrim(payload.serverWrapper or '')
  local extra = nil

  if command == '' then return false, 'Missing command', extra end
  if command:find('[^%w_:%-+/]') or command:find('[\r\n]') then
    return false, 'Unsafe command name blocked', extra
  end
  if args:find('[\r\n]') then
    return false, 'Unsafe command arguments blocked', extra
  end

  if wrapper ~= '' then
    local result = awaitServer('runResourceCommandWrapper', {
      command = command,
      args = args,
      wrapper = wrapper,
      resource = tostring(payload.resource or '')
    })
    if result and result.ok then return true, result.message or ('Ran /' .. command), extra end
  end

  local line = command
  if args ~= '' then line = line .. ' ' .. args end
  ExecuteCommand(line)
  return true, ('Ran /%s%s'):format(command, args ~= '' and (' ' .. args) or ''), extra
end

local function formatVec3(coords)
  return ('vector3(%.2f, %.2f, %.2f)'):format(coords.x or 0.0, coords.y or 0.0, coords.z or 0.0)
end

local function entityDebugText(kind)
  kind = tostring(kind or 'entity')
  local myPed = ped()
  local lines = {}
  local function addEntity(label, entity)
    if entity == 0 or not DoesEntityExist(entity) then
      table.insert(lines, label .. ': none')
      return
    end
    local model = GetEntityModel(entity)
    local coords = GetEntityCoords(entity)
    local minDim, maxDim = GetModelDimensions(model)
    local netText = 'local entity'
    if NetworkGetEntityIsNetworked(entity) then
      local netId = NetworkGetNetworkIdFromEntity(entity)
      local owner = NetworkGetEntityOwner and NetworkGetEntityOwner(entity) or -1
      netText = ('netId=%s owner=%s'):format(tostring(netId), tostring(owner))
    end
    table.insert(lines, ('%s: handle=%s model=%s %s coords=%s'):format(label, tostring(entity), tostring(model), netText, formatVec3(coords)))
    if minDim and maxDim then
      table.insert(lines, ('%s dimensions: min=%s max=%s'):format(label, formatVec3(minDim), formatVec3(maxDim)))
    end
  end

  if kind == 'vehicle' then
    addEntity('Vehicle', getVehicleFromPlayerOrNear())
  elseif kind == 'object' then
    local c = GetEntityCoords(myPed)
    local obj = GetClosestObjectOfType(c.x, c.y, c.z, 8.0, 0, false, false, false)
    addEntity('Object', obj)
  elseif kind == 'ped' then
    addEntity('Ped', myPed)
  elseif kind == 'models' then
    addEntity('Ped', myPed)
    addEntity('Vehicle', getVehicleFromPlayerOrNear())
  elseif kind == 'owners' then
    addEntity('Vehicle', getVehicleFromPlayerOrNear())
  else
    addEntity('Ped', myPed)
    addEntity('Vehicle', getVehicleFromPlayerOrNear())
  end

  local _, v4 = currentCoordsStrings()
  table.insert(lines, 'Current coords: ' .. v4)
  return table.concat(lines, '\n')
end

local function handleAction(action, value, context)
  local myPed = ped()
  local extra = nil

  if action == 'runResourceCommand' then
    local payload = {}
    if type(context) == 'table' then for k, v in pairs(context) do payload[k] = v end end
    if type(value) == 'table' then
      for k, v in pairs(value) do payload[k] = v end
    elseif value ~= nil then
      payload.command = value
    end
    return runResourceCommand(payload)
  elseif action == 'civPrivateMessage' then
    local target = tonumber((context or {}).playerId) or 0
    if isPmBlocked(target) then return false, 'Unblock this player before messaging them', extra end
    local result = awaitServer('civPrivateMessage', {
      target = target,
      message = tostring((value or {}).message or '')
    })
    return result and result.ok, result and result.message or 'Private message failed', extra
  elseif action == 'civGiveMoney' then
    local result = awaitServer('civGiveMoney', {
      target = tonumber((context or {}).playerId),
      account = tostring((value or {}).account or 'cash'),
      amount = tonumber((value or {}).amount or 0) or 0
    })
    return result and result.ok, result and result.message or 'Money transfer failed', extra
  elseif action == 'civTogglePmBlock' then
    local target = tonumber(value) or tonumber((context or {}).playerId) or 0
    local blocked = not isPmBlocked(target)
    return setPmBlocked(target, blocked)
  elseif action == 'civRequestGPS' then
    local target = tonumber(value) or tonumber((context or {}).playerId) or 0
    local result = awaitServer('civRequestGPS', { target = target })
    return result and result.ok, result and result.message or 'GPS request failed', extra
  elseif action == 'civRespondGPS' then
    local payload = type(value) == 'table' and value or {}
    local requester = tonumber(payload.requester) or 0
    local accepted = payload.accepted == true
    local result = awaitServer('civRespondGPS', { requester = requester, accepted = accepted })
    if state.pendingGpsRequests then state.pendingGpsRequests[tostring(requester)] = nil end
    return result and result.ok, result and result.message or 'GPS response failed', extra
  elseif action == 'civHandsUp' then
    return playCivilianHandsUp()
  elseif action == 'civRagdoll' then
    SetPedToRagdoll(myPed, 2500, 2500, 0, false, false, false)
    return true, 'Ragdoll toggled', extra
  elseif action == 'qbRefreshPlayers' then
    return true, 'Framework player list refreshed', extra
  elseif action == 'qbGiveSelfKeys' then
    local plate = getCurrentOrClosestPlateForQB()
    if not plate then return false, 'No current or nearby vehicle plate found', extra end
    return runQbManagementAction('keys', GetPlayerServerId(PlayerId()), { plate })
  elseif action == 'qbInfo' then
    return runQbManagementAction('info', (context or {}).source, {})
  elseif action == 'qbRevive' then
    return runQbManagementAction('revive', (context or {}).source, {})
  elseif action == 'qbHeal' then
    return runQbManagementAction('heal', (context or {}).source, {})
  elseif action == 'qbSave' then
    return runQbManagementAction('save', (context or {}).source, {})
  elseif action == 'qbDutyOn' then
    return runQbManagementAction('duty', (context or {}).source, { 'true' })
  elseif action == 'qbDutyOff' then
    return runQbManagementAction('duty', (context or {}).source, { 'false' })
  elseif action == 'qbSetJobPreset' then
    local payload = type(value) == 'table' and value or {}
    return runQbManagementAction('setjob', (context or {}).source, { payload.job or 'unemployed', tostring(payload.grade or 0) })
  elseif action == 'qbSetCustomJob' then
    return runQbManagementAction('setjob', (context or {}).source, { tostring((value or {}).job or 'unemployed'), tostring((value or {}).grade or 0) })
  elseif action == 'qbAddMoney' then
    return runQbManagementAction('addmoney', (context or {}).source, { tostring((value or {}).account or 'cash'), tostring((value or {}).amount or 0) })
  elseif action == 'qbRemoveMoney' then
    return runQbManagementAction('removemoney', (context or {}).source, { tostring((value or {}).account or 'cash'), tostring((value or {}).amount or 0) })
  elseif action == 'qbGivePlateKeys' then
    return runQbManagementAction('keys', (context or {}).source, { tostring((value or {}).plate or '') })
  elseif action == 'qbGiveCurrentKeys' then
    local plate = getCurrentOrClosestPlateForQB()
    if not plate then return false, 'No current or nearby vehicle plate found', extra end
    return runQbManagementAction('keys', (context or {}).source, { plate })
  elseif action == 'qbKick' then
    return runQbManagementAction('kick', (context or {}).source, { tostring((value or {}).reason or 'Kicked by staff.') })
  elseif action == 'heal' then SetEntityHealth(myPed, GetEntityMaxHealth(myPed)); return true, 'Healed', extra
  elseif action == 'maxArmor' then SetPedArmour(myPed, 100); return true, 'Armor set to 100', extra
  elseif action == 'cleanPlayer' then ClearPedBloodDamage(myPed); ClearPedEnvDirt(myPed); ResetPedVisibleDamage(myPed); ClearPedDecorations(myPed); return true, 'Player cleaned', extra
  elseif action == 'dryPlayer' then ClearPedWetness(myPed); return true, 'Player dried', extra
  elseif action == 'wetPlayer' then ClearPedWetness(myPed); SetPedWetnessHeight(myPed, 3.0); return true, 'Player wet', extra
  elseif action == 'setWantedLevel' then
    local level = tonumber((value or {}).level or 0) or 0
    if level <= 0 then ClearPlayerWantedLevel(pid()) else SetPlayerWantedLevel(pid(), level, false); SetPlayerWantedLevelNow(pid(), false) end
    return true, ('Wanted level: %s'):format(level), extra
  elseif action == 'driveToWaypoint' then
    local veh = GetVehiclePedIsIn(myPed, false)
    local blip = GetFirstBlipInfoId(8)
    if veh == 0 or GetPedInVehicleSeat(veh, -1) ~= myPed or blip == 0 then return false, 'Be the driver and set a waypoint first' end
    local c = GetBlipCoords(blip)
    TaskVehicleDriveToCoordLongrange(myPed, veh, c.x, c.y, c.z, 35.0, state.values.drivingStyle or 786603, 10.0)
    return true, 'Driving to waypoint', extra
  elseif action == 'driveRandom' then
    local veh = GetVehiclePedIsIn(myPed, false)
    if veh == 0 or GetPedInVehicleSeat(veh, -1) ~= myPed then return false, 'Be the driver first' end
    TaskVehicleDriveWander(myPed, veh, 30.0, state.values.drivingStyle or 786603)
    return true, 'Driving randomly', extra
  elseif action == 'stopDriving' then ClearPedTasks(myPed); return true, 'Driving task stopped', extra
  elseif action == 'setDrivingStyle' then state.values.drivingStyle = tonumber(type(value) == 'table' and (value.style or value.value) or value) or 786603; return true, ('Driving style: %s'):format(state.values.drivingStyle), extra
  elseif action == 'spawnPed' then return spawnPed((value or {}).model)
  elseif action == 'spawnPedQuick' then return spawnPed(value)
  elseif action == 'savePed' then return saveCurrentPed((value or {}).name or 'Ped')
  elseif action == 'loadPed' then return loadSavedPed(tonumber(value) or 0)
  elseif action == 'deletePed' then table.remove(state.savedPeds, (tonumber(value) or 0) + 1); savePersistentState(); return true, 'Saved ped removed', extra
  elseif action == 'saveOutfit' then return saveCurrentOutfit((value or {}).name or 'Outfit')
  elseif action == 'loadOutfit' then return loadSavedOutfit(tonumber(value) or 0)
  elseif action == 'deleteOutfit' then table.remove(state.savedOutfits, (tonumber(value) or 0) + 1); savePersistentState(); return true, 'Saved outfit removed', extra
  elseif action == 'exportOutfitCode' then
    local code = encodeShareCode(captureOutfitData(myPed))
    extra = { title = 'Outfit Share Code', displayText = code, copyText = code }
    return true, 'Outfit share code ready', extra
  elseif action == 'importOutfitCode' then
    local decoded, err = decodeShareCode((value or {}).code or '')
    if not decoded then return false, err end
    return applyOutfitData(decoded)
  elseif action == 'giveWeapon' then local name = type(value) == 'table' and value.weapon or value; GiveWeaponToPed(myPed, GetHashKey(tostring(name)), 9999, false, true); return true, ('Given %s'):format(tostring(name)), extra
  elseif action == 'giveAllWeapons' then for _, weapon in ipairs(weaponList) do GiveWeaponToPed(myPed, GetHashKey(weapon), 9999, false, false) end; return true, 'All weapons granted', extra
  elseif action == 'removeAllWeapons' then RemoveAllPedWeapons(myPed, true); return true, 'All weapons removed', extra
  elseif action == 'refillAmmo' then local current = GetSelectedPedWeapon(myPed); SetPedAmmo(myPed, current, 9999); return true, 'Ammo refilled', extra
  elseif action == 'saveLoadout' then return saveCurrentLoadout((value or {}).name or 'Loadout')
  elseif action == 'equipLoadout' then return equipLoadout(tonumber(value) or 0)
  elseif action == 'deleteLoadout' then table.remove(state.loadouts, (tonumber(value) or 0) + 1); savePersistentState(); return true, 'Loadout removed', extra
  elseif action == 'repairVehicle' then local veh = currentVehicleOrPersonal(); if veh == 0 then return false, 'No vehicle found' end; SetVehicleFixed(veh); SetVehicleDeformationFixed(veh); SetVehicleDirtLevel(veh, 0.0); return true, 'Vehicle repaired', extra
  elseif action == 'washVehicle' then local veh = currentVehicleOrPersonal(); if veh == 0 then return false, 'No vehicle found' end; SetVehicleDirtLevel(veh, 0.0); return true, 'Vehicle washed', extra
  elseif action == 'flipVehicle' then local veh = currentVehicleOrPersonal(); if veh == 0 then return false, 'No vehicle found' end; local c = GetEntityCoords(veh); SetEntityCoords(veh, c.x, c.y, c.z + 1.0, false, false, false, false); SetVehicleOnGroundProperly(veh); return true, 'Vehicle flipped', extra
  elseif action == 'toggleEngine' then local veh = currentVehicleOrPersonal(); if veh == 0 then return false, 'No vehicle found' end; local on = GetIsVehicleEngineRunning(veh); SetVehicleEngineOn(veh, not on, false, true); return true, on and 'Engine off' or 'Engine on', extra
  elseif action == 'lockVehicle' then local veh = currentVehicleOrPersonal(); if veh == 0 then return false, 'No vehicle found' end; local hasKeys, keyErr = hasVehicleKeysFor(veh); if not hasKeys then return false, keyErr or 'You do not have keys for this vehicle', extra end; local locked = GetVehicleDoorLockStatus(veh) == 2; SetVehicleDoorsLocked(veh, locked and 1 or 2); SetVehicleDoorsLockedForAllPlayers(veh, not locked); return true, locked and 'Vehicle unlocked' or 'Vehicle locked', extra
  elseif action == 'alarmVehicle' then local veh = currentVehicleOrPersonal(); if veh == 0 then return false, 'No vehicle found' end; SetVehicleAlarm(veh, true); StartVehicleAlarm(veh); return true, 'Alarm started', extra
  elseif action == 'deleteVehicle' then local veh = currentVehicleOrPersonal(); if veh == 0 then return false, 'No vehicle found' end; local deleted = deleteTrackedVehicle(veh); return deleted, deleted and 'Vehicle deleted' or 'Failed to delete vehicle', extra
  elseif action == 'speedLimiter' then state.values.speedLimitMph = tonumber((value or {}).speed or 0) or 0; return true, ('Speed limiter: %s MPH'):format(state.values.speedLimitMph), extra
  elseif action == 'setPlate' then local veh = currentVehicleOrPersonal(); if veh == 0 then return false, 'No vehicle found' end; SetVehicleNumberPlateText(veh, tostring((value or {}).plate or 'VMENU')); return true, 'Plate updated', extra
  elseif action == 'honkVehicle' then
    local veh = currentVehicleOrPersonal(); if veh == 0 then return false, 'No vehicle found', extra end
    StartVehicleHorn(veh, 900, GetHashKey('NORMAL'), false)
    return true, 'Horn sounded', extra
  elseif action == 'switchVehicleSeat' then
    local veh = GetVehiclePedIsIn(myPed, false); if veh == 0 then return false, 'You are not in a vehicle', extra end
    local seat = tonumber(value) or -1
    if not IsVehicleSeatFree(veh, seat) and GetPedInVehicleSeat(veh, seat) ~= myPed then return false, 'That seat is occupied', extra end
    SetPedIntoVehicle(myPed, veh, seat)
    return true, ('Moved to seat %s'):format(seat), extra
  elseif action == 'rollAllWindowsDown' then
    local veh = currentVehicleOrPersonal(); if veh == 0 then return false, 'No vehicle found', extra end
    for i = 0, 7 do RollDownWindow(veh, i) end
    rolledDown[tostring(VehToNet(veh)) .. ':all'] = true
    return true, 'All windows rolled down', extra
  elseif action == 'rollAllWindowsUp' then
    local veh = currentVehicleOrPersonal(); if veh == 0 then return false, 'No vehicle found', extra end
    for i = 0, 7 do RollUpWindow(veh, i) end
    rolledDown[tostring(VehToNet(veh)) .. ':all'] = nil
    return true, 'All windows rolled up', extra
  elseif action == 'toggleHeadlights' then
    local veh = currentVehicleOrPersonal(); if veh == 0 then return false, 'No vehicle found', extra end
    state.toggles.civHeadlights = not state.toggles.civHeadlights
    SetVehicleLights(veh, state.toggles.civHeadlights and 2 or 0)
    if not state.toggles.civHeadlights then SetVehicleFullbeam(veh, false); state.toggles.civHighbeams = false end
    return true, state.toggles.civHeadlights and 'Headlights on' or 'Headlights off', extra
  elseif action == 'toggleHighbeams' then
    local veh = currentVehicleOrPersonal(); if veh == 0 then return false, 'No vehicle found', extra end
    state.toggles.civHighbeams = not state.toggles.civHighbeams
    SetVehicleLights(veh, 2)
    SetVehicleFullbeam(veh, state.toggles.civHighbeams)
    state.toggles.civHeadlights = true
    return true, state.toggles.civHighbeams and 'High beams on' or 'High beams off', extra
  elseif action == 'toggleLeftIndicator' then
    local veh = currentVehicleOrPersonal(); if veh == 0 then return false, 'No vehicle found', extra end
    state.toggles.civLeftIndicator = not state.toggles.civLeftIndicator
    SetVehicleIndicatorLights(veh, 1, state.toggles.civLeftIndicator)
    return true, state.toggles.civLeftIndicator and 'Left blinker on' or 'Left blinker off', extra
  elseif action == 'toggleRightIndicator' then
    local veh = currentVehicleOrPersonal(); if veh == 0 then return false, 'No vehicle found', extra end
    state.toggles.civRightIndicator = not state.toggles.civRightIndicator
    SetVehicleIndicatorLights(veh, 0, state.toggles.civRightIndicator)
    return true, state.toggles.civRightIndicator and 'Right blinker on' or 'Right blinker off', extra
  elseif action == 'toggleHazards' then
    local veh = currentVehicleOrPersonal(); if veh == 0 then return false, 'No vehicle found', extra end
    local enabled = not (state.toggles.civHazards == true)
    state.toggles.civHazards = enabled
    state.toggles.civLeftIndicator = enabled
    state.toggles.civRightIndicator = enabled
    SetVehicleIndicatorLights(veh, 0, enabled)
    SetVehicleIndicatorLights(veh, 1, enabled)
    return true, enabled and 'Hazards on' or 'Hazards off', extra
  elseif action == 'toggleInteriorLight' then
    local veh = currentVehicleOrPersonal(); if veh == 0 then return false, 'No vehicle found', extra end
    state.toggles.civInteriorLight = not state.toggles.civInteriorLight
    SetVehicleInteriorlight(veh, state.toggles.civInteriorLight)
    return true, state.toggles.civInteriorLight and 'Interior light on' or 'Interior light off', extra
  elseif action == 'toggleDoor' then return toggleVehicleDoor(tonumber(value) or 0)
  elseif action == 'toggleWindow' then return toggleVehicleWindow(tonumber(value) or 0)
  elseif action == 'toggleExtra' then return toggleVehicleExtra(tonumber(value) or 0)
  elseif action == 'setVehiclePrimaryColor' then return setVehiclePaint(value, nil, nil, nil)
  elseif action == 'setVehicleSecondaryColor' then return setVehiclePaint(nil, value, nil, nil)
  elseif action == 'setVehiclePearlescentColor' then return setVehiclePaint(nil, nil, value, nil)
  elseif action == 'setVehicleWheelColor' then return setVehiclePaint(nil, nil, nil, value)
  elseif action == 'setVehicleDashboardColor' then return setVehicleDashboardColorValue(value)
  elseif action == 'setVehicleInteriorColor' then return setVehicleInteriorColorValue(value)
  elseif action == 'setVehicleCustomPrimaryColor' then return setVehicleCustomPrimaryColorValue((value or {}).r, (value or {}).g, (value or {}).b)
  elseif action == 'setVehicleCustomSecondaryColor' then return setVehicleCustomSecondaryColorValue((value or {}).r, (value or {}).g, (value or {}).b)
  elseif action == 'clearVehicleCustomPrimaryColor' then return clearVehicleCustomPrimaryColorValue()
  elseif action == 'clearVehicleCustomSecondaryColor' then return clearVehicleCustomSecondaryColorValue()
  elseif action == 'setVehicleColorsById' then return setVehiclePaint((value or {}).primaryColor, (value or {}).secondaryColor, (value or {}).pearlescentColor, (value or {}).wheelColor)
  elseif action == 'setVehicleWindowTint' then return setVehicleWindowTintValue(value)
  elseif action == 'setVehicleWheelType' then return setVehicleWheelTypeValue(value)
  elseif action == 'toggleVehicleMod' then return toggleVehicleModType(value)
  elseif action == 'setVehicleMod' then return setVehicleModValue((value or {}).modType, (value or {}).index)
  elseif action == 'setVehicleXenonColor' then return setVehicleXenonColorValue(value)
  elseif action == 'toggleBulletproofTires' then return toggleVehicleBulletproofTiresValue()
  elseif action == 'toggleLowGripTires' then return toggleVehicleLowGripValue()
  elseif action == 'toggleWheelVariation' then return toggleVehicleWheelVariationValue(value)
  elseif action == 'setTyreSmokeColor' then return setVehicleTyreSmokeColorValue((value or {}).r, (value or {}).g, (value or {}).b)
  elseif action == 'toggleNeonPosition' then return toggleVehicleNeonPosition(value)
  elseif action == 'toggleAllNeon' then return toggleAllVehicleNeons()
  elseif action == 'setNeonColor' then return setVehicleNeonColorValue((value or {}).r, (value or {}).g, (value or {}).b)
  elseif action == 'setVehicleLivery' then local veh = currentVehicleOrPersonal(); if veh == 0 then return false, 'No vehicle found' end; local idx = tonumber(value) or -1; if (GetVehicleLiveryCount(veh) or 0) > 0 then SetVehicleLivery(veh, idx) end; if (GetNumVehicleMods(veh, 48) or 0) > 0 then SetVehicleModKit(veh, 0); SetVehicleMod(veh, 48, idx, false) end; return true, ('Livery set to %s'):format(idx), extra
  elseif action == 'spawnVehicle' then return spawnVehicle((value or {}).model or value)
  elseif action == 'saveVehicle' then return saveCurrentVehicle((value or {}).name or 'Vehicle')
  elseif action == 'importLegacyAMenuVehicles' then return importLegacyAMenuSavedVehicles(true)
  elseif action == 'createSavedVehicleCategory' then
    local category = ensureSavedVehicleCategory((value or {}).name or value)
    savePersistentState()
    return true, ('Saved vehicle category ready: %s'):format(category), extra
  elseif action == 'renameSavedVehicleCategory' then
    local oldCategory = normalizeSavedVehicleCategory((context or {}).category or (value or {}).oldName or '')
    local newCategory = ensureSavedVehicleCategory((value or {}).name or value)
    if oldCategory == '' or oldCategory == newCategory then return true, ('Category ready: %s'):format(newCategory), extra end
    for _, entry in ipairs(state.savedVehicles or {}) do
      if type(entry) == 'table' and sameSavedVehicleCategory(entry.category or entry.legacyCategory, oldCategory) then entry.category = newCategory end
    end
    for i = #state.savedVehicleCategories, 1, -1 do
      if sameSavedVehicleCategory(state.savedVehicleCategories[i], oldCategory) then table.remove(state.savedVehicleCategories, i) end
    end
    ensureSavedVehicleCategory(newCategory)
    savePersistentState()
    return true, ('Renamed category to %s'):format(newCategory), extra
  elseif action == 'deleteSavedVehicleCategory' then
    local category = normalizeSavedVehicleCategory((context or {}).category or value)
    for _, entry in ipairs(state.savedVehicles or {}) do
      if type(entry) == 'table' and sameSavedVehicleCategory(entry.category or entry.legacyCategory, category) then entry.category = 'Uncategorized' end
    end
    for i = #state.savedVehicleCategories, 1, -1 do
      if sameSavedVehicleCategory(state.savedVehicleCategories[i], category) then table.remove(state.savedVehicleCategories, i) end
    end
    savePersistentState()
    return true, ('Category %s removed; vehicles moved to Uncategorized'):format(category), extra
  elseif action == 'setSavedVehicleCategory' then
    local index = ((context or {}).vehicleIndex or tonumber(value and value.vehicleIndex) or -1) + 1
    local entry = state.savedVehicles[index]
    if not entry then return false, 'Saved vehicle not found', extra end
    local category = ensureSavedVehicleCategory((value or {}).category or (value or {}).name or value)
    entry.category = category
    savePersistentState()
    return true, ('Vehicle moved to %s'):format(category), extra
  elseif action == 'clearSavedVehicleCategory' then
    local index = ((context or {}).vehicleIndex or tonumber(value) or -1) + 1
    local entry = state.savedVehicles[index]
    if not entry then return false, 'Saved vehicle not found', extra end
    entry.category = 'Uncategorized'
    savePersistentState()
    return true, 'Vehicle moved to Uncategorized', extra
  elseif action == 'spawnSavedVehicle' then return spawnSavedVehicle(tonumber(value) or 0)
  elseif action == 'deleteSavedVehicle' then table.remove(state.savedVehicles, (tonumber(value) or 0) + 1); savePersistentState(); return true, 'Saved vehicle removed', extra
  elseif action == 'exportVehicleCode' then
    local veh = currentVehicleOrPersonal(); if veh == 0 then return false, 'No vehicle found' end
    local code = encodeShareCode(captureVehicleData(veh))
    extra = { title = 'Vehicle Share Code', displayText = code, copyText = code }
    return true, 'Vehicle share code ready', extra
  elseif action == 'importVehicleCode' then
    local decoded, err = decodeShareCode((value or {}).code or '')
    if not decoded then return false, err end
    return applyVehicleData(decoded)
  elseif action == 'setPersonalVehicle' then local veh = getVehicleFromPlayerOrNear(); if veh == 0 then return false, 'No vehicle found' end; setPersonalVehicle(veh); return true, 'Personal vehicle set', extra
  elseif action == 'togglePersonalEngine' then local veh = getPersonalVehicleEntity(); if veh == 0 then return false, 'No personal vehicle' end; local on = GetIsVehicleEngineRunning(veh); SetVehicleEngineOn(veh, not on, false, true); return true, on and 'Engine off' or 'Engine on', extra
  elseif action == 'togglePersonalLights' then local veh = getPersonalVehicleEntity(); if veh == 0 then return false, 'No personal vehicle' end; SetVehicleLights(veh, 2); return true, 'Lights toggled', extra
  elseif action == 'lockPersonalVehicle' then local veh = getPersonalVehicleEntity(); if veh == 0 then return false, 'No personal vehicle' end; local locked = GetVehicleDoorLockStatus(veh) == 2; SetVehicleDoorsLocked(veh, locked and 1 or 2); return true, locked and 'Vehicle unlocked' or 'Vehicle locked', extra
  elseif action == 'kickPassengers' then
    local veh = getPersonalVehicleEntity(); if veh == 0 then return false, 'No personal vehicle' end
    for i = 0, GetVehicleMaxNumberOfPassengers(veh) - 1 do
      local passenger = GetPedInVehicleSeat(veh, i)
      if passenger ~= 0 then TaskLeaveVehicle(passenger, veh, 16) end
    end
    return true, 'Passengers kicked', extra
  elseif action == 'hornPersonalVehicle' then local veh = getPersonalVehicleEntity(); if veh == 0 then return false, 'No personal vehicle' end; StartVehicleHorn(veh, 1500, GetHashKey('HELDDOWN'), false); return true, 'Horn sounded', extra
  elseif action == 'alarmPersonalVehicle' then local veh = getPersonalVehicleEntity(); if veh == 0 then return false, 'No personal vehicle' end; SetVehicleAlarm(veh, true); StartVehicleAlarm(veh); return true, 'Alarm started', extra
  elseif action == 'togglePersonalBlip' then
    local veh = getPersonalVehicleEntity(); if veh == 0 then return false, 'No personal vehicle' end
    if personalBlip and DoesBlipExist(personalBlip) then RemoveBlip(personalBlip); personalBlip = nil; return true, 'Personal vehicle blip removed', extra end
    personalBlip = AddBlipForEntity(veh); return true, 'Personal vehicle blip added', extra
  elseif action == 'deletePersonalVehicle' then local veh = getPersonalVehicleEntity(); if veh == 0 then return false, 'No personal vehicle' end; local deleted = deleteTrackedVehicle(veh); return deleted, deleted and 'Personal vehicle deleted' or 'Failed to delete personal vehicle', extra
  elseif action == 'setTime' then
    if not worldControlsEnabled() then return false, 'World controls are disabled in config', extra end
    local result = awaitServer('setWorldTime', { hour = tonumber((value or {}).hour or 12) or 12, minute = tonumber((value or {}).minute or 0) or 0 })
    if result and result.ok and result.world then applyWorldState(result.world) end
    return result and result.ok, result and result.message or 'Failed to set time', extra
  elseif action == 'setWeather' then
    if not worldControlsEnabled() then return false, 'World controls are disabled in config', extra end
    local result = awaitServer('setWorldWeather', { weather = tostring(value or 'CLEAR') })
    if result and result.ok and result.world then applyWorldState(result.world) end
    return result and result.ok, result and result.message or 'Failed to set weather', extra
  elseif action == 'removeClouds' then
    if not worldControlsEnabled() then return false, 'World controls are disabled in config', extra end
    local result = awaitServer('setWorldClouds', { mode = 'clear' })
    if result and result.ok and result.world then applyWorldState(result.world) end
    return result and result.ok, result and result.message or 'Failed to update clouds', extra
  elseif action == 'randomizeClouds' then
    if not worldControlsEnabled() then return false, 'World controls are disabled in config', extra end
    local result = awaitServer('setWorldClouds', { mode = 'random' })
    if result and result.ok and result.world then applyWorldState(result.world) end
    return result and result.ok, result and result.message or 'Failed to update clouds', extra
  elseif action == 'teleportToWaypoint' then return teleportToWaypoint()
  elseif action == 'teleportToCoords' then setCoordsSafe(tonumber((value or {}).x or 0) or 0, tonumber((value or {}).y or 0) or 0, tonumber((value or {}).z or 72) or 72); return true, 'Teleported', extra
  elseif action == 'teleportToVector' then
    local parsed = parseVectorText((value or {}).coords or '')
    if not parsed then return false, 'Invalid vector3/vector4 text' end
    setCoordsSafe(parsed.x, parsed.y, parsed.z)
    if parsed.h then SetEntityHeading(myPed, parsed.h + 0.0) end
    return true, 'Teleported from vector text', extra
  elseif action == 'teleportPreset' then setCoordsSafe((value or {})[1], (value or {})[2], (value or {})[3]); return true, 'Teleported to preset', extra
  elseif action == 'showCoordsText' then
    local v3, v4 = currentCoordsStrings()
    extra = { title = 'Current Coordinates', displayText = v4 .. '\n' .. v3, copyText = v4 }
    return true, 'Coordinates ready', extra
  elseif action == 'showEntityDebug' then
    local text = entityDebugText(value)
    extra = { title = 'Entity Debug', displayText = text, copyText = text }
    return true, 'Entity debug ready', extra
  elseif action == 'copyCoordsV3' then
    local v3 = currentCoordsStrings()
    extra = { title = 'Vector3 Coordinates', displayText = v3, copyText = v3 }
    return true, 'Vector3 ready', extra
  elseif action == 'copyCoordsV4' then
    local _, v4 = currentCoordsStrings()
    extra = { title = 'Vector4 Coordinates', displayText = v4, copyText = v4 }
    return true, 'Vector4 ready', extra
  elseif action == 'spawnEntity' then local model = (value or {}).model; local hash, err = ensureModel(model); if not hash then return false, err end; local c = GetOffsetFromEntityInWorldCoords(myPed, 0.0, 2.0, 0.0); local obj = CreateObject(hash, c.x, c.y, c.z, true, true, false); PlaceObjectOnGroundProperly(obj); SetModelAsNoLongerNeeded(hash); return true, ('Spawned object %s'):format(model), extra
  elseif action == 'spawnEntityQuick' then local hash, err = ensureModel(value); if not hash then return false, err end; local c = GetOffsetFromEntityInWorldCoords(myPed, 0.0, 2.0, 0.0); local obj = CreateObject(hash, c.x, c.y, c.z, true, true, false); PlaceObjectOnGroundProperly(obj); SetModelAsNoLongerNeeded(hash); return true, ('Spawned object %s'):format(value), extra
  elseif action == 'clearArea' then local c = GetEntityCoords(myPed); ClearAreaOfPeds(c.x, c.y, c.z, 50.0, 1); ClearAreaOfVehicles(c.x, c.y, c.z, 50.0, false, false, false, false, false); return true, 'Area cleared', extra
  elseif action == 'restoreAppearance' then if not state.restore.appearance then return false, 'No appearance snapshot' end; local hash, err = ensureModel(state.restore.appearance); if not hash then return false, err end; SetPlayerModel(pid(), hash); SetPedDefaultComponentVariation(ped()); SetModelAsNoLongerNeeded(hash); return true, 'Appearance restored', extra
  elseif action == 'restoreWeapons' then if not state.restore.weapons then return false, 'No weapon snapshot' end; RemoveAllPedWeapons(myPed, true); for _, entry in ipairs(state.restore.weapons) do GiveWeaponToPed(myPed, GetHashKey(entry.weapon), entry.ammo or 999, false, false) end; return true, 'Weapons restored', extra
  elseif action == 'takePhoto' then if StartRecording then StartRecording(0) end; return true, 'Photo/record native triggered', extra
  elseif action == 'openGallery' then return true, 'Gallery is handled by Rockstar Editor', extra
  elseif action == 'startRecording' then if StartRecording then StartRecording(1) end; return true, 'Recording started', extra
  elseif action == 'stopRecording' then if StopRecordingAndSaveClip then StopRecordingAndSaveClip() end; return true, 'Recording stopped', extra
  elseif action == 'openEditor' then if ActivateRockstarEditor then ActivateRockstarEditor() end; return true, 'Rockstar Editor requested', extra
  elseif action == 'teleportToPlayer' then local target = playerByServerId(tonumber(value)); if not target then return false, 'Player not found' end; local c = GetEntityCoords(GetPlayerPed(target)); setCoordsSafe(c.x, c.y, c.z + 1.0); return true, 'Teleported to player', extra
  elseif action == 'waypointToPlayer' then local target = playerByServerId(tonumber(value)); if not target then return false, 'Player not found' end; local c = GetEntityCoords(GetPlayerPed(target)); SetNewWaypoint(c.x, c.y); return true, 'Waypoint set to player', extra
  elseif action == 'spectatePlayer' then local serverId = tonumber(value); local target = playerByServerId(serverId); if not target then return false, 'Player not found' end; local targetPed = GetPlayerPed(target); if spectatingTarget == serverId then NetworkSetInSpectatorMode(false, targetPed); spectatingTarget = nil; return true, 'Stopped spectating', extra else NetworkSetInSpectatorMode(true, targetPed); spectatingTarget = serverId; return true, 'Spectating player', extra end
  elseif action == 'summonPlayer' then return serverModeration('summonPlayer', { target = tonumber(value), coords = GetEntityCoords(myPed) })
  elseif action == 'killPlayer' then return serverModeration('killPlayer', { target = tonumber(value) })
  elseif action == 'kickPlayer' then return serverModeration('kickPlayer', { target = tonumber((context or {}).playerId), reason = (value or {}).reason })
  elseif action == 'tempBanPlayer' then return serverModeration('tempBanPlayer', { target = tonumber((context or {}).playerId), minutes = tonumber((value or {}).minutes or 60), reason = (value or {}).reason })
  elseif action == 'permBanPlayer' then return serverModeration('permBanPlayer', { target = tonumber((context or {}).playerId), reason = (value or {}).reason })
  elseif action == 'identifiers' then local result = awaitServer('identifiers', { target = tonumber(value) }); extra = result and result.ok and { title = 'Identifiers', displayText = result.message or '', copyText = result.message or '' } or nil; return result and result.ok, result and result.message or 'Failed', extra
  elseif action == 'sendPrivateMessage' then return serverModeration('sendPrivateMessage', { target = tonumber((context or {}).playerId), message = (value or {}).message })
  elseif action == 'showPermissionsSummary' then
    local result = awaitServer('permissionsSummary', {})
    extra = result and result.ok and { title = 'Permissions Summary', displayText = result.displayText or result.message or '', copyText = result.displayText or '' } or nil
    return result and result.ok, result and result.message or 'Failed', extra
  elseif action == 'grantPlayerGroup' then
    local result = awaitServer('grantPlayerGroup', { target = tonumber(value), group = tostring((context or {}).group or '') })
    return result and result.ok, result and result.message or 'Server action failed', extra
  elseif action == 'revokePlayerGroup' then
    local result = awaitServer('revokePlayerGroup', { target = tonumber(value), group = tostring((context or {}).group or '') })
    return result and result.ok, result and result.message or 'Server action failed', extra
  elseif action == 'addPermissionPrincipal' then
    local result = awaitServer('addPermissionPrincipal', { subject = (value or {}).subject, group = (value or {}).group })
    return result and result.ok, result and result.message or 'Server action failed', extra
  elseif action == 'removePermissionPrincipal' then
    local result = awaitServer('removePermissionPrincipal', { subject = (value or {}).subject, group = (value or {}).group })
    return result and result.ok, result and result.message or 'Server action failed', extra
  elseif action == 'addPermissionAce' then
    local result = awaitServer('addPermissionAce', { principal = (value or {}).principal, ace = (value or {}).ace, mode = (value or {}).mode })
    return result and result.ok, result and result.message or 'Server action failed', extra
  elseif action == 'removePermissionAce' then
    local result = awaitServer('removePermissionAce', { principal = (value or {}).principal, ace = (value or {}).ace, mode = (value or {}).mode })
    return result and result.ok, result and result.message or 'Server action failed', extra
  elseif action == 'clearBlood' then
    ClearPedBloodDamage(myPed)
    return true, 'Blood cleared', extra
  elseif action == 'commitSuicide' then
    SetEntityHealth(myPed, 0)
    return true, 'You died', extra
  elseif action == 'forceStopScenario' then
    ClearPedTasksImmediately(myPed)
    return true, 'Scenario stopped', extra
  elseif action == 'startScenario' then
    if type(value) ~= 'string' or value == '' then return false, 'Invalid scenario', extra end
    ClearPedTasksImmediately(myPed)
    TaskStartScenarioInPlace(myPed, value, 0, true)
    return true, ('Scenario: %s'):format(value), extra
  elseif action == 'setArmorType' then
    SetPedArmour(myPed, math.max(0, math.min(100, tonumber(value) or 0)))
    return true, ('Armor set to %s'):format(math.max(0, math.min(100, tonumber(value) or 0))), extra
  elseif action == 'setVehicleDirtLevel' then
    local veh = currentVehicleOrPersonal(); if veh == 0 then return false, 'No vehicle found' end
    local dirt = tonumber((value or {}).dirt or 0) or 0
    dirt = math.max(0.0, math.min(15.0, dirt + 0.0))
    SetVehicleDirtLevel(veh, dirt)
    return true, ('Dirt level set to %.1f'):format(dirt), extra
  elseif action == 'setEngineTorqueMultiplier' then
    local veh = currentVehicleOrPersonal(); if veh == 0 then return false, 'No vehicle found' end
    local mult = tonumber((value or {}).value or 1.0) or 1.0
    SetVehicleEngineTorqueMultiplier(veh, mult + 0.0)
    return true, ('Torque multiplier set to %.2f'):format(mult), extra
  elseif action == 'setEnginePowerMultiplier' then
    local veh = currentVehicleOrPersonal(); if veh == 0 then return false, 'No vehicle found' end
    local mult = tonumber((value or {}).value or 1.0) or 1.0
    SetVehicleEnginePowerMultiplier(veh, mult + 0.0)
    return true, ('Power multiplier set to %.2f'):format(mult), extra
  elseif action == 'teleportIntoPlayerVehicle' then
    local target = playerByServerId(tonumber(value)); if not target then return false, 'Player not found' end
    local targetPed = GetPlayerPed(target)
    if targetPed == 0 or not IsPedInAnyVehicle(targetPed, false) then return false, 'Target is not in a vehicle', extra end
    local veh = GetVehiclePedIsIn(targetPed, false)
    for seat = -1, GetVehicleMaxNumberOfPassengers(veh) - 1 do
      if IsVehicleSeatFree(veh, seat) then
        SetPedIntoVehicle(myPed, veh, seat)
        return true, 'Teleported into player vehicle', extra
      end
    end
    return false, 'No free seat in target vehicle', extra
  elseif action == 'toggleGPS' then
    local target = playerByServerId(tonumber(value)); if not target then return false, 'Player not found' end
    local c = GetEntityCoords(GetPlayerPed(target))
    SetNewWaypoint(c.x, c.y)
    return true, 'GPS waypoint set', extra
  elseif action == 'unbanPlayer' then
    local result = awaitServer('unbanPlayer', { index = tonumber(value) })
    if result and result.ok then
      local ok, banResult = pcall(function() return awaitServer('getBans', {}) end)
      if ok and banResult and banResult.ok then state.bans = banResult.bans or {} end
    end
    return result and result.ok, result and result.message or 'Server action failed', extra
  elseif action == 'setMenuScale' then
    if state.ui.allowPositioning == false then return false, 'Menu positioning is locked by server config', extra end
    local newScale = tonumber((value or {}).scale or state.ui.scale) or state.ui.scale
    state.ui.scale = math.max(0.7, math.min(1.4, newScale))
    return true, ('Menu scale set to %.2f'):format(state.ui.scale), extra
  elseif action == 'setMenuOffsets' then
    if state.ui.allowPositioning == false then return false, 'Menu positioning is locked by server config', extra end
    state.ui.offsetX = math.max(0, math.min(400, tonumber((value or {}).x or state.ui.offsetX) or state.ui.offsetX))
    state.ui.offsetY = math.max(0, math.min(400, tonumber((value or {}).y or state.ui.offsetY) or state.ui.offsetY))
    return true, ('Menu moved to X:%d Y:%d'):format(state.ui.offsetX, state.ui.offsetY), extra
  elseif action == 'renamePed' then return renameSaved(state.savedPeds, (context or {}).pedIndex or value, (value or {}).name, 'Saved ped'), extra
  elseif action == 'clonePed' then return cloneSaved(state.savedPeds, (context or {}).pedIndex or value, 'Saved ped'), extra
  elseif action == 'replacePed' then
    local entry = state.savedPeds[((context or {}).pedIndex or tonumber(value) or -1) + 1]
    if not entry then return false, 'Saved ped not found', extra end
    entry.model = GetEntityModel(myPed)
    savePersistentState()
    return true, 'Saved ped replaced', extra
  elseif action == 'renameOutfit' then return renameOrCloneOutfit((context or {}).outfitIndex or value, (value or {}).name, false)
  elseif action == 'cloneOutfit' then return renameOrCloneOutfit((context or {}).outfitIndex or value, (value or {}).name, true)
  elseif action == 'updateOutfit' then
    local entry = state.savedOutfits[((context or {}).outfitIndex or tonumber(value) or -1) + 1]
    if not entry then return false, 'Saved character not found', extra end
    local data = captureOutfitData(myPed)
    for k,v in pairs(data) do entry[k] = v end
    savePersistentState()
    return true, 'Character updated from current appearance', extra
  elseif action == 'setDefaultOutfit' then
    for i, entry in ipairs(state.savedOutfits) do entry.isDefault = (i == ((tonumber((context or {}).outfitIndex or value) or -1) + 2)) end
    savePersistentState()
    return true, 'Default character set', extra
  elseif action == 'randomizeCharacter' then
    for comp = 0, 11 do
      local maxDrawable = GetNumberOfPedDrawableVariations(myPed, comp)
      if maxDrawable and maxDrawable > 0 then
        local drawable = math.random(0, maxDrawable - 1)
        local maxTexture = GetNumberOfPedTextureVariations(myPed, comp, drawable)
        SetPedComponentVariation(myPed, comp, drawable, math.max(0, (maxTexture or 1) - 1 > 0 and math.random(0, (maxTexture or 1) - 1) or 0), 0)
      end
    end
    for prop = 0, 7 do
      local maxProp = GetNumberOfPedPropDrawableVariations(myPed, prop)
      if maxProp and maxProp > 0 then
        local drawable = math.random(-1, maxProp - 1)
        if drawable < 0 then ClearPedProp(myPed, prop) else SetPedPropIndex(myPed, prop, drawable, 0, true) end
      end
    end
    return true, 'Character randomized', extra
  elseif action == 'saveCharacter' then return saveCurrentOutfit((value or {}).name or 'Character')
  elseif action == 'setWalkingStyle' then return setWalkingStyle(type(value) == 'table' and value.style or value)
  elseif action == 'setAllAmmoCount' then return setAllAmmoCount((value or {}).count or value)
  elseif action == 'setWeaponTint' then return setWeaponTint((context or {}).weapon, (value or {}).tint or value)
  elseif action == 'giveWeaponComponent' then
    local weapon = GetHashKey(tostring((context or {}).weapon or ''))
    local component = tostring((value or {}).component or value or '')
    if component == '' then return false, 'Component required', extra end
    GiveWeaponComponentToPed(myPed, weapon, GetHashKey(component))
    return true, ('Component added: %s'):format(component), extra
  elseif action == 'togglePrimaryParachute' then
    local hash = GetHashKey('GADGET_PARACHUTE')
    if HasPedGotWeapon(myPed, hash, false) then RemoveWeaponFromPed(myPed, hash); return true, 'Primary parachute removed', extra end
    GiveWeaponToPed(myPed, hash, 1, false, true)
    return true, 'Primary parachute equipped', extra
  elseif action == 'setPrimaryParachuteStyle' then return setParachuteTint((value or {}).tint or value, nil)
  elseif action == 'setReserveParachuteStyle' then return setParachuteTint(nil, (value or {}).tint or value)
  elseif action == 'setParachuteSmokeTrailColor' then return setParachuteSmokeTrailColor((value or {}).r, (value or {}).g, (value or {}).b)
  elseif action == 'renameLoadout' then return renameSaved(state.loadouts, (context or {}).loadoutIndex or value, (value or {}).name, 'Loadout')
  elseif action == 'cloneLoadout' then return cloneSaved(state.loadouts, (context or {}).loadoutIndex or value, 'Loadout')
  elseif action == 'setDefaultLoadout' then state.values.defaultLoadoutIndex = tonumber((context or {}).loadoutIndex or value) or -1; savePersistentState(); return true, 'Default loadout set', extra
  elseif action == 'replaceLoadout' then
    local index = ((context or {}).loadoutIndex or tonumber(value) or -1) + 1
    if not state.loadouts[index] then return false, 'Loadout not found', extra end
    local weapons = {}
    for _, weapon in ipairs(weaponList) do
      local hash = GetHashKey(weapon)
      if HasPedGotWeapon(myPed, hash, false) then table.insert(weapons, { weapon = weapon, ammo = GetAmmoInPedWeapon(myPed, hash) }) end
    end
    state.loadouts[index].weapons = weapons
    savePersistentState()
    return true, 'Loadout replaced', extra
  elseif action == 'setRadioStation' then state.values.radioStation = tostring((value or {}).station or value or 'OFF'); return true, ('Default radio station set to %s'):format(state.values.radioStation), extra
  elseif action == 'cycleVehicleSeat' then return cycleVehicleSeat()
  elseif action == 'fixTires' then
    local veh = currentVehicleOrPersonal(); if veh == 0 then return false, 'No vehicle found', extra end
    for i = 0, 7 do SetVehicleTyreFixed(veh, i) end
    return true, 'Tires fixed', extra
  elseif action == 'destroyTires' then
    local veh = currentVehicleOrPersonal(); if veh == 0 then return false, 'No vehicle found', extra end
    for i = 0, 7 do SetVehicleTyreBurst(veh, i, true, 1000.0) end
    return true, 'Tires destroyed', extra
  elseif action == 'destroyEngine' then
    local veh = currentVehicleOrPersonal(); if veh == 0 then return false, 'No vehicle found', extra end
    SetVehicleEngineHealth(veh, -4000.0)
    return true, 'Engine destroyed', extra
  elseif action == 'setPlateType' then return setPlateType((value or {}).index or value)
  elseif action == 'renameSavedVehicle' then return renameSaved(state.savedVehicles, (context or {}).vehicleIndex or value, (value or {}).name, 'Vehicle')
  elseif action == 'replaceSavedVehicle' then
    local entry = state.savedVehicles[((context or {}).vehicleIndex or tonumber(value) or -1) + 1]
    local veh = getVehicleFromPlayerOrNear()
    if not entry then return false, 'Saved vehicle not found', extra end
    if veh == 0 then return false, 'No current vehicle found', extra end
    local data = captureVehicleData(veh)
    data.name = entry.name
    data.category = normalizeSavedVehicleCategory(entry.category or entry.legacyCategory or 'Uncategorized')
    data.legacyCategory = entry.legacyCategory
    state.savedVehicles[((context or {}).vehicleIndex or tonumber(value) or -1) + 1] = data
    savePersistentState()
    return true, 'Saved vehicle replaced', extra
  elseif action == 'setVehicleStance' then return setVehicleStance((value or {}).height or value)
  elseif action == 'openAllDoors' then return openAllVehicleDoors()
  elseif action == 'closeAllDoors' then return closeAllVehicleDoors()
  elseif action == 'removeDoor' then return breakVehicleDoor((value or {}).door or value)
  elseif action == 'restoreDoors' then return fixVehicleDoors()
  elseif action == 'setVoiceChannel' then state.values.voiceChannel = tonumber((value or {}).channel or value) or 0; MumbleSetVoiceChannel(state.values.voiceChannel); return true, ('Voice channel set to %s'):format(state.values.voiceChannel), extra
  elseif action == 'disconnectFromServer' then ExecuteCommand('disconnect'); return true, 'Disconnect requested', extra
  elseif action == 'quitSession' then NetworkSessionEnd(true, true); return true, 'Session end requested', extra
  elseif action == 'rejoinSession' then ExecuteCommand('reconnect'); return true, 'Reconnect requested', extra
  elseif action == 'quitGame' then ForceSocialClubUpdate(); return true, 'Quit requested', extra
  elseif action == 'toggleThemeBlue' then
    if state.ui.allowThemeSelection == false then return false, 'Theme presets are locked by server config', extra end
    state.ui.theme = 'blue'
    state.ui.preset = 'blue'
    return true, 'Theme set to blue', extra
  elseif action == 'setBloodLevel' then
    local level = math.max(0, math.min(10, tonumber((value or {}).level or value) or 0))
    ClearPedBloodDamage(myPed)
    for i = 1, level do ApplyPedDamagePack(myPed, 'SCR_Torture', 0.0, 1.0) end
    return true, ('Blood level set to %s'):format(level), extra
  elseif action == 'toggleVehicleLightsBlackout' then state.toggles.vehicleLightsBlackout = not state.toggles.vehicleLightsBlackout; return true, state.toggles.vehicleLightsBlackout and 'Vehicle lights blackout enabled' or 'Vehicle lights blackout disabled', extra
  elseif action == 'toggleSnowEffects' then state.toggles.snowEffects = not state.toggles.snowEffects; return true, state.toggles.snowEffects and 'Snow effects enabled' or 'Snow effects disabled', extra
  elseif action == 'toggleRespawnDefaultMp' then state.toggles.respawnDefaultMp = not state.toggles.respawnDefaultMp; return true, state.toggles.respawnDefaultMp and 'Default MP respawn enabled' or 'Default MP respawn disabled', extra
  elseif action == 'setTheme' then
    if state.ui.allowThemeSelection == false then return false, 'Theme presets are locked by server config', extra end
    state.ui.theme = tostring(value or 'blue')
    state.ui.preset = tostring(value or state.ui.preset or 'blue')
    return true, ('Theme set to %s'):format(state.ui.theme), extra
  elseif action == 'setThemePreset' then
    if state.ui.allowThemeSelection == false then return false, 'Theme presets are locked by server config', extra end
    local preset = tostring((value or {}).preset or value or state.ui.preset or 'blue')
    state.ui.preset = preset
    state.ui.theme = preset
    return true, ('Theme preset set to %s'):format(preset), extra
  elseif action == 'setBannerImageUrl' then
    if state.ui.allowBannerEditing == false then return false, 'Banner editing is locked by server config', extra end
    local okPath, sanitized = sanitizeUiAssetPath((value or {}).url or value)
    if not okPath then return false, sanitized, extra end
    state.ui.bannerImage = sanitized
    return true, sanitized ~= '' and 'Banner image updated' or 'Banner image cleared', extra
  elseif action == 'setBannerLogoUrl' then
    if state.ui.allowBannerEditing == false then return false, 'Banner editing is locked by server config', extra end
    local okPath, sanitized = sanitizeUiAssetPath((value or {}).url or value)
    if not okPath then return false, sanitized, extra end
    state.ui.bannerLogo = sanitized
    return true, sanitized ~= '' and 'Banner logo updated' or 'Banner logo cleared', extra
  elseif action == 'setBrandText' then
    if state.ui.allowBannerEditing == false then return false, 'Banner editing is locked by server config', extra end
    local brand = trimString((value or {}).text or value)
    if brand == '' then brand = (Config and Config.UI and Config.UI.brandText) or 'AMenu' end
    state.ui.brandText = brand:sub(1, 64)
    return true, ('Brand text set to %s'):format(state.ui.brandText), extra
  elseif action == 'setHeaderHeight' then
    if state.ui.allowBannerEditing == false then return false, 'Banner editing is locked by server config', extra end
    local height = tonumber((value or {}).height or value)
    if not height then return false, 'Invalid header height', extra end
    state.ui.headerHeight = math.min(180, math.max(80, height))
    return true, ('Header height set to %spx'):format(math.floor(state.ui.headerHeight)), extra
  elseif action == 'setBannerFitMode' then
    if state.ui.allowBannerEditing == false then return false, 'Banner editing is locked by server config', extra end
    local mode = tostring((value or {}).mode or value or 'contain'):lower()
    if mode ~= 'contain' and mode ~= 'cover' and mode ~= 'stretch' then return false, 'Valid modes: contain, cover, stretch', extra end
    state.ui.bannerFitMode = mode
    return true, ('Banner fit mode set to %s'):format(mode), extra
  elseif action == 'setBannerPosition' then
    if state.ui.allowBannerEditing == false then return false, 'Banner editing is locked by server config', extra end
    local pos = trimString((value or {}).position or value)
    if pos == '' then pos = 'center center' end
    state.ui.bannerPosition = pos:sub(1, 64)
    return true, ('Banner position set to %s'):format(state.ui.bannerPosition), extra
  elseif action == 'setBannerOverlayOpacity' then
    if state.ui.allowBannerEditing == false then return false, 'Banner editing is locked by server config', extra end
    local opacity = tonumber((value or {}).opacity or value)
    if opacity == nil then return false, 'Invalid banner overlay opacity', extra end
    state.ui.bannerOverlayOpacity = math.min(0.60, math.max(0.0, opacity))
    return true, ('Banner overlay opacity set to %.2f'):format(state.ui.bannerOverlayOpacity), extra
  elseif action == 'clearBannerImage' then
    if state.ui.allowBannerEditing == false then return false, 'Banner editing is locked by server config', extra end
    state.ui.bannerImage = ''
    return true, 'Banner image cleared', extra
  elseif action == 'clearBannerLogo' then
    if state.ui.allowBannerEditing == false then return false, 'Banner editing is locked by server config', extra end
    state.ui.bannerLogo = ''
    return true, 'Banner logo cleared', extra
  elseif action == 'resetMenuAppearance' then
    if state.ui.allowBannerEditing == false and state.ui.allowThemeSelection == false and state.ui.allowPositioning == false then
      return false, 'Menu appearance is locked by server config', extra
    end
    if state.ui.allowPositioning ~= false then
      state.ui.rightAlign = (Config and Config.UI and Config.UI.defaultRightAlign) == true
      state.toggles.rightAlign = state.ui.rightAlign
      state.ui.offsetX = (Config and Config.UI and Config.UI.defaultOffsetX) or 18
      state.ui.offsetY = (Config and Config.UI and Config.UI.defaultOffsetY) or 18
      state.ui.scale = (Config and Config.UI and Config.UI.defaultScale) or 1.0
    end
    if state.ui.allowThemeSelection ~= false then
      state.ui.theme = (Config and Config.UI and Config.UI.defaultTheme) or ((Config and Config.UI and Config.UI.defaultPreset) or 'blue')
      state.ui.preset = (Config and Config.UI and Config.UI.defaultPreset) or state.ui.theme or 'blue'
    end
    if state.ui.allowBannerEditing ~= false then
      state.ui.brandText = (Config and Config.UI and Config.UI.brandText) or 'AMenu'
      state.ui.bannerImage = (Config and Config.UI and Config.UI.bannerImage) or ''
      state.ui.bannerLogo = (Config and Config.UI and Config.UI.bannerLogo) or ''
      state.ui.headerHeight = tonumber((Config and Config.UI and Config.UI.headerHeight) or 112) or 112
      state.ui.bannerFitMode = tostring((Config and Config.UI and Config.UI.bannerFitMode) or 'contain')
      state.ui.bannerPosition = tostring((Config and Config.UI and Config.UI.bannerPosition) or 'center center')
      state.ui.bannerOverlayOpacity = tonumber((Config and Config.UI and Config.UI.bannerOverlayOpacity) or 0.04) or 0.04
    end
    return true, 'Menu appearance reset to defaults', extra
  end

  return false, 'Unsupported action', extra
end

RegisterNUICallback('getState', function(_, cb)
  cb({ ok = true, state = buildState(true) })
end)

RegisterNUICallback('setModalInputMode', function(data, cb)
  local enabled = data and data.enabled == true
  if uiOpen then
    if enabled then
      SetNuiFocus(true, true)
      SetNuiFocusKeepInput(false)
    else
      SetNuiFocus(true, false)
      SetNuiFocusKeepInput(true)
    end
  else
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
  end
  cb({ ok = true })
end)

RegisterNUICallback('requestInput', function(data, cb)
  local wasOpen = uiOpen == true
  SetNuiFocus(false, false)
  SetNuiFocusKeepInput(false)
  local values = requestPromptFields(data and data.title or 'Input', data and data.fields or {})
  if wasOpen then
    SetNuiFocus(true, false)
    SetNuiFocusKeepInput(true)
  end
  cb({ ok = true, cancelled = values == nil, values = values or {} })
end)

RegisterNUICallback('close', function(_, cb)
  setUi(false)
  cb({ ok = true })
end)

RegisterNUICallback('exec', function(data, cb)
  local ok, message, extra = false, 'No action', nil
  if data.action == 'toggle' then
    if data.key == 'freezeTime' or data.key == 'dynamicWeather' or data.key == 'blackout' then
      if not worldControlsEnabled() then
        ok, message = false, 'World controls are disabled in config'
      else
        local actionMap = { freezeTime = 'toggleFreezeTime', dynamicWeather = 'toggleDynamicWeather', blackout = 'toggleBlackout' }
        local result = awaitServer(actionMap[data.key], {})
        if result and result.ok and result.world then applyWorldState(result.world) end
        ok, message = result and result.ok, result and result.message or 'Server action failed'
      end
    else
      ok, message = handleToggle(data.key)
    end
  elseif data.action == 'setValue' then
    ok, message = setVoiceRange(data.value)
  else
    ok, message, extra = handleAction(data.action, data.value, data.context)
  end
  savePersistentState()
  cb({ ok = ok, message = message, state = buildState(false), extra = extra })
end)

RegisterCommand('amenuui', function() setUi(not uiOpen) end, false)
RegisterKeyMapping('amenuui', 'Open Styled AMenu UI', 'keyboard', 'M')
RegisterCommand('amenuui_noclip', function() handleToggle('noclip') end, false)
RegisterKeyMapping('amenuui_noclip', 'Toggle AMenu UI NoClip', 'keyboard', 'F2')

AddEventHandler('onResourceStop', function(resource)
  if resource ~= GetCurrentResourceName() then return end
  deactivateNoclip()
  SetNuiFocus(false, false)
  SetNuiFocusKeepInput(false)
end)

CreateThread(function()
  local wheelCooldown = 0
  local clickCooldown = 0
  while true do
    if uiOpen then
      Wait(0)
      disableUiGameControls()

      local now = GetGameTimer()
      if now >= wheelCooldown then
        if uiControlJustPressed(14) or uiControlJustPressed(16) or uiControlJustPressed(81) or uiControlJustPressed(83) then
          SendNUIMessage({ action = 'menuWheel', direction = 1 })
          wheelCooldown = now + 15
        elseif uiControlJustPressed(15) or uiControlJustPressed(17) or uiControlJustPressed(82) or uiControlJustPressed(84) then
          SendNUIMessage({ action = 'menuWheel', direction = -1 })
          wheelCooldown = now + 15
        end
      end

      if now >= clickCooldown then
        if uiControlJustPressed(24) or uiControlJustPressed(69) or uiControlJustPressed(92) or uiControlJustPressed(257) then
          SendNUIMessage({ action = 'menuPress', press = 'enter' })
          clickCooldown = now + 140
        elseif uiControlJustPressed(25) or uiControlJustPressed(68) or uiControlJustPressed(70) or uiControlJustPressed(91) then
          SendNUIMessage({ action = 'menuPress', press = 'back' })
          clickCooldown = now + 140
        end
      end
    else
      Wait(250)
    end
  end
end)

CreateThread(function()
  loadPersistentState()
  if state.values.walkingStyle and state.values.walkingStyle ~= 'default' then pcall(function() setWalkingStyle(state.values.walkingStyle) end) end
  loadAddonsCatalog()
  ensureVehicleCatalog(true)
  if not (Config and Config.LegacyAMenu and Config.LegacyAMenu.autoImportSavedVehicles == false) then
    importLegacyAMenuSavedVehicles(false)
  end
  Wait(200)
  syncPmBlocksToServer()
  setUi(false)
  if worldSyncEnabled() and ((Config and Config.World and Config.World.syncOnJoin) == true) then
    local ok, result = pcall(function() return awaitServer('getWorldState', {}) end)
    if ok and result and result.ok and result.world then applyWorldState(result.world) end
  end
end)

CreateThread(function()
  while true do
    local active = false
    local p = ped()
    if state.toggles.god then SetEntityInvincible(p, true); SetPlayerInvincible(pid(), true); SetEntityCanBeDamaged(p, false); active = true else SetEntityInvincible(p, false); SetPlayerInvincible(pid(), false); SetEntityCanBeDamaged(p, true) end
    if state.toggles.invisible and not state.toggles.noclip then SetEntityVisible(p, false, false); active = true elseif not state.toggles.noclip then SetEntityVisible(p, true, false) end
    if state.toggles.unlimitedStamina then RestorePlayerStamina(pid(), 1.0); active = true end
    SetRunSprintMultiplierForPlayer(pid(), state.toggles.fastRun and 1.49 or 1.0)
    SetSwimMultiplierForPlayer(pid(), state.toggles.fastSwim and 1.49 or 1.0)
    if state.toggles.superJump then SetSuperJumpThisFrame(pid()); active = true end
    SetPedCanRagdoll(p, not state.toggles.noRagdoll)
    if state.toggles.neverWanted then ClearPlayerWantedLevel(pid()); SetMaxWantedLevel(0); active = true else SetMaxWantedLevel(5) end
    SetEveryoneIgnorePlayer(pid(), state.toggles.ignored)
    SetPoliceIgnorePlayer(pid(), state.toggles.ignored)
    if state.toggles.stayInVehicle and IsPedInAnyVehicle(p, false) then DisableControlAction(0, 75, true); active = true end
    if state.toggles.unlimitedAmmo then local current = GetSelectedPedWeapon(p); SetPedAmmo(p, current, 9999); active = true end
    SetPedInfiniteAmmoClip(p, state.toggles.noReload)
    if state.toggles.parachuteUnlimited or state.toggles.parachuteAutoEquip then
      local parachuteHash = GetHashKey('GADGET_PARACHUTE')
      if not HasPedGotWeapon(p, parachuteHash, false) then GiveWeaponToPed(p, parachuteHash, 1, false, false) end
      active = true
    end
    if worldSyncEnabled() and state.toggles.freezeTime then NetworkOverrideClockTime(state.values.timeHour or 12, state.values.timeMinute or 0, 0); active = true end
    if worldSyncEnabled() and state.toggles.dynamicWeather then active = true end
    if state.toggles.snowEffects then pcall(SetForcePedFootstepsTracks, true); pcall(SetForceVehicleTrails, true); active = true else pcall(SetForcePedFootstepsTracks, false); pcall(SetForceVehicleTrails, false) end
    pcall(SetArtificialLightsStateAffectsVehicles, state.toggles.vehicleLightsBlackout == true)
    local veh = GetVehiclePedIsIn(p, false)
    if veh ~= 0 then
      SetEntityInvincible(veh, state.toggles.vehicleGod)
      SetEntityVisible(veh, not state.toggles.vehicleInvisible, false)
      FreezeEntityPosition(veh, state.toggles.vehicleFreeze)
      if state.toggles.keepClean then SetVehicleDirtLevel(veh, 0.0); active = true end
      if state.toggles.engineAlwaysOn then SetVehicleEngineOn(veh, true, true, false); active = true end
      if state.toggles.autoRepairVehicle then SetVehicleFixed(veh); SetVehicleDeformationFixed(veh); active = true end
      if state.toggles.protectEngineDamage and GetVehicleEngineHealth(veh) < 1000.0 then SetVehicleEngineHealth(veh, 1000.0); active = true end
      if state.toggles.protectVisualDamage then SetVehicleFixed(veh); SetVehicleDeformationFixed(veh); active = true end
      SetVehicleTyresCanBurst(veh, not state.toggles.strongWheels)
      if state.toggles.sirenOff then SetVehicleSiren(veh, false); active = true end
      if state.toggles.infiniteFuel and SetVehicleFuelLevel then pcall(SetVehicleFuelLevel, veh, 100.0); active = true end
      if state.toggles.defaultRadio then SetVehRadioStation(veh, tostring(state.values.radioStation or 'OFF')); active = true end
      if state.toggles.flashHighbeamsOnHonk then local hornActive = (IsHornActive and IsHornActive(veh)) or false; pcall(SetVehicleFullbeam, veh, hornActive); active = true end
      if state.toggles.anchoredBoat and GetVehicleClass(veh) == 14 then pcall(SetBoatAnchor, veh, true); pcall(SetBoatFrozenWhenAnchored, veh, true); active = true end
      if not state.toggles.anchoredBoat and GetVehicleClass(veh) == 14 then pcall(SetBoatAnchor, veh, false) end
      if state.toggles.planeTurbulence and GetVehicleClass(veh) == 16 then pcall(SetPlaneTurbulenceMultiplier, veh, 0.0); active = true end
      if state.toggles.heliTurbulence and GetVehicleClass(veh) == 15 then pcall(SetHeliTurbulenceScalar, veh, 0.0); active = true end
      if state.values.speedLimitMph and state.values.speedLimitMph > 0 then SetEntityMaxSpeed(veh, state.values.speedLimitMph / 2.236936) else SetEntityMaxSpeed(veh, 999.0) end
    end
    if state.toggles.noBikeHelmet and (IsPedOnAnyBike(p) or IsPedInAnyVehicle(p, false)) then RemovePedHelmet(p, true) end
    if state.toggles.bikeSeatbelt then pcall(SetPedCanBeKnockedOffVehicle, p, 1) end
    if state.toggles.noclip then
      active = true
      local entity, usingVehicle = getNoclipTarget()
      if usingVehicle and GetPedInVehicleSeat(entity, -1) ~= p then
        deactivateNoclip()
        notify('NoClip disabled: you must be the driver.')
      else
        if noclipState.entity ~= 0 and noclipState.entity ~= entity then
          restoreNoclipEntity(noclipState.entity, noclipState.isVehicle)
        end
        noclipState.entity = entity
        noclipState.isVehicle = usingVehicle

        DisableControlAction(0, 30, true)
        DisableControlAction(0, 31, true)
        DisableControlAction(0, 32, true)
        DisableControlAction(0, 33, true)
        DisableControlAction(0, 34, true)
        DisableControlAction(0, 35, true)
        DisableControlAction(0, 22, true)
        DisableControlAction(0, 36, true)
        DisableControlAction(0, 44, true)
        DisableControlAction(0, 75, true)
        if usingVehicle then DisableControlAction(0, 85, true) end

        if IsDisabledControlJustPressed(0, 21) then
          noclipState.speedIndex = ((noclipState.speedIndex or 3) % #noclipSpeeds) + 1
        end
        if IsDisabledControlJustPressed(0, 74) then
          noclipState.followCam = not (noclipState.followCam == true)
        end

        local coords = GetEntityCoords(entity)
        local heading = GetEntityHeading(entity)
        local camRot = GetGameplayCamRot(2)
        local camZ = math.rad(camRot.z)
        local camX = math.rad(camRot.x)
        local camCos = math.abs(math.cos(camX))
        local dir = vector3(-math.sin(camZ) * camCos, math.cos(camZ) * camCos, math.sin(camX))
        local baseSpeed = noclipSpeeds[noclipState.speedIndex or 3] or 1.6
        local moveSpeed = baseSpeed * (GetFrameTime() * 60.0)

        SetEntityVelocity(entity, 0.0, 0.0, 0.0)
        FreezeEntityPosition(entity, true)
        SetEntityInvincible(entity, true)
        SetEntityCollision(entity, false, false)
        if noclipState.followCam then
          SetEntityHeading(entity, camRot.z)
        else
          if IsDisabledControlPressed(0, 34) then heading = heading + 2.5 end
          if IsDisabledControlPressed(0, 35) then heading = heading - 2.5 end
          SetEntityHeading(entity, heading)
          local headingRad = math.rad(heading)
          dir = vector3(-math.sin(headingRad), math.cos(headingRad), 0.0)
        end

        if usingVehicle then
          SetEntityVisible(entity, true, false)
          SetEntityAlpha(entity, 190, false)
        else
          if state.toggles.invisible then
            SetEntityVisible(entity, false, false)
          else
            SetEntityVisible(entity, true, false)
            SetEntityAlpha(entity, 190, false)
          end
          SetLocalPlayerVisibleLocally(true)
        end

        if IsDisabledControlPressed(0, 32) then coords = coords + dir * moveSpeed end
        if IsDisabledControlPressed(0, 33) then coords = coords - dir * moveSpeed end
        if IsDisabledControlPressed(0, 22) then coords = vector3(coords.x, coords.y, coords.z + moveSpeed) end
        if IsDisabledControlPressed(0, 36) then coords = vector3(coords.x, coords.y, coords.z - moveSpeed) end

        SetEntityCoordsNoOffset(entity, coords.x, coords.y, coords.z, true, true, true)
      end
    else
      if noclipState.entity ~= 0 then
        restoreNoclipEntity(noclipState.entity, noclipState.isVehicle)
        noclipState.entity = 0
        noclipState.isVehicle = false
      end
      SetEntityCollision(p, true, true)
      ResetEntityAlpha(p)
      if not state.toggles.freezePlayer then FreezeEntityPosition(p, false) end
    end
    Wait(active and 0 or 250)
  end
end)

CreateThread(function()
  while true do
    Wait(500)
    if state.toggles.exclusiveDriver then
      local veh = getPersonalVehicleEntity()
      if veh ~= 0 and DoesEntityExist(veh) then
        if GetPedInVehicleSeat(veh, -1) == ped() then
          SetVehicleDoorsLocked(veh, 2)
        end
      end
    end
  end
end)

local function drawText2D(x, y, text, scale)
  SetTextFont(4)
  SetTextScale(scale or 0.34, scale or 0.34)
  SetTextColour(255, 255, 255, 230)
  SetTextOutline()
  SetTextEntry('STRING')
  AddTextComponentString(text)
  DrawText(x, y)
end

local function drawText3D(x, y, z, text)
  local onScreen, _x, _y = World3dToScreen2d(x, y, z)
  if not onScreen then return end
  SetTextScale(0.30, 0.30)
  SetTextFont(4)
  SetTextColour(255, 255, 255, 220)
  SetTextOutline()
  SetTextEntry('STRING')
  SetTextCentre(true)
  AddTextComponentString(text)
  DrawText(_x, _y)
end

CreateThread(function()
  while true do
    local sleep = 500
    local p = ped()
    local veh = GetVehiclePedIsIn(p, false)
    if state.toggles.showSpeedKmh then sleep = 0; if veh ~= 0 then drawText2D(0.015, 0.89, ('Speed: %.1f KM/H'):format(GetEntitySpeed(veh) * 3.6), 0.34) end end
    if state.toggles.showSpeedMph then sleep = 0; if veh ~= 0 then drawText2D(0.015, 0.91, ('Speed: %.1f MPH'):format(GetEntitySpeed(veh) * 2.236936), 0.34) end end
    if state.toggles.showCoords then sleep = 0; local _, v4 = currentCoordsStrings(); drawText2D(0.015, 0.85, v4, 0.34) end
    if state.toggles.showTime then sleep = 0; drawText2D(0.015, 0.83, ('Time: %02d:%02d'):format(GetClockHours(), GetClockMinutes()), 0.34) end
    if state.toggles.locationDisplay then sleep = 0; local c = GetEntityCoords(p); local s, cr = GetStreetNameAtCoord(c.x, c.y, c.z); local street = GetStreetNameFromHashKey(s); local cross = cr ~= 0 and (' / ' .. GetStreetNameFromHashKey(cr)) or ''; drawText2D(0.015, 0.93, ('Location: %s%s'):format(street, cross), 0.34) end
    if state.toggles.showCurrentSpeaker and NetworkIsPlayerTalking(pid()) then sleep = 0; drawText2D(0.015, 0.95, 'Talking...', 0.34) end
    if state.toggles.showMicStatus then sleep = 0; drawText2D(0.015, 0.95, NetworkIsPlayerTalking(pid()) and 'Mic: Active' or 'Mic: Idle', 0.34) end
    if state.toggles.showVehicleHealth and veh ~= 0 then sleep = 0; drawText2D(0.015, 0.87, ('Veh HP: E %.0f | B %.0f'):format(GetVehicleEngineHealth(veh), GetVehicleBodyHealth(veh)), 0.34) end
    if state.toggles.overheadNames then sleep = 0; local my = GetEntityCoords(p); for _, ply in ipairs(GetActivePlayers()) do if ply ~= pid() then local tp = GetPlayerPed(ply); local c = GetEntityCoords(tp); if #(my - c) < 25.0 then drawText3D(c.x, c.y, c.z + 1.05, ('%s [%s]'):format(GetPlayerName(ply), GetPlayerServerId(ply))) end end end end
    if state.toggles.playerBlips then
      sleep = 0
      for _, ply in ipairs(GetActivePlayers()) do
        if ply ~= pid() then
          local sid = GetPlayerServerId(ply)
          if not playerBlips[sid] or not DoesBlipExist(playerBlips[sid]) then playerBlips[sid] = AddBlipForEntity(GetPlayerPed(ply)) end
          SetBlipNameToPlayerName(playerBlips[sid], ply)
        end
      end
      for sid, blip in pairs(playerBlips) do
        local exists = false
        for _, ply in ipairs(GetActivePlayers()) do if GetPlayerServerId(ply) == sid then exists = true break end end
        if not exists and DoesBlipExist(blip) then RemoveBlip(blip); playerBlips[sid] = nil end
      end
    else
      for sid, blip in pairs(playerBlips) do if DoesBlipExist(blip) then RemoveBlip(blip) end playerBlips[sid] = nil end
    end
    if state.toggles.locationBlips then
      sleep = 0
      for i, entry in ipairs((DATA and DATA.teleportPresets) or {}) do
        if not presetLocationBlips[i] or not DoesBlipExist(presetLocationBlips[i]) then
          local coords = entry.coords or {}
          local blip = AddBlipForCoord((coords[1] or 0.0) + 0.0, (coords[2] or 0.0) + 0.0, (coords[3] or 0.0) + 0.0)
          SetBlipAsShortRange(blip, true)
          BeginTextCommandSetBlipName('STRING')
          AddTextComponentString(tostring(entry.label or ('Location ' .. tostring(i))))
          EndTextCommandSetBlipName(blip)
          presetLocationBlips[i] = blip
        end
      end
    else
      for i, blip in pairs(presetLocationBlips) do if DoesBlipExist(blip) then RemoveBlip(blip) end presetLocationBlips[i] = nil end
    end
    Wait(sleep)
  end
end)

CreateThread(function()
  local fallback = (Config and Config.Controls and Config.Controls.fallbackOpenControl) or 244
  local useMenuFallback = not (Config and Config.Controls and Config.Controls.disableOpenFallback == true)
  while true do
    Wait(0)
    if useMenuFallback and not uiOpen and IsControlJustReleased(0, fallback) then
      setUi(true)
      Wait(150)
    end
  end
end)

CreateThread(function()
  local localWasDead = false
  while true do
    Wait(500)
    local p = ped()
    local isDead = IsEntityDead(p)
    if localWasDead and not isDead and state.values.defaultLoadoutIndex and state.values.defaultLoadoutIndex >= 0 then
      equipLoadout(state.values.defaultLoadoutIndex)
      if state.toggles.respawnDefaultMp and GetEntityModel(p) ~= GetHashKey('mp_m_freemode_01') and GetEntityModel(p) ~= GetHashKey('mp_f_freemode_01') then
        local hash = GetHashKey('mp_m_freemode_01')
        RequestModel(hash)
        while not HasModelLoaded(hash) do Wait(0) end
        SetPlayerModel(pid(), hash)
        SetPedDefaultComponentVariation(ped())
        SetModelAsNoLongerNeeded(hash)
      end
    end
    localWasDead = isDead
  end
end)

CreateThread(function()
  while true do
    Wait(750)
    if state.toggles.deathNotifications then
      for _, ply in ipairs(GetActivePlayers()) do
        if ply ~= pid() then
          local sid = GetPlayerServerId(ply)
          local dead = IsEntityDead(GetPlayerPed(ply))
          if lastKnownDeathState[sid] == nil then lastKnownDeathState[sid] = dead end
          if dead and lastKnownDeathState[sid] == false then
            notify(('%s died'):format(GetPlayerName(ply) or ('Player ' .. tostring(sid))))
          end
          lastKnownDeathState[sid] = dead
        end
      end
    end
  end
end)

CreateThread(function()
  while true do
    if state.toggles.noclip then
      local labels = { 'Very Slow', 'Slow', 'Normal', 'Fast', 'Very Fast', 'Extreme', 'Extreme+', 'Max' }
      local modeText = (noclipState.followCam == true) and 'Camera' or 'Heading'
      drawText2D(0.015, 0.79, ('NoClip: %s | Mode: %s | Shift: Cycle Speed | H: Cam Mode | %s'):format(labels[noclipState.speedIndex or 3] or 'Normal', modeText, noclipState.isVehicle and 'Vehicle' or 'Ped'), 0.33)
      Wait(0)
    else
      Wait(350)
    end
  end
end)

CreateThread(function()
  while true do
    if uiOpen or state.toggles.hideHud or state.toggles.hideRadar or state.toggles.cameraLockH or state.toggles.cameraLockV then
      if state.toggles.hideRadar then DisplayRadar(false) else DisplayRadar(true) end
      if state.toggles.hideHud then HideHudAndRadarThisFrame() end
      if state.toggles.cameraLockH then DisableControlAction(0, 1, true) end
      if state.toggles.cameraLockV then DisableControlAction(0, 2, true) end
      if uiOpen then
        DisableControlAction(0, 24, true)
        DisableControlAction(0, 25, true)
        DisableControlAction(0, 37, true)
        DisableControlAction(0, 44, true)
        DisableControlAction(0, 45, true)
        DisableControlAction(0, 140, true)
        DisableControlAction(0, 141, true)
        DisableControlAction(0, 142, true)
        DisableControlAction(0, 257, true)
        DisableControlAction(0, 263, true)
        DisableControlAction(0, 264, true)
        DisableControlAction(0, 257, true)
        DisableControlAction(0, 322, true)
      end
      Wait(0)
    else
      DisplayRadar(true)
      Wait(250)
    end
  end
end)
