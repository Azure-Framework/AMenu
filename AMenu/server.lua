local bans = {}
local bansPath = 'bans.json'
local worldState = { hour = 12, minute = 0, freezeTime = false, weather = 'CLEAR', dynamicWeather = false, blackout = false, clouds = 'default' }
local cloudPresets = { 'Cloudy 01', 'RAIN', 'ALTCLOUDS', 'Wispy', 'Puffs', 'Stormy 01', 'Clear 01', 'Snowy 01' }
local dynamicWeatherList = { 'CLEAR', 'EXTRASUNNY', 'CLOUDS', 'OVERCAST', 'RAIN', 'THUNDER', 'SMOG', 'FOGGY', 'CLEARING', 'NEUTRAL', 'XMAS', 'BLIZZARD', 'HALLOWEEN' }
local permissionsPath = 'config/permissions.cfg'
local permissionsData = { passthrough = {}, principals = {}, aces = {} }
local pmBlocks = {}
local pendingGpsRequests = {}

local function worldSyncEnabled()
  return Config and Config.World and Config.World.manageSync == true
end

local function worldControlsEnabled()
  return Config and Config.World and Config.World.allowMenuControls == true
end

local function loadBans()
  local raw = LoadResourceFile(GetCurrentResourceName(), bansPath)
  bans = raw and json.decode(raw) or {}
end

local function saveBans()
  SaveResourceFile(GetCurrentResourceName(), bansPath, json.encode(bans), -1)
end

local function getPlayerNameSafe(src)
  return GetPlayerName(src) or ('ID ' .. tostring(src))
end

local function getIdentifiers(src)
  local out = {}
  for _, identifier in ipairs(GetPlayerIdentifiers(src) or {}) do table.insert(out, identifier) end
  return out
end

local function hasAce(src, ace)
  return src == 0 or IsPlayerAceAllowed(src, ace)
end

local function broadcastWorldState(target)
  if target then
    TriggerClientEvent('amenu_ui:syncWorld', target, worldState)
  else
    TriggerClientEvent('amenu_ui:syncWorld', -1, worldState)
  end
end

local function requireWorldAce(src)
  return hasAce(src, 'AMenu.TimeOptions.Menu') or hasAce(src, 'AMenu.TimeOptions.All') or hasAce(src, 'AMenu.TimeOptions.SetTime') or hasAce(src, 'AMenu.TimeOptions.FreezeTime') or hasAce(src, 'AMenu.WeatherOptions.Menu') or hasAce(src, 'AMenu.WeatherOptions.All') or hasAce(src, 'AMenu.WeatherOptions.SetWeather') or hasAce(src, 'AMenu.WeatherOptions.Dynamic') or hasAce(src, 'AMenu.WeatherOptions.Blackout') or hasAce(src, 'AMenu.WeatherOptions.RemoveClouds') or hasAce(src, 'AMenu.WeatherOptions.RandomizeClouds') or hasAce(src, 'AMenu.Staff')
end

local function isExpired(entry)
  return entry.expiresAt and entry.expiresAt > 0 and entry.expiresAt <= os.time()
end

local function trim(value)
  value = tostring(value or '')
  return value:match('^%s*(.-)%s*$') or ''
end

local function normalizeAceMode(value)
  local mode = string.lower(trim(value))
  if mode ~= 'allow' and mode ~= 'deny' then mode = 'allow' end
  return mode
end

local function escapeQuoted(value)
  return tostring(value or ''):gsub('\\', '\\\\'):gsub('"', '\\"')
end

local function preferredIdentifier(src)
  local ids = getIdentifiers(src)
  local preferredOrder = { 'license:', 'fivem:', 'steam:', 'discord:' }
  for _, prefix in ipairs(preferredOrder) do
    for _, identifier in ipairs(ids) do
      if identifier:sub(1, #prefix) == prefix then
        return 'identifier.' .. identifier
      end
    end
  end
  if ids[1] then return 'identifier.' .. ids[1] end
  return 'player.' .. tostring(src)
end

local function normalizeGroupName(value)
  local group = trim(value)
  if group == '' then return nil, 'Group is required' end
  if group == 'everyone' then return 'builtin.everyone' end
  if group:match('^[%w_%-]+$') then return 'group.' .. group end
  return group
end

local function normalizePrincipalValue(value)
  local raw = trim(value)
  if raw == '' then return nil, 'Principal is required' end
  local playerId = raw:match('^player[:%.](%d+)$') or raw:match('^(%d+)$')
  if playerId then
    local target = tonumber(playerId)
    if target and GetPlayerName(target) then
      return preferredIdentifier(target)
    end
    return 'player.' .. tostring(target)
  end
  if raw == 'everyone' then return 'builtin.everyone' end
  if raw:match('^[%w_]+:[^%s]+$') then return 'identifier.' .. raw end
  return raw
end

local function parsePermissionsFile(content)
  local passthrough, principals, aces = {}, {}, {}
  content = tostring(content or '')
  for line in (content .. '\n'):gmatch('(.-)\r?\n') do
    local cleaned = trim(line)
    if cleaned == '' or cleaned:match('^#') or cleaned:match('^//') then
      if cleaned ~= '# AMenu UI permissions rules' then
        table.insert(passthrough, line)
      end
    else
      local subject, group = cleaned:match('^add_principal%s+([^%s]+)%s+([^%s]+)%s*$')
      if subject and group then
        table.insert(principals, { subject = subject, group = group })
      else
        local principal, ace, mode = cleaned:match('^add_ace%s+([^%s]+)%s+"([^"]+)"%s+([^%s]+)%s*$')
        if not principal then principal, ace, mode = cleaned:match("^add_ace%s+([^%s]+)%s+'([^']+)'%s+([^%s]+)%s*$") end
        if not principal then principal, ace, mode = cleaned:match('^add_ace%s+([^%s]+)%s+([^%s]+)%s+([^%s]+)%s*$') end
        if principal and ace and mode then
          table.insert(aces, { principal = principal, ace = ace, mode = normalizeAceMode(mode) })
        else
          table.insert(passthrough, line)
        end
      end
    end
  end
  table.sort(principals, function(a, b)
    local left = (a.subject or '') .. '|' .. (a.group or '')
    local right = (b.subject or '') .. '|' .. (b.group or '')
    return left < right
  end)
  table.sort(aces, function(a, b)
    local left = (a.principal or '') .. '|' .. (a.ace or '') .. '|' .. (a.mode or '')
    local right = (b.principal or '') .. '|' .. (b.ace or '') .. '|' .. (b.mode or '')
    return left < right
  end)
  return passthrough, principals, aces
end

local function loadPermissionsData()
  local raw = LoadResourceFile(GetCurrentResourceName(), permissionsPath) or ''
  local passthrough, principals, aces = parsePermissionsFile(raw)
  permissionsData = { passthrough = passthrough, principals = principals, aces = aces }
end

local function savePermissionsData()
  local lines = {}
  for _, line in ipairs(permissionsData.passthrough or {}) do
    table.insert(lines, line)
  end
  if #lines > 0 and trim(lines[#lines]) ~= '' then table.insert(lines, '') end
  table.insert(lines, '# AMenu UI permissions rules')
  for _, entry in ipairs(permissionsData.principals or {}) do
    table.insert(lines, ('add_principal %s %s'):format(entry.subject, entry.group))
  end
  for _, entry in ipairs(permissionsData.aces or {}) do
    table.insert(lines, ('add_ace %s "%s" %s'):format(entry.principal, escapeQuoted(entry.ace), normalizeAceMode(entry.mode)))
  end
  SaveResourceFile(GetCurrentResourceName(), permissionsPath, table.concat(lines, '\n'), -1)
end

local function canEditPermissions(src)
  return hasAce(src, 'AMenu.Permissions.Editor') or hasAce(src, 'AMenu.Staff')
end

local function getPermissionsSnapshot(src)
  if not canEditPermissions(src) then
    return { canEdit = false, principals = {}, aces = {}, commonGroups = { 'builtin.everyone', 'group.moderator', 'group.admin' } }
  end
  loadPermissionsData()
  return {
    canEdit = true,
    principals = permissionsData.principals or {},
    aces = permissionsData.aces or {},
    commonGroups = { 'builtin.everyone', 'group.moderator', 'group.admin' }
  }
end

local function principalIndex(subject, group)
  for index, entry in ipairs(permissionsData.principals or {}) do
    if entry.subject == subject and entry.group == group then return index end
  end
  return nil
end

local function aceIndex(principal, ace, mode)
  for index, entry in ipairs(permissionsData.aces or {}) do
    if entry.principal == principal and entry.ace == ace and normalizeAceMode(entry.mode) == normalizeAceMode(mode) then return index end
  end
  return nil
end

local function permissionsSummaryText()
  local lines = {
    ('Principals: %s'):format(#(permissionsData.principals or {})),
    ('ACE rules: %s'):format(#(permissionsData.aces or {})),
    ''
  }
  if #(permissionsData.principals or {}) > 0 then
    table.insert(lines, 'Principals')
    for _, entry in ipairs(permissionsData.principals) do
      table.insert(lines, ('- %s -> %s'):format(entry.subject, entry.group))
    end
    table.insert(lines, '')
  end
  if #(permissionsData.aces or {}) > 0 then
    table.insert(lines, 'ACE rules')
    for _, entry in ipairs(permissionsData.aces) do
      table.insert(lines, ('- %s :: %s [%s]'):format(entry.principal, entry.ace, normalizeAceMode(entry.mode)))
    end
  end
  return table.concat(lines, '\n')
end

local function addPrincipalRule(subject, group)
  if principalIndex(subject, group) then return false, 'That principal rule already exists' end
  ExecuteCommand(('add_principal %s %s'):format(subject, group))
  table.insert(permissionsData.principals, { subject = subject, group = group })
  table.sort(permissionsData.principals, function(a, b)
    return ((a.subject or '') .. '|' .. (a.group or '')) < ((b.subject or '') .. '|' .. (b.group or ''))
  end)
  savePermissionsData()
  return true, ('Added %s -> %s'):format(subject, group)
end

local function removePrincipalRule(subject, group)
  local index = principalIndex(subject, group)
  if not index then return false, 'That principal rule was not found' end
  ExecuteCommand(('remove_principal %s %s'):format(subject, group))
  table.remove(permissionsData.principals, index)
  savePermissionsData()
  return true, ('Removed %s -> %s'):format(subject, group)
end

local function addAceRule(principal, ace, mode)
  mode = normalizeAceMode(mode)
  if aceIndex(principal, ace, mode) then return false, 'That ACE rule already exists' end
  ExecuteCommand(('add_ace %s "%s" %s'):format(principal, escapeQuoted(ace), mode))
  table.insert(permissionsData.aces, { principal = principal, ace = ace, mode = mode })
  table.sort(permissionsData.aces, function(a, b)
    return ((a.principal or '') .. '|' .. (a.ace or '') .. '|' .. (a.mode or '')) < ((b.principal or '') .. '|' .. (b.ace or '') .. '|' .. (b.mode or ''))
  end)
  savePermissionsData()
  return true, ('Added %s :: %s [%s]'):format(principal, ace, mode)
end

local function removeAceRule(principal, ace, mode)
  mode = normalizeAceMode(mode)
  local index = aceIndex(principal, ace, mode)
  if not index then return false, 'That ACE rule was not found' end
  ExecuteCommand(('remove_ace %s "%s" %s'):format(principal, escapeQuoted(ace), mode))
  table.remove(permissionsData.aces, index)
  savePermissionsData()
  return true, ('Removed %s :: %s [%s]'):format(principal, ace, mode)
end

local function cleanupBans()
  local changed = false
  for i = #bans, 1, -1 do
    if isExpired(bans[i]) then table.remove(bans, i); changed = true end
  end
  if changed then saveBans() end
end

AddEventHandler('playerJoining', function()
  if not worldSyncEnabled() or not (Config and Config.World and Config.World.syncOnJoin == true) then return end
  local src = source
  local joinName = GetPlayerName(src) or ('ID ' .. tostring(src))
  TriggerClientEvent('amenu_ui:playerEvent', -1, 'joined', joinName)
  CreateThread(function()
    Wait(1500)
    broadcastWorldState(src)
  end)
end)

AddEventHandler('playerDropped', function()
  local src = source
  local leftName = GetPlayerName(src) or ('ID ' .. tostring(src))
  pmBlocks[src] = nil
  pendingGpsRequests[src] = nil
  for _, list in pairs(pmBlocks) do list[src] = nil end
  for target, list in pairs(pendingGpsRequests) do
    if list[src] then
      list[src] = nil
      TriggerClientEvent('amenu_ui:gpsRequestClosed', target, src)
    end
  end
  TriggerClientEvent('amenu_ui:playerEvent', -1, 'left', leftName)
end)

AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
  loadBans()
  cleanupBans()
  local ids = getIdentifiers(source)
  for _, entry in ipairs(bans) do
    for _, identifier in ipairs(entry.identifiers or {}) do
      for _, current in ipairs(ids) do
        if current == identifier then
          local msg = entry.reason or 'You are banned.'
          if entry.expiresAt and entry.expiresAt > 0 then msg = msg .. (' Ban expires at %s.'):format(os.date('%Y-%m-%d %H:%M:%S', entry.expiresAt)) end
          deferrals.done(msg)
          CancelEvent()
          return
        end
      end
    end
  end
end)

local QBCore = nil

local function qbConfig()
  return (Config and Config.QBCore) or {}
end

local function qbEnabled()
  return qbConfig().Enabled == true
end

local function qbLoadCore()
  if not qbEnabled() then return nil end
  if QBCore then return QBCore end
  local resource = qbConfig().CoreResource or 'qb-core'
  if GetResourceState(resource) ~= 'started' then return nil end
  local ok, core = pcall(function()
    return exports[resource]:GetCoreObject()
  end)
  if ok and core then QBCore = core end
  return QBCore
end

local function qbNotify(src, msg, msgType, length)
  TriggerClientEvent('QBCore:Notify', src, msg, msgType or 'primary', length or 5000)
end

local function frameworkBridgeResources()
  local configured = (Config and Config.QBCore and Config.QBCore.FrameworkBridgeResource) or 'AMenu-Bridge'
  local list, seen = {}, {}
  local function add(name)
    name = tostring(name or '')
    if name ~= '' and not seen[name] then
      seen[name] = true
      list[#list + 1] = name
    end
  end
  add(configured)
  add('AMenu-Bridge')
  add('az_amenu_framework_bridge')
  add('az_amenu_qbcore_bridge')
  return list
end

local function callFrameworkBridgeExport(exportName, ...)
  local args = { ... }
  local unpackFn = table.unpack or unpack

  for _, resource in ipairs(frameworkBridgeResources()) do
    if GetResourceState(resource) == 'started' then
      local ok, result, result2 = pcall(function()
        local exp = exports[resource]
        if not exp or not exp[exportName] then return nil end

        return exp[exportName](exp, unpackFn(args))
      end)
      if ok and result ~= nil then
        return true, result, result2
      elseif not ok then
        print(('[AMenu NUI FrameworkBridge] Colon export %s failed on %s: %s'):format(tostring(exportName), tostring(resource), tostring(result)))

        local ok2, resultA, resultB = pcall(function()
          local exp = exports[resource]
          if not exp or not exp[exportName] then return nil end
          return exp[exportName](unpackFn(args))
        end)
        if ok2 and resultA ~= nil then
          return true, resultA, resultB
        elseif not ok2 then
          print(('[AMenu NUI FrameworkBridge] Dot export %s failed on %s: %s'):format(tostring(exportName), tostring(resource), tostring(resultA)))
        end
      end
    end
  end
  return false, nil
end

local function frameworkDisplayLabel(value)
  local text = tostring(value or '')
  local lowerText = text:lower()
  if lowerText == 'az' or lowerText:find('az%-framework') or lowerText:find('az framework') or lowerText:find('azure') then return 'Azure Framework' end
  if lowerText == 'esx' or lowerText:find('esx') or lowerText:find('es_extended') then return 'ESX Legacy' end
  if lowerText == 'nd' or lowerText:find('nd_core') or lowerText:find('ndcore') or lowerText:find('nd%-core') then return 'NDCore' end
  if lowerText == 'qb' or lowerText:find('qbcore') or lowerText:find('qb%-core') then return 'QBCore' end
  if text ~= '' and text ~= 'nil' then return text end
  return 'Framework'
end

local function compactFrameworkAction(value)
  if type(value) == 'table' then return '' end
  return tostring(value or ''):lower():gsub('[^%w]', '')
end

local FRAMEWORK_ACTION_ALIASES = {
  info = 'info', playerinfo = 'info', qbinfo = 'info', azinfo = 'info', getinfo = 'info', details = 'info', inspect = 'info',
  revive = 'revive', qbrevive = 'revive', azrevive = 'revive', reviveplayer = 'revive',
  heal = 'heal', qbheal = 'heal', azheal = 'heal', healplayer = 'heal',
  save = 'save', qbsave = 'save', azsave = 'save', saveplayer = 'save',
  duty = 'duty', qbduty = 'duty', azduty = 'duty', setduty = 'duty', dutyon = 'duty', dutyoff = 'duty', onduty = 'duty', offduty = 'duty',
  setjob = 'setjob', qbsetjob = 'setjob', qbsetjobpreset = 'setjob', qbsetcustomjob = 'setjob', azsetjob = 'setjob', setjobpreset = 'setjob', customjob = 'setjob',
  addmoney = 'addmoney', qbaddmoney = 'addmoney', azaddmoney = 'addmoney', addcash = 'addmoney', addbank = 'addmoney', givemoney = 'addmoney', givecash = 'addmoney', givebank = 'addmoney',
  removemoney = 'removemoney', qbremovemoney = 'removemoney', azremovemoney = 'removemoney', removecash = 'removemoney', removebank = 'removemoney', takemoney = 'removemoney', takecash = 'removemoney', takebank = 'removemoney', deductcash = 'removemoney', deductbank = 'removemoney',
  keys = 'keys', qbkeys = 'keys', azkeys = 'keys', givekeys = 'keys', qbgiveplatekeys = 'keys', qbgivecurrentkeys = 'keys', giveplatekeys = 'keys', givecurrentkeys = 'keys',
  kick = 'kick', qbkick = 'kick', azkick = 'kick', kickplayer = 'kick'
}

local function actionFromFrameworkText(value)
  if type(value) ~= 'string' and type(value) ~= 'number' then return nil end
  local text = tostring(value or ''):match('^%s*(.-)%s*$') or ''
  if text == '' then return nil end
  local low = text:lower()
  if low:find('^table:') or low:find('^function:') or low:find('^userdata:') then return nil end
  local key = compactFrameworkAction(text)
  if key == '' or key == 'action' or key == 'prompt' or key == 'submenu' then return nil end
  if FRAMEWORK_ACTION_ALIASES[key] then return FRAMEWORK_ACTION_ALIASES[key] end
  if key:find('playerinfo') then return 'info' end
  if key:find('revive') then return 'revive' end
  if key:find('heal') then return 'heal' end
  if key:find('save') then return 'save' end
  if key:find('kick') then return 'kick' end
  if key:find('setjob') or key:find('jobpreset') then return 'setjob' end
  if key:find('addcash') or key:find('addbank') or key:find('addmoney') or key:find('givecash') or key:find('givebank') then return 'addmoney' end
  if key:find('removecash') or key:find('removebank') or key:find('removemoney') or key:find('takecash') or key:find('takebank') or key:find('deduct') then return 'removemoney' end
  if key:find('dutyon') or key:find('dutyoff') or key:find('onduty') or key:find('offduty') or key == 'setduty' then return 'duty' end
  if key:find('key') and (key:find('give') or key:find('plate') or key:find('current')) then return 'keys' end
  return nil
end

local function actionFromFrameworkAny(value, seen)
  if type(value) ~= 'table' then return actionFromFrameworkText(value) end
  seen = seen or {}
  if seen[value] then return nil end
  seen[value] = true
  for _, key in ipairs({ 'action', 'Action', 'actionName', 'ActionName', 'action_name', 'frameworkAction', 'FrameworkAction', 'framework_action', 'event', 'Event', 'command', 'Command', 'cmd', 'Cmd', 'id', 'Id', 'key', 'Key', 'name', 'Name', 'label', 'Label', 'title', 'Title', 'text', 'Text', 'description', 'Description', 1 }) do
    local found = actionFromFrameworkAny(value[key], seen)
    if found then return found end
  end
  local val = value.value
  if value.job or value.jobName or (type(val) == 'table' and (val.job or val.jobName)) then return 'setjob' end
  if value.plate or (type(val) == 'table' and val.plate) then return 'keys' end
  if value.amount or (type(val) == 'table' and val.amount) then
    local labelAction = actionFromFrameworkText(value.label or value.title or value.name or value.description or '')
    if labelAction == 'removemoney' then return 'removemoney' end
    return 'addmoney'
  end
  for _, nested in pairs(value) do
    if type(nested) == 'table' then
      local found = actionFromFrameworkAny(nested, seen)
      if found then return found end
    end
  end
  return nil
end

local function sourceFromFrameworkValue(value, seen)
  if type(value) == 'number' then
    return value > 0 and value or 0
  end
  if type(value) == 'string' then
    local text = tostring(value or '')
    local low = text:lower()
    if low:find('^table:') or low:find('^function:') or low:find('^userdata:') then return 0 end
    local direct = tonumber(text)
    if direct and direct > 0 then return direct end
    local bracketed = text:match('%[(%d+)%]')
    if bracketed then return tonumber(bracketed) or 0 end
    if low:find('set job') or low:find('grade') or low:find('cash') or low:find('bank') or low:find('money') then return 0 end
    local first = text:match('(%d+)')
    return tonumber(first or 0) or 0
  end
  if type(value) == 'table' then
    seen = seen or {}
    if seen[value] then return 0 end
    seen[value] = true
    for _, key in ipairs({ 'target', 'Target', 'targetId', 'TargetId', 'targetID', 'TargetID', 'source', 'Source', 'src', 'Src', 'id', 'Id', 'serverId', 'ServerId', 'serverID', 'ServerID', 'playerId', 'PlayerId', 'playerID', 'PlayerID', 'context', 'Context', 'player', 'Player' }) do
      local found = sourceFromFrameworkValue(value[key], seen)
      if found > 0 then return found end
    end
    for _, v in pairs(value) do
      local found = sourceFromFrameworkValue(v, seen)
      if found > 0 then return found end
    end
  end
  return 0
end

local function mapFrameworkActionName(value, fallback)
  local action = actionFromFrameworkAny(value) or actionFromFrameworkAny(fallback)
  if action then return action end
  local key = compactFrameworkAction(value)
  if key == '' or key == 'table' then key = compactFrameworkAction(fallback) end
  return FRAMEWORK_ACTION_ALIASES[key] or tostring(value or fallback or ''):lower()
end

local function arrayAppend(out, value)
  if value ~= nil then out[#out + 1] = value end
end

local function inferFrameworkActionFromLooseArgs(args, payload)
  local explicit = actionFromFrameworkAny(payload)
  if explicit then return explicit end

  local flat = {}
  local seen = {}
  local function absorb(value)
    if value == nil then return end
    if type(value) == 'table' then
      if seen[value] then return end
      seen[value] = true
      if value.job or value.jobName or value.job_name or (type(value.value) == 'table' and (value.value.job or value.value.jobName or value.value.job_name)) then flat.__setjob = true end
      if value.plate or (type(value.value) == 'table' and value.value.plate) then flat.__keys = true end
      if value.amount or (type(value.value) == 'table' and value.value.amount) then flat.__money = true end
      for i = 1, #value do absorb(value[i]) end
      for _, key in ipairs({ 'account', 'moneyType', 'type', 'amount', 'job', 'jobName', 'grade', 'rank', 'plate', 'duty', 'value', 'values', 'args', 'extra' }) do absorb(value[key]) end
      return
    end
    flat[#flat + 1] = value
  end
  absorb(args)
  absorb(payload)

  if flat.__setjob then return 'setjob' end
  if flat.__keys then return 'keys' end
  if flat.__money then return 'addmoney' end

  local first = tostring(flat[1] or ''):lower():gsub('^%s+', ''):gsub('%s+$', '')
  local second = flat[2]
  if first == 'cash' or first == 'bank' or first == 'money' then return 'addmoney' end
  if tonumber(first) and not second then return 'addmoney' end
  if first == 'true' or first == 'false' or first == 'on' or first == 'off' or first == 'yes' or first == 'no' then return 'duty' end
  if first ~= '' and tonumber(second) and not FRAMEWORK_ACTION_ALIASES[compactFrameworkAction(first)] then return 'setjob' end
  return nil
end

local function normalizeFrameworkActionArgs(actionName, args, payload)
  local out = {}

  local function absorb(value, seen)
    if value == nil then return end
    if type(value) == 'table' then
      seen = seen or {}
      if seen[value] then return end
      seen[value] = true
      local account = value.account or value.moneyType or value.type
      local amount = value.amount
      if amount == nil and type(value.value) ~= 'table' then amount = value.value end
      local job = value.job or value.jobName
      local grade = value.grade or value.rank
      local plate = value.plate
      local reason = value.reason
      arrayAppend(out, account)
      arrayAppend(out, amount)
      arrayAppend(out, job)
      arrayAppend(out, grade)
      arrayAppend(out, plate)
      arrayAppend(out, reason)
      if type(value.value) == 'table' then absorb(value.value, seen) end
      if type(value.values) == 'table' then absorb(value.values, seen) end
      if type(value.args) == 'table' then absorb(value.args, seen) end
      if type(value.extra) == 'table' then absorb(value.extra, seen) end
      for i = 1, #value do arrayAppend(out, value[i]) end
    else
      arrayAppend(out, value)
    end
  end

  absorb(args)
  if #out == 0 and type(payload) == 'table' then
    absorb(payload.value)
    absorb(payload.values)
    absorb(payload.extra)
    absorb(payload.args)
  end

  actionName = mapFrameworkActionName(actionName, payload)
  if actionName == 'setjob' then
    local job, grade
    for _, v in ipairs(out) do
      if type(v) == 'table' then
        job = job or v.job or v.jobName
        grade = grade or v.grade or v.rank
      elseif job == nil and tostring(v or '') ~= '' and not tonumber(v) and not FRAMEWORK_ACTION_ALIASES[compactFrameworkAction(v)] then
        job = v
      elseif grade == nil and tonumber(v) then
        grade = v
      end
    end
    if type(payload) == 'table' then
      job = job or payload.job or payload.jobName or (type(payload.value) == 'table' and (payload.value.job or payload.value.jobName))
      grade = grade or payload.grade or payload.rank or (type(payload.value) == 'table' and (payload.value.grade or payload.value.rank))
    end
    return { tostring(job or 'unemployed'), tostring(grade or 0) }
  elseif actionName == 'addmoney' or actionName == 'removemoney' then
    local account, amount
    for _, v in ipairs(out) do
      if type(v) == 'table' then
        account = account or v.account or v.moneyType or v.type
        amount = amount or v.amount or v.value
      elseif tonumber(v) and amount == nil then
        amount = v
      elseif account == nil and tostring(v or '') ~= '' and not FRAMEWORK_ACTION_ALIASES[compactFrameworkAction(v)] then
        account = v
      end
    end
    if type(payload) == 'table' then
      account = account or payload.account or payload.moneyType or payload.type or (type(payload.value) == 'table' and (payload.value.account or payload.value.moneyType or payload.value.type))
      amount = amount or payload.amount or (type(payload.value) == 'table' and payload.value.amount)
    end
    return { tostring(account or 'cash'), tostring(amount or 0) }
  elseif actionName == 'duty' then
    if #out == 0 and compactFrameworkAction(actionName):find('off') then return { 'false' } end
    if #out == 0 then return { 'true' } end
  elseif actionName == 'keys' then
    local plate = nil
    for _, v in ipairs(out) do
      if type(v) == 'table' then plate = plate or v.plate elseif tostring(v or '') ~= '' and not FRAMEWORK_ACTION_ALIASES[compactFrameworkAction(v)] then plate = plate or v end
    end
    if type(payload) == 'table' then plate = plate or payload.plate or (type(payload.value) == 'table' and payload.value.plate) end
    return { tostring(plate or '') }
  end

  return out
end

local function normalizeFrameworkActionPayload(actionName, target, args)
  local payload = nil
  if type(actionName) == 'table' then
    payload = actionName
    actionName = actionFromFrameworkAny(payload) or payload.action or payload.Action or payload.actionName or payload.ActionName or payload.frameworkAction or payload.FrameworkAction or payload.name or payload.Name or payload.type or payload.Type or payload.label or payload.Label or payload[1]
    target = target or payload.target or payload.Target or payload.targetId or payload.TargetId or payload.targetID or payload.TargetID or payload.source or payload.Source or payload.src or payload.Src or payload.player or payload.Player or payload.playerId or payload.PlayerId or payload.context or payload.Context
    args = args or payload.args or payload.Args or payload.values or payload.Values or payload.value or payload.Value or payload.extra or payload.Extra
  end

  if type(actionName) == 'table' then
    local nested = actionName
    actionName = actionFromFrameworkAny(nested) or nested.action or nested.Action or nested.actionName or nested.ActionName or nested.frameworkAction or nested.FrameworkAction or nested.name or nested.Name or nested.type or nested.Type or nested.label or nested.Label or nested[1]
    target = target or nested.target or nested.Target or nested.targetId or nested.TargetId or nested.targetID or nested.TargetID or nested.source or nested.Source or nested.src or nested.Src or nested.player or nested.Player or nested.playerId or nested.PlayerId or nested.context or nested.Context
    args = args or nested.args or nested.Args or nested.values or nested.Values or nested.value or nested.Value or nested.extra or nested.Extra
    payload = nested
  end

  local mapped = mapFrameworkActionName(actionName, payload)
  if mapped == '' or mapped == 'nil' or mapped:find('^table:') then
    mapped = inferFrameworkActionFromLooseArgs(args, payload) or mapped
  end
  local resolvedTarget = sourceFromFrameworkValue(target)
  if resolvedTarget <= 0 and type(payload) == 'table' then
    resolvedTarget = sourceFromFrameworkValue(payload.context or payload.player or payload)
  end

  return mapped, resolvedTarget, normalizeFrameworkActionArgs(mapped, args, payload)
end

local function qbGetPlayer(src)
  local core = qbLoadCore()
  if not core then return nil end
  local srcNum = tonumber(src)
  if srcNum and core.Functions and core.Functions.GetPlayer then
    local direct = core.Functions.GetPlayer(srcNum)
    if direct then return direct end
    direct = core.Functions.GetPlayer(tostring(srcNum))
    if direct then return direct end
  end
  local players = nil
  if core.Functions and core.Functions.GetQBPlayers then
    players = core.Functions.GetQBPlayers()
  elseif core.Players then
    players = core.Players
  end
  if players and srcNum then
    for key, Player in pairs(players) do
      local pdata = Player and Player.PlayerData or {}
      local pdataSource = tonumber(pdata.source or pdata.src or Player.source or key)
      if pdataSource == srcNum then return Player end
    end
  end
  return nil
end

local function qbGetPlayers()
  local core = qbLoadCore()
  if not core then return {} end
  if core.Functions and core.Functions.GetQBPlayers then
    return core.Functions.GetQBPlayers() or {}
  end
  return core.Players or {}
end

local function qbHasAdmin(src)
  if src == 0 then return true end
  local cfg = qbConfig()
  if IsPlayerAceAllowed(src, cfg.AdminAce or 'AMenu.QBCore.Admin') then return true end
  if IsPlayerAceAllowed(src, 'AMenu.QBCore.Menu') then return true end
  if IsPlayerAceAllowed(src, 'AMenu.QBCore.All') then return true end
  if IsPlayerAceAllowed(src, 'AMenu.Staff') then return true end
  local core = qbLoadCore()
  if core and core.Functions and core.Functions.HasPermission then
    for _, perm in ipairs(cfg.AdminQBPermissions or {}) do
      local ok, hasPerm = pcall(core.Functions.HasPermission, src, perm)
      if ok and hasPerm then return true end
    end
  end
  return false
end

local function qbGetJobData(Player)
  if not Player or not Player.PlayerData then return nil, nil end
  local job = Player.PlayerData.job or {}
  local jobName = tostring(job.name or ''):lower()
  return jobName, job
end

local function qbIsServiceJob(Player)
  local cfg = qbConfig()
  local jobName, job = qbGetJobData(Player)
  if not jobName or jobName == '' then return false, 'none' end
  local rule = (cfg.AllowedJobs or {})[jobName]
  if not rule then return false, jobName end
  local requireDuty = rule.requireDuty
  if requireDuty == nil then requireDuty = cfg.RequireOnDuty end
  if requireDuty and job.onduty ~= true then return false, jobName, 'offduty' end
  return true, jobName
end

local function qbCanUseVehicleSpawner(src)
  local cfg = qbConfig()
  if not qbEnabled() then return true, 'disabled' end
  if qbHasAdmin(src) then return true, 'admin' end
  if cfg.RestrictVehicleSpawner == false then return true, 'open' end
  local Player = qbGetPlayer(src)
  if not Player then return false, 'player_not_loaded' end
  local allowed, jobName, reason = qbIsServiceJob(Player)
  if allowed then return true, jobName end
  return false, reason or jobName or 'job_not_allowed'
end

local function qbGetSpawnCost(src, Player, vehicleClass)
  local cfg = qbConfig()
  if qbHasAdmin(src) then return 0 end
  local costs = cfg.SpawnCosts or {}
  local classId = tonumber(vehicleClass) or -1
  local base = tonumber(costs.Default or 0) or 0
  if costs.Classes and costs.Classes[classId] ~= nil then base = tonumber(costs.Classes[classId]) or base end
  local jobName = select(1, qbGetJobData(Player))
  local multiplier = 1.0
  if jobName and costs.JobMultipliers and costs.JobMultipliers[jobName] ~= nil then
    multiplier = tonumber(costs.JobMultipliers[jobName]) or 1.0
  end
  return math.max(0, math.floor(base * multiplier))
end

local function qbRemoveMoney(Player, amount, reason)
  local cfg = qbConfig()
  amount = tonumber(amount) or 0
  if amount <= 0 then return true, 'free' end
  local balances = (Player.PlayerData and Player.PlayerData.money) or {}
  for _, account in ipairs(cfg.MoneyAccountOrder or { 'bank', 'cash' }) do
    local balance = tonumber(balances[account] or 0) or 0
    if balance >= amount then
      local ok = Player.Functions.RemoveMoney(account, amount, reason)
      return ok == true, account
    end
  end
  if cfg.SplitPayment then
    local bank = tonumber(balances.bank or 0) or 0
    local cash = tonumber(balances.cash or 0) or 0
    if bank + cash >= amount then
      local remaining = amount
      if bank > 0 then
        local bankTake = math.min(bank, remaining)
        if bankTake > 0 and not Player.Functions.RemoveMoney('bank', bankTake, reason) then return false, 'bank_failed' end
        remaining = remaining - bankTake
      end
      if remaining > 0 and not Player.Functions.RemoveMoney('cash', remaining, reason) then return false, 'cash_failed' end
      return true, 'split'
    end
  end
  return false, 'insufficient'
end

local function qbAudit(title, fields)
  local audit = qbConfig().Audit or {}
  if not audit.Enabled then return end
  if audit.PrintToConsole then
    local parts = {}
    for k, v in pairs(fields or {}) do parts[#parts + 1] = ('%s=%s'):format(k, tostring(v)) end
    print(('[AMenu NUI QBCore] %s | %s'):format(title, table.concat(parts, ' | ')))
  end
  if audit.Webhook and audit.Webhook ~= '' then
    PerformHttpRequest(audit.Webhook, function() end, 'POST', json.encode({
      username = 'AMenu NUI QBCore',
      embeds = {{
        title = title,
        color = 16766720,
        fields = (function()
          local out = {}
          for k, v in pairs(fields or {}) do out[#out + 1] = { name = tostring(k), value = tostring(v), inline = true } end
          return out
        end)(),
        footer = { text = os.date('%Y-%m-%d %H:%M:%S') }
      }}
    }), { ['Content-Type'] = 'application/json' })
  end
end

local function qbPlayersForMenu()
  local list = {}
  for key, Player in pairs(qbGetPlayers()) do
    local pdata = Player and Player.PlayerData or {}
    local src = tonumber(pdata.source or pdata.src or Player.source or key)
    if src and GetPlayerName(src) then
      local job = pdata.job or {}
      local grade = job.grade or {}
      local money = pdata.money or {}
      list[#list + 1] = {
        source = src,
        name = GetPlayerName(src) or pdata.name or ('Player ' .. src),
        citizenid = pdata.citizenid or 'unknown',
        job = job.name or 'unemployed',
        jobLabel = job.label or job.name or 'Unemployed',
        grade = tostring(grade.level or grade.name or 0),
        onduty = job.onduty == true,
        cash = tonumber(money.cash or 0) or 0,
        bank = tonumber(money.bank or 0) or 0
      }
    end
  end
  table.sort(list, function(a, b) return (a.source or 0) < (b.source or 0) end)
  return list
end

local function qbStateForMenu(src)
  local bridgeOk, bridgeState = callFrameworkBridgeExport('GetStateForMenu', src)
  if bridgeOk and type(bridgeState) == 'table' then
    bridgeState.frameworkLabel = frameworkDisplayLabel(bridgeState.frameworkLabel or bridgeState.label or bridgeState.frameworkName or bridgeState.framework)
    bridgeState.label = bridgeState.frameworkLabel
    return bridgeState
  end

  local core = qbLoadCore()
  local canSpawn, spawnReason = qbCanUseVehicleSpawner(src)
  return {
    enabled = qbEnabled(),
    coreStarted = core ~= nil,
    framework = 'qb',
    frameworkName = 'qb',
    frameworkLabel = 'QBCore',
    label = 'QBCore',
    resource = qbConfig().CoreResource or 'qb-core',
    canAccessMenu = qbHasAdmin(src),
    canUseVehicleSpawner = canSpawn == true,
    vehicleSpawnerReason = spawnReason or '',
    source = src,
    players = qbHasAdmin(src) and qbPlayersForMenu() or {}
  }
end

local function azExport(exportName, ...)
  if GetResourceState('Az-Framework') ~= 'started' then
    return false, nil, 'Az-Framework not started'
  end

  local okExports, fw = pcall(function() return exports['Az-Framework'] end)
  if not okExports or not fw then return false, nil, 'Az-Framework exports unavailable' end

  local okFn, fn = pcall(function() return fw[exportName] end)
  if not okFn or type(fn) ~= 'function' then return false, nil, ('Missing Az-Framework export: %s'):format(tostring(exportName)) end

  local ok, a, b, c = pcall(fn, ...)
  if ok then return true, a, b, c end

  ok, a, b, c = pcall(fn, fw, ...)
  if ok then return true, a, b, c end

  return false, nil, tostring(a or 'Az-Framework export call failed')
end

local function azFirstExport(names, ...)
  for _, name in ipairs(names or {}) do
    local ok, result, extra, err = azExport(name, ...)
    if ok then return true, result, extra, name end
    if Config and Config.Debug then
      print(('[AMenu Az Direct] export failed %s: %s'):format(tostring(name), tostring(err)))
    end
  end
  return false, nil, nil, 'no_export_succeeded'
end

local function azNotifyDirect(src, message, msgType, length)
  local ok, result = azExport('BridgeNotify', src, tostring(message or ''), msgType or 'inform', length or 5000)
  if ok and result ~= false then return end
  TriggerClientEvent('ox_lib:notify', src, {
    title = 'AMenu Bridge',
    description = tostring(message or ''),
    type = msgType or 'inform',
    duration = tonumber(length) or 5000
  })
end

local AZ_JOB_ACTION_VALUES = {
  police = true, sheriff = true, state = true, ems = true, ambulance = true, fire = true,
  leo = true, lspd = true, bcso = true, sasp = true, sahp = true, trooper = true,
  ranger = true, park = true, parks = true, civ = true, civilian = true, unemployed = true,
  offduty = true, offdutycivilian = true
}

local AZ_MONEY_ACCOUNT_VALUES = { cash = true, money = true, bank = true }

local function azCompact(value)
  return tostring(value or ''):lower():gsub('[^%w]', '')
end

local function azIsJobActionValue(value)
  return AZ_JOB_ACTION_VALUES[azCompact(value)] == true
end

local function azIsMoneyAccountValue(value)
  return AZ_MONEY_ACCOUNT_VALUES[azCompact(value)] == true
end

local function azNormalizeAction(actionName)
  local action = azCompact(actionName)
  if action == '' or action == 'nil' then return '' end
  if action == 'qbinfo' or action == 'azinfo' or action == 'playerinfo' or action == 'info' then return 'info' end
  if action == 'qbsetjobpreset' or action == 'qbsetcustomjob' or action == 'azsetjobpreset' or action == 'azsetcustomjob' or action == 'setjobpreset' or action == 'setjob' then return 'setjob' end
  if azIsJobActionValue(action) then return 'setjob' end
  if action == 'qbaddmoney' or action == 'azaddmoney' or action == 'addcash' or action == 'addbank' or action == 'addmoney' then return 'addmoney' end
  if azIsMoneyAccountValue(action) then return 'addmoney' end
  if action == 'qbremovemoney' or action == 'azremovemoney' or action == 'removecash' or action == 'removebank' or action == 'takemoney' or action == 'removemoney' then return 'removemoney' end
  if action == 'qbrevive' or action == 'azrevive' or action == 'reviveplayer' or action == 'revive' then return 'revive' end
  if action == 'qbheal' or action == 'azheal' or action == 'healplayer' or action == 'heal' then return 'heal' end
  if action == 'qbsave' or action == 'azsave' or action == 'saveplayer' or action == 'save' then return 'save' end
  if action == 'qbduty' or action == 'azduty' or action == 'dutyon' or action == 'dutyoff' or action == 'setduty' or action == 'duty' then return 'duty' end
  if action == 'qbkick' or action == 'azkick' or action == 'kickplayer' or action == 'kick' then return 'kick' end
  if action == 'qbkeys' or action == 'azkeys' or action == 'givekeys' or action == 'qbgiveplatekeys' or action == 'qbgivecurrentkeys' or action == 'keys' then return 'keys' end
  return action
end

local function azPayloadTable(value)
  return type(value) == 'table' and value or {}
end

local function azTargetFrom(value, fallback)
  if type(value) == 'number' then return value > 0 and value or 0 end
  if type(value) == 'string' then
    local direct = tonumber(value)
    if direct and direct > 0 then return direct end
    local bracketed = value:match('%[(%d+)%]')
    if bracketed then return tonumber(bracketed) or 0 end
    return 0
  end
  if type(value) == 'table' then
    for _, key in ipairs({ 'target', 'targetId', 'source', 'src', 'serverId', 'playerId', 'id' }) do
      local found = azTargetFrom(value[key])
      if found > 0 then return found end
    end
    if type(value.context) == 'table' then
      local found = azTargetFrom(value.context)
      if found > 0 then return found end
    end
  end
  return tonumber(fallback or 0) or 0
end

local function azDirectPlayerAction(staffSrc, payload)
  payload = azPayloadTable(payload)
  local args = type(payload.args) == 'table' and payload.args or type(payload.values) == 'table' and payload.values or {}
  local value = azPayloadTable(payload.value)
  local context = azPayloadTable(payload.context)

  local rawActionText = tostring(payload.action or payload.actionName or payload.frameworkAction or payload.framework_action or '')
  local rawActionKey = azCompact(rawActionText)
  local action = azNormalizeAction(rawActionText)
  if action == 'setjob' and azIsJobActionValue(rawActionKey) then
    value.job = rawActionKey
    if #args == 0 then args = { rawActionKey, '0' } end
  elseif action == 'addmoney' and azIsMoneyAccountValue(rawActionKey) then
    value.account = rawActionKey == 'money' and 'cash' or rawActionKey
    if #args == 0 then args = { value.account, '1000' } end
  end
  if action == '' then
    if value.job or value.jobName then action = 'setjob'
    elseif value.amount then action = 'addmoney'
    elseif value.plate then action = 'keys' end
  end

  local target = azTargetFrom(payload.target or payload.targetId or payload.source or payload.src or context, staffSrc)
  if target <= 0 then target = tonumber(staffSrc or 0) or 0 end
  if target <= 0 or not GetPlayerName(target) then return { ok = false, message = 'Az target player not found.' } end

  if staffSrc ~= 0 and not qbHasAdmin(staffSrc) then
    return { ok = false, message = 'No Azure Framework management permission.' }
  end

  do
    local bridgeArgs = args

    if action == 'setjob' then
      bridgeArgs = {
        tostring(value.job or value.jobName or payload.job or payload.jobName or args[1] or (azIsJobActionValue(rawActionKey) and rawActionKey) or 'unemployed'),
        tostring(value.grade or value.rank or payload.grade or payload.rank or args[2] or 0)
      }
    elseif action == 'addmoney' or action == 'removemoney' then
      bridgeArgs = {
        tostring(value.account or value.moneyType or payload.account or payload.moneyType or args[1] or (azIsMoneyAccountValue(rawActionKey) and rawActionKey) or 'cash'),
        tostring(value.amount or payload.amount or args[2] or 1000)
      }
    elseif action == 'duty' then
      bridgeArgs = { tostring(value.duty or payload.duty or args[1] or 'true') }
    elseif action == 'kick' then
      bridgeArgs = { tostring(value.reason or payload.reason or args[1] or 'Kicked by staff.') }
    elseif action == 'keys' then
      bridgeArgs = { tostring(value.plate or payload.plate or args[1] or '') }
    end

    print(('[AMenu AZ] Sending direct bridge action staff=%s action=%s target=%s args=%s'):format(
      tostring(staffSrc), tostring(action), tostring(target), json.encode(bridgeArgs or {})
    ))

    local bridgeOk, bridgeResult = callFrameworkBridgeExport('RunPlayerAction', staffSrc, action, target, bridgeArgs)
    if bridgeOk and type(bridgeResult) == 'table' then
      return bridgeResult
    end

    print(('[AMenu AZ] Direct bridge export failed or returned nil for action=%s target=%s'):format(tostring(action), tostring(target)))
  end

  if action == 'info' then
    local ok, snap = azExport('GetBridgePlayerSnapshot', target)
    if not ok or type(snap) ~= 'table' then
      local _, charId = azExport('GetPlayerCharacter', target)
      local _, job = azExport('getPlayerJob', target)
      local _, money = azExport('GetPlayerMoney', target)
      snap = { source = target, name = GetPlayerName(target), charid = charId, job = job, money = type(money) == 'table' and money or {} }
    end
    local money = snap.money or {}
    local msg = ('%s | Char: %s | Job: %s | Bank: $%s | Cash: $%s'):format(
      snap.name or GetPlayerName(target) or ('Player ' .. tostring(target)),
      snap.charid or snap.citizenid or 'unknown',
      (type(snap.jobInfo) == 'table' and snap.jobInfo.name) or snap.job or 'unemployed',
      money.bank or snap.bank or 0,
      money.cash or snap.cash or 0
    )
    return { ok = true, message = 'Azure player info opened.', title = 'Azure Player Info', displayText = msg }
  end

  if action == 'setjob' then
    local jobName = tostring(value.job or value.jobName or args[1] or payload.job or payload.jobName or (azIsJobActionValue(rawActionKey) and rawActionKey) or ''):lower()
    if jobName == '' then return { ok = false, message = 'Missing Az job name.' } end
    local ok, result = azFirstExport({ 'setPlayerJob', 'SetPlayerJob' }, target, jobName)
    if ok and result == true then
      TriggerClientEvent('hud:setDepartment', target, jobName)
      TriggerEvent('AMenu:QBCore:RefreshPermissions', target)
      return { ok = true, message = ('Az job set to %s.'):format(jobName) }
    end
    return { ok = false, message = 'Az set job export failed.' }
  end

  if action == 'addmoney' or action == 'removemoney' then
    local account = tostring(value.account or value.moneyType or args[1] or payload.account or (azIsMoneyAccountValue(rawActionKey) and rawActionKey) or 'cash'):lower()
    local amount = tonumber(value.amount or args[2] or payload.amount or 0) or 0
    if account ~= 'cash' and account ~= 'bank' and account ~= 'money' then
      local asAmount = tonumber(account)
      if asAmount and amount <= 0 then amount = asAmount end
      account = 'cash'
    end
    if account == 'money' then account = 'cash' end
    if amount <= 0 then return { ok = false, message = 'Invalid Az money amount.' } end

    local ok, result
    if action == 'addmoney' then
      ok, result = azFirstExport({ 'AddBridgeMoney', 'addBridgeMoney' }, target, account, amount)
      if (not ok or result ~= true) and account == 'cash' then
        ok, result = azFirstExport({ 'AddMoney', 'addMoney' }, target, amount)
      end
    else
      ok, result = azFirstExport({ 'RemoveBridgeMoney', 'removeBridgeMoney' }, target, account, amount)
      if (not ok or result ~= true) and account == 'cash' then
        ok, result = azFirstExport({ 'DeductMoney', 'deductMoney' }, target, amount)
      end
    end

    if ok and result == true then
      azExport('sendMoneyToClient', target)
      return { ok = true, message = 'Az money updated.' }
    end
    return { ok = false, message = 'Az money export failed.' }
  end

  if action == 'revive' then
    TriggerClientEvent('amenu_ui:qbPlayerAction', target, 'revive')
    TriggerClientEvent('az-amenu-qb:client:playerAction', target, 'revive')
    return { ok = true, message = 'Az revive sent.' }
  end

  if action == 'heal' then
    TriggerClientEvent('amenu_ui:qbPlayerAction', target, 'heal')
    TriggerClientEvent('az-amenu-qb:client:playerAction', target, 'heal')
    return { ok = true, message = 'Az heal sent.' }
  end

  if action == 'save' then
    azExport('sendMoneyToClient', target)
    return { ok = true, message = 'Az player refreshed/saved.' }
  end

  if action == 'duty' then
    return { ok = true, message = 'Az duty accepted. Az uses active department, not framework duty.' }
  end

  if action == 'kick' then
    local reason = tostring(value.reason or args[1] or payload.reason or 'Kicked by staff.')
    if reason == '' then reason = 'Kicked by staff.' end
    DropPlayer(target, reason)
    return { ok = true, message = 'Player kicked.' }
  end

  if action == 'keys' then
    local plate = tostring(value.plate or args[1] or payload.plate or ''):gsub('^%s+', ''):gsub('%s+$', '')
    local bridgeOk, bridgeResult = callFrameworkBridgeExport('GiveKeys', target, plate, 0, 0)
    if bridgeOk and bridgeResult == true then return { ok = true, message = 'Keys sent through bridge.' } end
    return { ok = true, message = 'No Az key export configured; plate accepted.' }
  end

  return { ok = false, message = ('Unknown Az action: %s.'):format(tostring(action)) }
end

local function qbExecutePlayerAction(src, actionName, target, args)
  actionName, target, args = normalizeFrameworkActionPayload(actionName, target, args)
  target = tonumber(target) or 0
  args = args or {}

  local bridgeOk, bridgeResult = callFrameworkBridgeExport('RunPlayerAction', src, actionName, target, args)
  if bridgeOk and type(bridgeResult) == 'table' then
    return bridgeResult
  end

  if src ~= 0 and not qbHasAdmin(src) then return { ok = false, message = 'No framework management permission' } end
  local Target = qbGetPlayer(target)
  if not Target then return { ok = false, message = ('Target not found/loaded in framework: %s'):format(tostring(target)) } end

  if actionName == 'info' then
    local money = Target.PlayerData.money or {}
    local job = Target.PlayerData.job or {}
    local msg = ('%s | CID: %s | Job: %s %s | Bank: $%s | Cash: $%s'):format(
      GetPlayerName(target) or target,
      Target.PlayerData.citizenid or 'unknown',
      job.name or 'none',
      job.grade and (job.grade.level or job.grade.name or '') or '',
      money.bank or 0,
      money.cash or 0
    )
    return { ok = true, message = 'Framework player info opened', title = 'Framework Player Info', displayText = msg }
  elseif actionName == 'setjob' then
    local jobName = tostring(args[1] or '')
    local grade = tonumber(args[2] or 0) or 0
    if jobName == '' then return { ok = false, message = 'Missing job name' } end
    local ok = Target.Functions.SetJob(jobName, grade)
    return { ok = ok == true, message = ok and 'Job updated' or 'Failed to set job' }
  elseif actionName == 'addmoney' or actionName == 'removemoney' then
    local account = tostring(args[1] or 'cash')
    local amount = tonumber(args[2] or 0) or 0
    if amount <= 0 then return { ok = false, message = 'Invalid amount' } end
    local ok
    if actionName == 'addmoney' then ok = Target.Functions.AddMoney(account, amount, 'AMenu NUI framework management')
    else ok = Target.Functions.RemoveMoney(account, amount, 'AMenu NUI framework management') end
    return { ok = ok == true, message = ok and 'Money updated' or 'Money update failed' }
  elseif actionName == 'revive' then
    TriggerClientEvent('amenu_ui:qbPlayerAction', target, 'revive')
    return { ok = true, message = 'Revive sent' }
  elseif actionName == 'heal' then
    TriggerClientEvent('amenu_ui:qbPlayerAction', target, 'heal')
    return { ok = true, message = 'Heal sent' }
  elseif actionName == 'duty' then
    local duty = tostring(args[1] or ''):lower()
    local dutyValue = duty == 'true' or duty == '1' or duty == 'yes' or duty == 'on'
    Target.Functions.SetJobDuty(dutyValue)
    return { ok = true, message = dutyValue and 'Duty enabled' or 'Duty disabled' }
  elseif actionName == 'save' then
    Target.Functions.Save()
    return { ok = true, message = 'Player saved' }
  elseif actionName == 'kick' then
    local reason = tostring(args[1] or 'Kicked by staff.')
    if reason == '' then reason = 'Kicked by staff.' end
    DropPlayer(target, reason)
    return { ok = true, message = 'Player kicked' }
  elseif actionName == 'keys' then
    local plate = tostring(args[1] or ''):gsub('^%s+', ''):gsub('%s+$', '')
    if plate == '' then return { ok = false, message = 'Missing plate' } end
    local keys = qbConfig().Keys or {}
    if keys.ClientSetOwnerEvent and keys.ClientSetOwnerEvent ~= '' then
      TriggerClientEvent(keys.ClientSetOwnerEvent, target, plate)
    end
    if keys.UseServerAcquireEvent and keys.ServerAcquireEvent and keys.ServerAcquireEvent ~= '' then
      TriggerClientEvent('amenu_ui:qbForceServerAcquire', target, plate)
    end
    return { ok = true, message = ('Keys sent for %s'):format(plate) }
  end

  return { ok = false, message = 'Unknown QBCore action' }
end

local function splitCommandArgs(args)
  local out = {}
  for token in tostring(args or ''):gmatch('%S+') do table.insert(out, token) end
  return out
end

local function sourceHasLawJob(src)
  local Player = qbGetPlayer(src)
  if not Player or not Player.PlayerData or not Player.PlayerData.job then return false, 'Player job not loaded' end
  local job = tostring(Player.PlayerData.job.name or ''):lower()
  local allowed = {
    police = true, sheriff = true, bcso = true, lspd = true, sahp = true,
    state = true, trooper = true, doc = true, government = true, gov = true,
    sadot = true, construction = true, roadworker = true
  }
  if allowed[job] then return true, job end
  return false, job
end

local function runResourceCommandWrapper(src, payload)
  payload = type(payload) == 'table' and payload or {}
  local command = trim(payload.command or '')
  local args = trim(payload.args or '')
  local wrapper = trim(payload.wrapper or '')

  if command == '' then return { ok = false, message = 'Missing command' } end
  if command:find('[^%w_:%-+/]') or command:find('[\r\n]') or args:find('[\r\n]') then
    return { ok = false, message = 'Unsafe command blocked' }
  end

  if wrapper == 'lotteryOpen' then
    TriggerClientEvent('az_lottery:client:open', src)
    return { ok = true, message = 'Lottery opened' }
  elseif wrapper == 'truckingOpen' then
    TriggerClientEvent('qb_ats_trucking:client:openUi', src)
    return { ok = true, message = 'Trucking board opened' }
  elseif wrapper == 'weaponSling' then
    TriggerClientEvent('mg-weapon-sling:client:changeSling', src)
    return { ok = true, message = 'Weapon sling toggled' }
  elseif wrapper == 'lockdownCreate' then
    local allowed, job = sourceHasLawJob(src)
    if not allowed then return { ok = false, message = 'Your job cannot create lockdowns: ' .. tostring(job) } end
    TriggerClientEvent('QBCore:Client:CreateLockdownBlip', src, job)
    return { ok = true, message = 'Lockdown created' }
  elseif wrapper == 'lockdownRemove' then
    local allowed, job = sourceHasLawJob(src)
    if not allowed then return { ok = false, message = 'Your job cannot remove lockdowns: ' .. tostring(job) } end
    TriggerClientEvent('QBCore:Client:RemoveLockdownBlip', src, job)
    return { ok = true, message = 'Lockdown removed' }
  elseif wrapper == 'vuInvoice' then
    local parts = splitCommandArgs(args)
    local target = tonumber(parts[1] or 0)
    local amount = tonumber(parts[2] or 0)
    if not target or target <= 0 or not amount or amount <= 0 then return { ok = false, message = 'Usage: /invoice <player id> <amount>' } end
    local Worker = qbGetPlayer(src)
    local Customer = qbGetPlayer(target)
    if not Worker or not Customer then return { ok = false, message = 'Worker/customer not found' } end
    local job = Worker.PlayerData.job and Worker.PlayerData.job.name or ''
    if job ~= 'vu' and job ~= 'vanillaunicorn' then return { ok = false, message = 'Only VU employees can invoice from this menu' } end
    if Worker.PlayerData.citizenid == Customer.PlayerData.citizenid then return { ok = false, message = 'You cannot invoice yourself' } end
    local firstname = (Worker.PlayerData.charinfo and Worker.PlayerData.charinfo.firstname) or GetPlayerName(src) or 'VU'
    if exports and exports.oxmysql then
      exports.oxmysql:insert('INSERT INTO phone_invoices (citizenid, amount, society, sender, sendercitizenid) VALUES (?, ?, ?, ?, ?)', {
        Customer.PlayerData.citizenid, amount, job, firstname, Worker.PlayerData.citizenid
      })
      TriggerClientEvent('qb-phone:RefreshPhone', Customer.PlayerData.source)
      TriggerClientEvent('QBCore:Notify', src, 'Invoice Successfully Sent', 'success')
      TriggerClientEvent('QBCore:Notify', Customer.PlayerData.source, 'New Invoice Received')
      return { ok = true, message = 'Invoice sent' }
    end
    return { ok = false, message = 'oxmysql export unavailable for invoice wrapper' }
  end

  return { ok = false, message = 'No source-aware wrapper found for /' .. command }
end

local function registeredCommandsForMenu(src)
  local out = {}
  local seen = {}
  if type(GetRegisteredCommands) ~= 'function' then return out end
  local ok, commands = pcall(GetRegisteredCommands)
  if not ok or type(commands) ~= 'table' then return out end
  for _, cmd in ipairs(commands) do
    if type(cmd) == 'table' then
      local name = tostring(cmd.name or cmd.command or cmd[1] or ''):gsub('^/', '')
      name = trim(name)
      if name ~= '' and not name:find('[\r\n]') then
        local resource = tostring(cmd.resource or cmd.resourceName or cmd.resource_name or cmd[2] or 'server')
        if resource == '' or resource == 'nil' then resource = 'server' end
        local restricted = cmd.restricted == true or cmd.permission == true
        local key = ('server:%s:%s'):format(resource, name)
        if not seen[key] then
          seen[key] = true
          out[#out + 1] = {
            name = name,
            command = name,
            label = '/' .. name,
            resource = resource,
            source = 'server',
            restricted = restricted,
            description = ('Auto-detected registered server command from %s.'):format(resource),
          }
        end
      end
    end
  end
  table.sort(out, function(a, b)
    local ar, br = tostring(a.resource or ''), tostring(b.resource or '')
    if ar == br then return tostring(a.name or '') < tostring(b.name or '') end
    return ar < br
  end)
  return out
end

RegisterNetEvent('amenu_ui:serverAction', function(requestId, action, payload)
  local src = source
  loadBans()
  cleanupBans()

  local function respond(data)
    TriggerClientEvent('amenu_ui:serverResponse', src, requestId, data)
  end

  if action == 'getQbState' then
    return respond({ ok = true, qb = qbStateForMenu(src), message = 'Framework state loaded' })
  end

  if action == 'getRegisteredCommands' then
    return respond({ ok = true, commands = registeredCommandsForMenu(src), message = 'Registered commands loaded' })
  end

  if action == 'qbCanSpawnVehicle' then
    local vehicleClass = tonumber(payload.vehicleClass) or -1
    local bridgeAllowedOk, bridgeAllowed, bridgeReason = callFrameworkBridgeExport('CanUseVehicleSpawner', src)
    if bridgeAllowedOk then
      if bridgeAllowed ~= true then
        local msg = 'You do not have active-framework access to the AMenu vehicle spawner.'
        if bridgeReason == 'offduty' then msg = 'You must be on duty to use the AMenu vehicle spawner.'
        elseif bridgeReason and bridgeReason ~= '' then msg = ('Your job/group (%s) cannot use the AMenu vehicle spawner.'):format(bridgeReason) end
        return respond({ ok = false, cost = 0, message = msg })
      end
      local costOk, cost = callFrameworkBridgeExport('GetSpawnCost', src, vehicleClass)
      cost = tonumber(cost) or 0
      local chargeOk, paid, account = callFrameworkBridgeExport('ChargePlayer', src, cost, ('AMenu NUI vehicle spawn class %s'):format(tostring(vehicleClass)))
      if chargeOk and paid ~= true then return respond({ ok = false, cost = cost, message = ('You need $%s to spawn this vehicle.'):format(cost) }) end
      return respond({ ok = true, cost = cost, account = account or 'free', message = cost > 0 and ('$%s charged from %s.'):format(cost, account or 'account') or 'Vehicle spawn approved.' })
    end

    if not qbEnabled() then return respond({ ok = true, cost = 0, message = 'Framework bridge disabled' }) end
    local Player = qbGetPlayer(src)
    if not Player then return respond({ ok = false, cost = 0, message = 'Framework player was not loaded yet' }) end
    local allowed, reason = qbCanUseVehicleSpawner(src)
    if not allowed then
      local msg = 'You do not have QBCore access to the AMenu vehicle spawner.'
      if reason == 'offduty' then msg = 'You must be on duty to use the AMenu vehicle spawner.'
      elseif reason and reason ~= '' then msg = ('Your job (%s) cannot use the AMenu vehicle spawner.'):format(reason) end
      return respond({ ok = false, cost = 0, message = msg })
    end
    local cost = qbGetSpawnCost(src, Player, vehicleClass)
    local paid, account = qbRemoveMoney(Player, cost, ('AMenu NUI vehicle spawn class %s'):format(tostring(vehicleClass)))
    if not paid then return respond({ ok = false, cost = cost, message = ('You need $%s to spawn this vehicle.'):format(cost) }) end
    qbAudit('Vehicle spawn approved', {
      source = src,
      name = GetPlayerName(src) or 'unknown',
      model = tostring(payload.model or ''),
      modelHash = tostring(payload.modelHash or ''),
      class = tostring(vehicleClass),
      cost = cost,
      account = account
    })
    return respond({ ok = true, cost = cost, account = account, message = cost > 0 and ('$%s charged from %s.'):format(cost, account) or 'Vehicle spawn approved.' })
  end

  if action == 'qbVehicleSpawned' then
    local plate = tostring(payload.plate or ''):gsub('^%s+', ''):gsub('%s+$', '')
    local cost = tonumber(payload.cost) or 0
    local bridgeKeysOk = false
    if plate ~= '' then
      local bridgeOk, keyResult = callFrameworkBridgeExport('GiveKeys', src, plate, tonumber(payload.netId) or 0, tonumber(payload.modelHash) or 0)
      bridgeKeysOk = bridgeOk and keyResult == true
    end
    local keys = qbConfig().Keys or {}
    if not bridgeKeysOk and plate ~= '' and keys.ClientSetOwnerEvent and keys.ClientSetOwnerEvent ~= '' then
      TriggerClientEvent(keys.ClientSetOwnerEvent, src, plate)
    end
    qbAudit('Vehicle spawned', {
      source = src,
      name = GetPlayerName(src) or 'unknown',
      netId = tostring(payload.netId or 0),
      plate = plate,
      modelHash = tostring(payload.modelHash or ''),
      class = tostring(payload.vehicleClass or -1),
      cost = cost
    })
    return respond({ ok = true, message = plate ~= '' and ('Vehicle keys/audit finished for %s.'):format(plate) or 'Vehicle audit finished.' })
  end

  if action == 'azRunPlayerAction' then
    payload = type(payload) == 'table' and payload or {}

    return respond(azDirectPlayerAction(src, payload))
  end

  if action == 'azFrameworkAction' then
    payload = type(payload) == 'table' and payload or {}
    return respond(azDirectPlayerAction(src, payload))
  end

  if action == 'qbRunPlayerAction' then
    payload = type(payload) == 'table' and payload or {}
    local actionName = payload.action or payload.Action or payload.actionName or payload.ActionName or payload.frameworkAction or payload.FrameworkAction or payload.framework_action
    local target = payload.target or payload.Target or payload.targetId or payload.TargetId or payload.targetID or payload.TargetID or payload.source or payload.Source or payload.src or payload.Src or payload.player or payload.Player or payload.playerId or payload.PlayerId or payload.context or payload.Context
    local args = payload.args or payload.Args or payload.values or payload.Values or payload.value or payload.Value or payload.extra or payload.Extra or {}
    local result = qbExecutePlayerAction(src, actionName or payload, target, args)
    return respond(result)
  end

  if action == 'runResourceCommandWrapper' then
    local result = runResourceCommandWrapper(src, payload or {})
    return respond(result)
  end

  if action == 'getBans' then
    if not hasAce(src, 'AMenu.OnlinePlayers.ViewBannedPlayers') and not hasAce(src, 'AMenu.Staff') then return respond({ ok = false, bans = {}, message = 'No permission' }) end
    return respond({ ok = true, bans = bans, message = 'Bans loaded' })
  end

  if action == 'unbanPlayer' then
    if not hasAce(src, 'AMenu.OnlinePlayers.Unban') and not hasAce(src, 'AMenu.Staff') then return respond({ ok = false, message = 'No permission' }) end
    local index = (tonumber(payload.index) or -1) + 1
    if index < 1 or index > #bans then return respond({ ok = false, message = 'Ban entry not found' }) end
    table.remove(bans, index)
    saveBans()
    return respond({ ok = true, message = 'Player unbanned', bans = bans })
  end

  if action == 'getPermissionsState' then
    return respond({ ok = true, permissions = getPermissionsSnapshot(src), message = 'Permissions loaded' })
  end

  if action == 'permissionsSummary' then
    if not canEditPermissions(src) then return respond({ ok = false, message = 'No permission' }) end
    loadPermissionsData()
    return respond({ ok = true, message = 'Permissions summary loaded', displayText = permissionsSummaryText() })
  end

  if action == 'grantPlayerGroup' then
    if not canEditPermissions(src) then return respond({ ok = false, message = 'No permission' }) end
    loadPermissionsData()
    local target = tonumber(payload.target)
    local group, err = normalizeGroupName(payload.group)
    if not target or not GetPlayerName(target) then return respond({ ok = false, message = 'Player not found' }) end
    if not group then return respond({ ok = false, message = err or 'Invalid group' }) end
    local ok, message = addPrincipalRule(preferredIdentifier(target), group)
    return respond({ ok = ok, message = message, permissions = getPermissionsSnapshot(src) })
  end

  if action == 'revokePlayerGroup' then
    if not canEditPermissions(src) then return respond({ ok = false, message = 'No permission' }) end
    loadPermissionsData()
    local target = tonumber(payload.target)
    local group, err = normalizeGroupName(payload.group)
    if not target or not GetPlayerName(target) then return respond({ ok = false, message = 'Player not found' }) end
    if not group then return respond({ ok = false, message = err or 'Invalid group' }) end
    local ok, message = removePrincipalRule(preferredIdentifier(target), group)
    return respond({ ok = ok, message = message, permissions = getPermissionsSnapshot(src) })
  end

  if action == 'addPermissionPrincipal' then
    if not canEditPermissions(src) then return respond({ ok = false, message = 'No permission' }) end
    loadPermissionsData()
    local subject, subjectErr = normalizePrincipalValue(payload.subject)
    local group, groupErr = normalizeGroupName(payload.group)
    if not subject then return respond({ ok = false, message = subjectErr or 'Invalid principal' }) end
    if not group then return respond({ ok = false, message = groupErr or 'Invalid group' }) end
    local ok, message = addPrincipalRule(subject, group)
    return respond({ ok = ok, message = message, permissions = getPermissionsSnapshot(src) })
  end

  if action == 'removePermissionPrincipal' then
    if not canEditPermissions(src) then return respond({ ok = false, message = 'No permission' }) end
    loadPermissionsData()
    local subject, subjectErr = normalizePrincipalValue(payload.subject)
    local group, groupErr = normalizeGroupName(payload.group)
    if not subject then return respond({ ok = false, message = subjectErr or 'Invalid principal' }) end
    if not group then return respond({ ok = false, message = groupErr or 'Invalid group' }) end
    local ok, message = removePrincipalRule(subject, group)
    return respond({ ok = ok, message = message, permissions = getPermissionsSnapshot(src) })
  end

  if action == 'addPermissionAce' then
    if not canEditPermissions(src) then return respond({ ok = false, message = 'No permission' }) end
    loadPermissionsData()
    local principal, principalErr = normalizePrincipalValue(payload.principal)
    local ace = trim(payload.ace)
    local mode = normalizeAceMode(payload.mode)
    if not principal then return respond({ ok = false, message = principalErr or 'Invalid principal' }) end
    if ace == '' then return respond({ ok = false, message = 'ACE is required' }) end
    local ok, message = addAceRule(principal, ace, mode)
    return respond({ ok = ok, message = message, permissions = getPermissionsSnapshot(src) })
  end

  if action == 'removePermissionAce' then
    if not canEditPermissions(src) then return respond({ ok = false, message = 'No permission' }) end
    loadPermissionsData()
    local principal, principalErr = normalizePrincipalValue(payload.principal)
    local ace = trim(payload.ace)
    local mode = normalizeAceMode(payload.mode)
    if not principal then return respond({ ok = false, message = principalErr or 'Invalid principal' }) end
    if ace == '' then return respond({ ok = false, message = 'ACE is required' }) end
    local ok, message = removeAceRule(principal, ace, mode)
    return respond({ ok = ok, message = message, permissions = getPermissionsSnapshot(src) })
  end

  if action == 'getWorldState' then
    return respond({ ok = true, world = worldState, message = 'World state loaded' })
  end

  if action == 'setWorldTime' then
    if not worldControlsEnabled() then return respond({ ok = false, message = 'World controls are disabled in config' }) end
    if not requireWorldAce(src) then return respond({ ok = false, message = 'No permission' }) end
    worldState.hour = math.max(0, math.min(23, tonumber(payload.hour) or worldState.hour))
    worldState.minute = math.max(0, math.min(59, tonumber(payload.minute) or worldState.minute))
    broadcastWorldState()
    return respond({ ok = true, message = ('Time set to %02d:%02d'):format(worldState.hour, worldState.minute), world = worldState })
  end

  if action == 'toggleFreezeTime' then
    if not worldControlsEnabled() then return respond({ ok = false, message = 'World controls are disabled in config' }) end
    if not requireWorldAce(src) then return respond({ ok = false, message = 'No permission' }) end
    worldState.freezeTime = not worldState.freezeTime
    broadcastWorldState()
    return respond({ ok = true, message = worldState.freezeTime and 'Time frozen' or 'Time unfrozen', world = worldState })
  end

  if action == 'setWorldWeather' then
    if not worldControlsEnabled() then return respond({ ok = false, message = 'World controls are disabled in config' }) end
    if not requireWorldAce(src) then return respond({ ok = false, message = 'No permission' }) end
    worldState.weather = tostring(payload.weather or worldState.weather)
    broadcastWorldState()
    return respond({ ok = true, message = ('Weather set to %s'):format(worldState.weather), world = worldState })
  end

  if action == 'toggleDynamicWeather' then
    if not worldControlsEnabled() then return respond({ ok = false, message = 'World controls are disabled in config' }) end
    if not requireWorldAce(src) then return respond({ ok = false, message = 'No permission' }) end
    worldState.dynamicWeather = not worldState.dynamicWeather
    broadcastWorldState()
    return respond({ ok = true, message = worldState.dynamicWeather and 'Dynamic weather enabled' or 'Dynamic weather disabled', world = worldState })
  end

  if action == 'toggleBlackout' then
    if not worldControlsEnabled() then return respond({ ok = false, message = 'World controls are disabled in config' }) end
    if not requireWorldAce(src) then return respond({ ok = false, message = 'No permission' }) end
    worldState.blackout = not worldState.blackout
    broadcastWorldState()
    return respond({ ok = true, message = worldState.blackout and 'Blackout enabled' or 'Blackout disabled', world = worldState })
  end

  if action == 'setWorldClouds' then
    if not worldControlsEnabled() then return respond({ ok = false, message = 'World controls are disabled in config' }) end
    if not requireWorldAce(src) then return respond({ ok = false, message = 'No permission' }) end
    local mode = tostring(payload.mode or 'default')
    if mode == 'clear' then
      worldState.clouds = 'clear'
      broadcastWorldState()
      return respond({ ok = true, message = 'Clouds removed', world = worldState })
    elseif mode == 'random' then
      worldState.clouds = cloudPresets[math.random(1, #cloudPresets)]
      broadcastWorldState()
      return respond({ ok = true, message = 'Cloud pattern randomized', world = worldState })
    end
    worldState.clouds = 'default'
    broadcastWorldState()
    return respond({ ok = true, message = 'Cloud pattern reset', world = worldState })
  end

  if action == 'identifiers' then
    if not hasAce(src, 'AMenu.OnlinePlayers.Identifiers') and not hasAce(src, 'AMenu.Staff') then return respond({ ok = false, message = 'No permission' }) end
    local target = tonumber(payload.target)
    if not target or not GetPlayerName(target) then return respond({ ok = false, message = 'Player not found' }) end
    return respond({ ok = true, message = table.concat(getIdentifiers(target), '\n') })
  end

  if action == 'civSyncPmBlocks' then
    pmBlocks[src] = {}
    if type(payload.blocked) == 'table' then
      for target, enabled in pairs(payload.blocked) do
        local targetId = tonumber(target)
        if targetId and targetId > 0 and enabled == true then pmBlocks[src][targetId] = true end
      end
    end
    return respond({ ok = true, message = 'Message block list synced' })
  end

  if action == 'civSetPmBlock' then
    local target = tonumber(payload.target)
    if not target or target == src or not GetPlayerName(target) then return respond({ ok = false, message = 'Player not found' }) end
    pmBlocks[src] = pmBlocks[src] or {}
    if payload.blocked == true then
      pmBlocks[src][target] = true
      return respond({ ok = true, message = ('Blocked private messages from %s'):format(getPlayerNameSafe(target)) })
    end
    pmBlocks[src][target] = nil
    return respond({ ok = true, message = ('Unblocked private messages from %s'):format(getPlayerNameSafe(target)) })
  end

  if action == 'civRequestGPS' then
    local target = tonumber(payload.target)
    if not target or target == src or not GetPlayerName(target) then return respond({ ok = false, message = 'Player not found' }) end
    local timeout = tonumber(Config and Config.Civilian and Config.Civilian.GpsRequestTimeoutSeconds or 120) or 120
    local expiresAt = os.time() + math.max(15, math.min(600, timeout))
    pendingGpsRequests[target] = pendingGpsRequests[target] or {}
    pendingGpsRequests[target][src] = expiresAt
    TriggerClientEvent('amenu_ui:gpsRequest', target, src, getPlayerNameSafe(src), expiresAt)
    qbNotify(target, ('%s requested your GPS location. Open AMenu > Civilian Player Menu > GPS Requests.'):format(getPlayerNameSafe(src)), 'primary', 8000)
    return respond({ ok = true, message = ('GPS request sent to %s'):format(getPlayerNameSafe(target)) })
  end

  if action == 'civRespondGPS' then
    local requester = tonumber(payload.requester)
    if not requester or requester == src or not GetPlayerName(requester) then return respond({ ok = false, message = 'Requester not found' }) end
    local pending = pendingGpsRequests[src] and pendingGpsRequests[src][requester]
    if not pending then return respond({ ok = false, message = 'No pending GPS request from that player' }) end
    pendingGpsRequests[src][requester] = nil
    TriggerClientEvent('amenu_ui:gpsRequestClosed', src, requester)
    if os.time() > tonumber(pending) then
      return respond({ ok = false, message = 'That GPS request expired' })
    end
    if payload.accepted ~= true then
      qbNotify(requester, ('%s denied your GPS request.'):format(getPlayerNameSafe(src)), 'error', 5000)
      return respond({ ok = true, message = 'GPS request denied' })
    end
    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    TriggerClientEvent('amenu_ui:gpsAccepted', requester, getPlayerNameSafe(src), { x = coords.x, y = coords.y, z = coords.z })
    qbNotify(requester, ('%s accepted your GPS request.'):format(getPlayerNameSafe(src)), 'success', 5000)
    return respond({ ok = true, message = ('Shared your GPS location with %s'):format(getPlayerNameSafe(requester)) })
  end

  if action == 'civPrivateMessage' then
    local target = tonumber(payload.target)
    local message = trim(payload.message or '')
    if not target or target == src or message == '' or not GetPlayerName(target) then
      return respond({ ok = false, message = 'Invalid target or empty message' })
    end
    if pmBlocks[target] and pmBlocks[target][src] then
      return respond({ ok = false, message = 'That player has blocked private messages from you' })
    end
    if #message > 240 then message = message:sub(1, 240) end
    TriggerClientEvent('amenu_ui:privateMessage', target, getPlayerNameSafe(src), message, src)
    TriggerClientEvent('amenu_ui:privateMessage', src, 'To ' .. getPlayerNameSafe(target), message, target)
    return respond({ ok = true, message = 'Private message sent' })
  end

  if action == 'civGiveMoney' then
    local target = tonumber(payload.target)
    if not target or target == src or not GetPlayerName(target) then return respond({ ok = false, message = 'Player not found' }) end
    local account = string.lower(trim(payload.account or 'cash'))
    if account ~= 'cash' and account ~= 'bank' then return respond({ ok = false, message = 'Account must be cash or bank' }) end
    local amount = math.floor(tonumber(payload.amount or 0) or 0)
    local maxTransfer = tonumber(Config and Config.Civilian and Config.Civilian.MaxTransferAmount or 100000) or 100000
    if amount <= 0 then return respond({ ok = false, message = 'Invalid amount' }) end
    if amount > maxTransfer then return respond({ ok = false, message = ('Max transfer is $%s'):format(maxTransfer) }) end
    local bridgeRemoveOk, bridgeRemoved = callFrameworkBridgeExport('RemoveMoney', src, account, amount, ('AMenu civilian transfer to %s'):format(target))
    if bridgeRemoveOk then
      if bridgeRemoved ~= true then return respond({ ok = false, message = ('You do not have enough %s money.'):format(account) }) end
      local bridgeAddOk, bridgeAdded = callFrameworkBridgeExport('AddMoney', target, account, amount, ('AMenu civilian transfer from %s'):format(src))
      if bridgeAddOk and bridgeAdded == true then
        TriggerClientEvent('amenu_ui:privateMessage', target, 'Money Transfer', ('%s gave you $%s %s.'):format(getPlayerNameSafe(src), amount, account), src)
        return respond({ ok = true, message = ('Gave $%s %s to %s'):format(amount, account, getPlayerNameSafe(target)) })
      end
      callFrameworkBridgeExport('AddMoney', src, account, amount, 'AMenu civilian transfer refund')
      return respond({ ok = false, message = 'Transfer failed and was refunded' })
    end

    local Sender = qbGetPlayer(src)
    local Target = qbGetPlayer(target)
    if not Sender or not Target then return respond({ ok = false, message = 'Framework player data not loaded' }) end
    local removed = Sender.Functions.RemoveMoney(account, amount, ('AMenu civilian transfer to %s'):format(target))
    if removed ~= true then return respond({ ok = false, message = ('You do not have enough %s money.'):format(account) }) end
    local added = Target.Functions.AddMoney(account, amount, ('AMenu civilian transfer from %s'):format(src))
    if added ~= true then
      Sender.Functions.AddMoney(account, amount, 'AMenu civilian transfer refund')
      return respond({ ok = false, message = 'Transfer failed and was refunded' })
    end
    qbNotify(src, ('You gave $%s %s to %s.'):format(amount, account, getPlayerNameSafe(target)), 'success')
    qbNotify(target, ('%s gave you $%s %s.'):format(getPlayerNameSafe(src), amount, account), 'success')
    qbAudit('Civilian money transfer', {
      source = src,
      target = target,
      account = account,
      amount = amount,
      from = getPlayerNameSafe(src),
      to = getPlayerNameSafe(target)
    })
    return respond({ ok = true, message = ('Gave $%s %s to %s'):format(amount, account, getPlayerNameSafe(target)) })
  end

  if action == 'sendPrivateMessage' then
    if not hasAce(src, 'AMenu.OnlinePlayers.SendMessage') and not hasAce(src, 'AMenu.Staff') then return respond({ ok = false, message = 'No permission' }) end
    local target = tonumber(payload.target)
    local message = tostring(payload.message or '')
    if not target or message == '' or not GetPlayerName(target) then return respond({ ok = false, message = 'Invalid target or empty message' }) end
    TriggerClientEvent('amenu_ui:privateMessage', target, getPlayerNameSafe(src), message, src)
    return respond({ ok = true, message = 'Private message sent' })
  end

  if action == 'summonPlayer' then
    if not hasAce(src, 'AMenu.OnlinePlayers.Summon') and not hasAce(src, 'AMenu.Staff') then return respond({ ok = false, message = 'No permission' }) end
    local target = tonumber(payload.target)
    if not target or not GetPlayerName(target) then return respond({ ok = false, message = 'Player not found' }) end
    TriggerClientEvent('amenu_ui:teleportToCoords', target, payload.coords)
    return respond({ ok = true, message = 'Player summoned' })
  end

  if action == 'killPlayer' then
    if not hasAce(src, 'AMenu.OnlinePlayers.Kill') and not hasAce(src, 'AMenu.Staff') then return respond({ ok = false, message = 'No permission' }) end
    local target = tonumber(payload.target)
    if not target or not GetPlayerName(target) then return respond({ ok = false, message = 'Player not found' }) end
    TriggerClientEvent('amenu_ui:killMe', target)
    return respond({ ok = true, message = 'Player killed' })
  end

  if action == 'kickPlayer' then
    if not hasAce(src, 'AMenu.OnlinePlayers.Kick') and not hasAce(src, 'AMenu.Staff') then return respond({ ok = false, message = 'No permission' }) end
    local target = tonumber(payload.target)
    if not target or not GetPlayerName(target) then return respond({ ok = false, message = 'Player not found' }) end
    DropPlayer(target, tostring(payload.reason or 'Kicked by staff'))
    return respond({ ok = true, message = 'Player kicked' })
  end

  if action == 'tempBanPlayer' or action == 'permBanPlayer' then
    local ace = action == 'tempBanPlayer' and 'AMenu.OnlinePlayers.TempBan' or 'AMenu.OnlinePlayers.PermBan'
    if not hasAce(src, ace) and not hasAce(src, 'AMenu.Staff') then return respond({ ok = false, message = 'No permission' }) end
    local target = tonumber(payload.target)
    if not target or not GetPlayerName(target) then return respond({ ok = false, message = 'Player not found' }) end
    local entry = {
      playerName = getPlayerNameSafe(target),
      identifiers = getIdentifiers(target),
      reason = tostring(payload.reason or 'Banned by staff'),
      bannedBy = getPlayerNameSafe(src),
      createdAt = os.time(),
      expiresAt = action == 'tempBanPlayer' and (os.time() + ((tonumber(payload.minutes) or 60) * 60)) or 0
    }
    table.insert(bans, entry)
    saveBans()
    DropPlayer(target, entry.reason)
    return respond({ ok = true, message = action == 'tempBanPlayer' and 'Player temp banned' or 'Player permanently banned' })
  end

  respond({ ok = false, message = 'Unknown server action' })
end)

CreateThread(function()
  loadBans()
  cleanupBans()
  loadPermissionsData()
end)

CreateThread(function()
  math.randomseed(os.time())
  local weatherTicker = GetGameTimer()
  local weatherIndex = 1
  while true do
    Wait(5000)
    if worldSyncEnabled() and worldState.dynamicWeather and (GetGameTimer() - weatherTicker) >= 300000 then
      weatherTicker = GetGameTimer()
      weatherIndex = weatherIndex + 1
      if weatherIndex > #dynamicWeatherList then weatherIndex = 1 end
      worldState.weather = dynamicWeatherList[weatherIndex]
      broadcastWorldState()
    end
  end
end)
