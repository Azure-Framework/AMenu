local RESOURCE = GetCurrentResourceName()
local AZ_RESOURCE = Config.AzResource or 'Az-Framework'

local function trim(value)
    return tostring(value or ''):gsub('^%s+', ''):gsub('%s+$', '')
end

local function lower(value)
    return trim(value):lower()
end

local function compact(value)
    return lower(value):gsub('[^%w]', '')
end

local function debugPrint(...)
    if not Config.Debug then return end
    local parts = {}
    for i = 1, select('#', ...) do
        parts[#parts + 1] = tostring(select(i, ...))
    end
    print(('^3[%s]^7 %s'):format(RESOURCE, table.concat(parts, ' ')))
end

local function isPlayerOnline(src)
    src = tonumber(src or 0) or 0
    return src > 0 and GetPlayerName(src) ~= nil
end

local function azExports()
    if GetResourceState(AZ_RESOURCE) ~= 'started' then
        return nil, ('%s not started'):format(AZ_RESOURCE)
    end

    local ok, exp = pcall(function() return exports[AZ_RESOURCE] end)
    if not ok or not exp then
        return nil, ('%s exports unavailable'):format(AZ_RESOURCE)
    end

    return exp, nil
end

local function azCall(exportName, ...)
    local exp, err = azExports()
    if not exp then
        debugPrint('azCall failed:', exportName, err)
        return false, nil, err
    end

    local okFn, fn = pcall(function() return exp[exportName] end)
    if not okFn or type(fn) ~= 'function' then
        local msg = ('missing Az export %s'):format(tostring(exportName))
        debugPrint(msg)
        return false, nil, msg
    end

    local ok, a, b, c, d = pcall(fn, ...)
    if ok then
        return true, a, b, c, d
    end

    local firstErr = a
    ok, a, b, c, d = pcall(fn, exp, ...)
    if ok then
        return true, a, b, c, d
    end

    local msg = tostring(a or firstErr or 'Az export call failed')
    debugPrint('azCall error:', exportName, msg)
    return false, nil, msg
end

local function azFirst(names, ...)
    for _, name in ipairs(names or {}) do
        local ok, a, b, c, d = azCall(name, ...)
        if ok then
            return true, a, b, c, d, name
        end
    end
    return false, nil, 'no Az export succeeded'
end

local function notify(src, message, msgType, duration)
    src = tonumber(src or 0) or 0
    if src <= 0 then
        print(('[%s] %s'):format(RESOURCE, tostring(message or '')))
        return
    end

    local ok, result = azCall('BridgeNotify', src, tostring(message or ''), msgType or 'inform', tonumber(duration) or 5000)
    if ok and result ~= false then return end

    if Config.Notifications and Config.Notifications.UseOxLibFallback then
        TriggerClientEvent('ox_lib:notify', src, {
            title = (Config.Notifications and Config.Notifications.Title) or 'vMenu Bridge',
            description = tostring(message or ''),
            type = msgType or 'inform',
            duration = tonumber(duration) or 5000
        })
    end

    TriggerClientEvent('chat:addMessage', src, {
        args = { '^3vMenu Bridge', tostring(message or '') }
    })
end

local function hasAdmin(src)
    src = tonumber(src or 0) or 0
    if src == 0 then return true end

    for _, ace in ipairs(Config.AdminAces or {}) do
        if ace ~= '' and IsPlayerAceAllowed(src, ace) then
            return true
        end
    end

    local ok, result = azFirst({ 'isAdmin', 'IsAdmin' }, src)
    if ok and result == true then return true end

    return false
end

local function oneOnlinePlayerFallback()
    local found = 0
    for _, id in ipairs(GetPlayers()) do
        local src = tonumber(id) or 0
        if isPlayerOnline(src) then
            if found ~= 0 then return 0 end
            found = src
        end
    end
    return found
end

local function resolveSource(value, fallback)
    if type(value) == 'number' then
        local n = math.floor(value)
        if isPlayerOnline(n) then return n end
    elseif type(value) == 'string' then
        local n = tonumber(value)
        if n and isPlayerOnline(n) then return math.floor(n) end
        local bracketed = value:match('%[(%d+)%]')
        if bracketed and isPlayerOnline(tonumber(bracketed)) then return tonumber(bracketed) end
    elseif type(value) == 'table' then
        for _, key in ipairs({ 'target', 'targetId', 'Target', 'TargetId', 'source', 'src', 'serverId', 'playerId', 'id' }) do
            local n = resolveSource(value[key])
            if n > 0 then return n end
        end
        if type(value.context) == 'table' then
            local n = resolveSource(value.context)
            if n > 0 then return n end
        end
    end

    fallback = tonumber(fallback or 0) or 0
    if isPlayerOnline(fallback) then return fallback end
    return 0
end

local activeCharacterCache = {}

local function stateBag(src)
    src = tonumber(src or 0) or 0
    if src <= 0 or not Player then return nil end
    local ok, ply = pcall(Player, src)
    if not ok or not ply or not ply.state then return nil end
    return ply.state
end

local function setStateValue(st, key, value)
    if not st or not key then return end
    local ok = pcall(function()
        if st.set then st:set(key, value, true) else st[key] = value end
    end)
    return ok
end

local function getStateValue(st, key)
    if not st or not key then return nil end
    local ok, value = pcall(function() return st[key] end)
    if ok then return value end
    return nil
end

local function cacheActiveCharacter(src, charid, reason)
    src = tonumber(src or 0) or 0
    local cid = tostring(charid or '')
    if src <= 0 or cid == '' or cid == 'nil' then return false end

    activeCharacterCache[tostring(src)] = cid
    local st = stateBag(src)
    setStateValue(st, 'az_active_character', cid)
    setStateValue(st, 'az_active_charid', cid)
    setStateValue(st, 'activeCharacter', cid)
    setStateValue(st, 'charid', cid)
    setStateValue(st, 'az_active_character_reason', tostring(reason or 'vMenu-Bridge'))
    debugPrint('cached active character', src, cid, reason or '')
    return true
end

local function getCachedActiveCharacter(src)
    src = tonumber(src or 0) or 0
    if src <= 0 then return nil end

    local cached = tostring(activeCharacterCache[tostring(src)] or '')
    if cached ~= '' then return cached end

    local st = stateBag(src)
    for _, key in ipairs({ 'az_active_character', 'az_active_charid', 'activeCharacter', 'charid', 'characterId', 'citizenid' }) do
        local value = getStateValue(st, key)
        value = tostring(value or '')
        if value ~= '' and value ~= 'nil' and value ~= 'unknown' then
            activeCharacterCache[tostring(src)] = value
            return value
        end
    end

    return nil
end

RegisterNetEvent('azfw:set_active_character', function(charid)
    cacheActiveCharacter(source, charid, 'azfw:set_active_character')
end)

RegisterNetEvent('az-fw-money:selectCharacter', function(charid)
    cacheActiveCharacter(source, charid, 'az-fw-money:selectCharacter')
end)

RegisterNetEvent('vMenu-Bridge:setActiveCharacter', function(a, b)

    if b ~= nil then
        cacheActiveCharacter(a, b, 'vMenu-Bridge:setActiveCharacter:local')
    else
        cacheActiveCharacter(source, a, 'vMenu-Bridge:setActiveCharacter:net')
    end
end)

AddEventHandler('Az-Framework:characterSelected', function(src, charid)
    cacheActiveCharacter(src, charid, 'Az-Framework:characterSelected')
end)

AddEventHandler('Az-Framework:Bridge:characterSelected', function(src, charid)
    cacheActiveCharacter(src, charid, 'Az-Framework:Bridge:characterSelected')
end)

AddEventHandler('playerDropped', function()
    activeCharacterCache[tostring(source)] = nil
end)

local function getDiscordIdentifier(src)
    local ok, did = azFirst({ 'GetDiscordID', 'getDiscordID' }, src)
    did = tostring((ok and did) or ''):gsub('^discord:', '')
    if did ~= '' and did ~= 'nil' then return did end

    local ids = GetPlayerIdentifiers(tonumber(src or 0) or 0) or {}
    for _, id in ipairs(ids) do
        if type(id) == 'string' and id:sub(1, 8) == 'discord:' then
            return id:sub(9)
        end
    end
    return ''
end

local function dbSingleAwait(sql, params)
    if not MySQL then return nil end

    if MySQL.single and type(MySQL.single.await) == 'function' then
        local ok, row = pcall(function() return MySQL.single.await(sql, params or {}) end)
        if ok then return row end
    end

    if MySQL.query and type(MySQL.query.await) == 'function' then
        local ok, rows = pcall(function() return MySQL.query.await(sql, params or {}) end)
        if ok and type(rows) == 'table' then return rows[1] end
    end

    if MySQL.Async and type(MySQL.Async.fetchAll) == 'function' then
        local p = promise.new()
        local done = false
        local ok = pcall(function()
            MySQL.Async.fetchAll(sql, params or {}, function(rows)
                if done then return end
                done = true
                p:resolve(type(rows) == 'table' and rows[1] or nil)
            end)
        end)
        if ok then
            SetTimeout(1000, function()
                if done then return end
                done = true
                p:resolve(nil)
            end)
            return Citizen.Await(p)
        end
    end

    return nil
end

local dbActiveCharacterRow, dbMoneyRow
local resolveActiveCharacter

local function dbUpdateAwait(sql, params)
    if not MySQL then return 0 end

    if MySQL.update and type(MySQL.update.await) == 'function' then
        local ok, affected = pcall(function() return MySQL.update.await(sql, params or {}) end)
        if ok then return tonumber(affected) or 0 end
    end

    if MySQL.query and type(MySQL.query.await) == 'function' then
        local ok = pcall(function() return MySQL.query.await(sql, params or {}) end)
        if ok then return 1 end
    end

    if MySQL.Async and type(MySQL.Async.execute) == 'function' then
        local p = promise.new()
        local done = false
        local ok = pcall(function()
            MySQL.Async.execute(sql, params or {}, function(affected)
                if done then return end
                done = true
                p:resolve(tonumber(affected) or 0)
            end)
        end)
        if ok then
            SetTimeout(1500, function()
                if done then return end
                done = true
                p:resolve(0)
            end)
            return Citizen.Await(p)
        end
    end

    return 0
end

local function splitCharacterName(name)
    name = trim(name)
    if name == '' then return '', '' end
    local first, last = name:match('^(%S+)%s+(.+)$')
    return first or name, last or ''
end

local function ensureMoneyRow(discordId, charid, charName)
    discordId = tostring(discordId or '')
    charid = tostring(charid or '')
    if discordId == '' or charid == '' then return false end

    local row = dbMoneyRow(discordId, charid)
    if row then return true end

    local first, last = splitCharacterName(charName or '')
    local affected = dbUpdateAwait(
        'INSERT INTO econ_user_money (discordid, charid, firstname, lastname, cash, bank) VALUES (?, ?, ?, ?, 0, 0) ON DUPLICATE KEY UPDATE charid=VALUES(charid)',
        { discordId, charid, first, last }
    )
    return affected >= 0
end

local function pushHudFromDb(src, discordId, charid)
    src = tonumber(src or 0) or 0
    if src <= 0 then return end

    azCall('sendMoneyToClient', src, true)

    local money = dbMoneyRow(discordId, charid) or {}
    local char = dbActiveCharacterRow(discordId, charid) or {}
    local name = tostring(char.name or GetPlayerName(src) or '')
    local cash = tonumber(money.cash or 0) or 0
    local bank = tonumber(money.bank or 0) or 0
    TriggerClientEvent('updateCashHUD', src, cash, bank, name)
end

local function directSetJob(src, job, grade)
    src = tonumber(src or 0) or 0
    job = lower(job)
    grade = tonumber(grade or 0) or 0
    if src <= 0 or job == '' then return false, 'bad_args' end

    local discordId = getDiscordIdentifier(src)
    local charid = resolveActiveCharacter(src)
    if discordId == '' or not charid or tostring(charid) == '' then return false, 'no_active_character' end

    local affected = dbUpdateAwait('UPDATE user_characters SET active_department=? WHERE discordid=? AND charid=?', { job, discordId, tostring(charid) })
    if affected <= 0 then return false, 'db_update_failed' end

    local st = stateBag(src)
    setStateValue(st, 'job', job)
    setStateValue(st, 'department', job)
    TriggerClientEvent('hud:setDepartment', src, job)
    TriggerEvent('Az-Framework:jobChanged', src, job, '')
    TriggerClientEvent('Az-Framework:jobChanged', src, job, '')
    TriggerEvent('vMenu:QBCore:RefreshPermissions', src)
    debugPrint('directSetJob success', src, job, grade, 'charid=', tostring(charid))
    return true
end

local function directMoney(src, account, amount, mode)
    src = tonumber(src or 0) or 0
    account = lower(account)
    if account == 'money' then account = 'cash' end
    amount = math.floor(tonumber(amount or 0) or 0)
    if src <= 0 or amount <= 0 then return false, 'bad_args' end
    if account ~= 'cash' and account ~= 'bank' then return false, 'bad_account' end

    local discordId = getDiscordIdentifier(src)
    local charid = resolveActiveCharacter(src)
    if discordId == '' or not charid or tostring(charid) == '' then return false, 'no_active_character' end
    charid = tostring(charid)

    local char = dbActiveCharacterRow(discordId, charid) or {}
    ensureMoneyRow(discordId, charid, char.name or '')
    local money = dbMoneyRow(discordId, charid) or {}
    local current = tonumber(money[account] or 0) or 0
    local nextAmount = mode == 'remove' and math.max(0, current - amount) or (current + amount)

    local affected = 0
    if account == 'cash' then
        affected = dbUpdateAwait('UPDATE econ_user_money SET cash=? WHERE discordid=? AND charid=?', { nextAmount, discordId, charid })
    else
        affected = dbUpdateAwait('UPDATE econ_user_money SET bank=? WHERE discordid=? AND charid=?', { nextAmount, discordId, charid })
        dbUpdateAwait("UPDATE econ_accounts SET balance=? WHERE discordid=? AND charid=? AND type='checking'", { nextAmount, discordId, charid })
    end

    if affected <= 0 then return false, 'db_update_failed' end
    pushHudFromDb(src, discordId, charid)
    TriggerEvent('Az-Framework:Bridge:moneyChanged', src, account, amount, mode == 'remove' and 'remove' or 'add')
    debugPrint('directMoney success', mode, src, account, amount, 'charid=', charid, 'new=', nextAmount)
    return true
end

function dbActiveCharacterRow(discordId, charid)
    discordId = tostring(discordId or '')
    charid = tostring(charid or '')
    if discordId == '' or charid == '' then return nil end
    return dbSingleAwait('SELECT charid, name, active_department FROM user_characters WHERE discordid=? AND charid=? LIMIT 1', { discordId, charid })
end

function dbMoneyRow(discordId, charid)
    discordId = tostring(discordId or '')
    charid = tostring(charid or '')
    if discordId == '' or charid == '' then return nil end
    return dbSingleAwait('SELECT cash, bank FROM econ_user_money WHERE discordid=? AND charid=? LIMIT 1', { discordId, charid })
end

resolveActiveCharacter = function(src)
    src = tonumber(src or 0) or 0
    if src <= 0 then return nil end

    local cid = getCachedActiveCharacter(src)
    if cid and cid ~= '' then return cid end

    local ok, exported = azFirst({ 'GetActiveCharacter', 'getActiveCharacter', 'GetCharacter', 'getCharacter', 'GetPlayerCharacter', 'getPlayerCharacter' }, src)
    exported = tostring((ok and exported) or '')
    if exported ~= '' and exported ~= 'nil' and exported ~= 'unknown' then
        cacheActiveCharacter(src, exported, 'Az export')
        return exported
    end

    return nil
end

local ACTION_ALIASES = {
    info = 'info', playerinfo = 'info', qbinfo = 'info', azinfo = 'info', details = 'info', inspect = 'info',
    setjob = 'setjob', qbsetjob = 'setjob', azsetjob = 'setjob', setjobpreset = 'setjob', qbsetjobpreset = 'setjob', azsetjobpreset = 'setjob', customjob = 'setjob', qbsetcustomjob = 'setjob', azsetcustomjob = 'setjob',
    addmoney = 'addmoney', qbaddmoney = 'addmoney', azaddmoney = 'addmoney', addcash = 'addmoney', addbank = 'addmoney', givemoney = 'addmoney', givecash = 'addmoney', givebank = 'addmoney',
    removemoney = 'removemoney', qbremovemoney = 'removemoney', azremovemoney = 'removemoney', removecash = 'removemoney', removebank = 'removemoney', takemoney = 'removemoney', takecash = 'removemoney', takebank = 'removemoney', deductmoney = 'removemoney', deductcash = 'removemoney', deductbank = 'removemoney',
    revive = 'revive', qbrevive = 'revive', azrevive = 'revive', reviveplayer = 'revive',
    heal = 'heal', qbheal = 'heal', azheal = 'heal', healplayer = 'heal',
    duty = 'duty', qbduty = 'duty', azduty = 'duty', setduty = 'duty', dutyon = 'duty', dutyoff = 'duty', onduty = 'duty', offduty = 'duty',
    save = 'save', qbsave = 'save', azsave = 'save', saveplayer = 'save',
    kick = 'kick', qbkick = 'kick', azkick = 'kick', kickplayer = 'kick',
    keys = 'keys', qbkeys = 'keys', azkeys = 'keys', givekeys = 'keys', giveplatekeys = 'keys', qbgiveplatekeys = 'keys', azgiveplatekeys = 'keys', givecurrentkeys = 'keys'
}

local JOB_ACTION_VALUES = {
    police = true, sheriff = true, state = true, ems = true, ambulance = true, fire = true,
    leo = true, lspd = true, bcso = true, sasp = true, sahp = true, trooper = true,
    ranger = true, park = true, parks = true, civ = true, civilian = true, unemployed = true,
    offduty = true, offdutycivilian = true
}

local MONEY_ACCOUNT_VALUES = {
    cash = true, money = true, bank = true
}

local function isJobActionValue(value)
    return JOB_ACTION_VALUES[compact(value)] == true
end

local function isMoneyAccountValue(value)
    return MONEY_ACCOUNT_VALUES[compact(value)] == true
end

local function actionFromString(value)
    if value == nil then return '' end
    local raw = tostring(value or '')
    if raw:find('^table:') or raw:find('^function:') or raw:find('^userdata:') then return '' end

    local key = compact(raw)
    if key == '' or key == 'nil' then return '' end
    if tonumber(key) then return '' end
    if ACTION_ALIASES[key] then return ACTION_ALIASES[key] end
    if isJobActionValue(key) then return 'setjob' end
    if isMoneyAccountValue(key) then return 'addmoney' end

    if key:find('playerinfo') or key:find('details') then return 'info' end
    if key:find('setjob') or key:find('customjob') or key:find('jobpreset') then return 'setjob' end
    if key:find('addcash') or key:find('addbank') or key:find('addmoney') or key:find('givecash') or key:find('givebank') or key:find('givemoney') then return 'addmoney' end
    if key:find('removecash') or key:find('removebank') or key:find('removemoney') or key:find('takecash') or key:find('takebank') or key:find('takemoney') or key:find('deduct') then return 'removemoney' end
    if key:find('revive') then return 'revive' end
    if key:find('heal') then return 'heal' end
    if key:find('duty') then return 'duty' end
    if key:find('save') then return 'save' end
    if key:find('kick') then return 'kick' end
    if key:find('key') then return 'keys' end

    return key
end

local function actionFromAny(value, seen)
    if type(value) ~= 'table' then return actionFromString(value) end

    seen = seen or {}
    if seen[value] then return '' end
    seen[value] = true

    for _, key in ipairs({ 'action', 'Action', 'actionName', 'ActionName', 'frameworkAction', 'FrameworkAction', 'framework_action', 'event', 'command', 'cmd', 'id', 'key', 'name', 'label', 'title', 'text', 1 }) do
        local action = actionFromAny(value[key], seen)
        if action ~= '' then return action end
    end

    local val = type(value.value) == 'table' and value.value or {}
    if value.job or value.jobName or val.job or val.jobName then return 'setjob' end
    if value.amount or val.amount then return 'addmoney' end
    if value.plate or val.plate then return 'keys' end
    if value.duty ~= nil or val.duty ~= nil then return 'duty' end

    return ''
end

local function arrayAppend(out, value)
    if value ~= nil and value ~= '' then out[#out + 1] = value end
end

local function flattenArgs(out, value, seen)
    if value == nil then return end
    if type(value) ~= 'table' then
        arrayAppend(out, value)
        return
    end

    seen = seen or {}
    if seen[value] then return end
    seen[value] = true

    for _, key in ipairs({ 'account', 'moneyType', 'type', 'amount', 'job', 'jobName', 'grade', 'rank', 'plate', 'duty', 'reason' }) do
        arrayAppend(out, value[key])
    end

    if type(value.value) == 'table' then flattenArgs(out, value.value, seen) end
    if type(value.values) == 'table' then flattenArgs(out, value.values, seen) end
    if type(value.args) == 'table' then flattenArgs(out, value.args, seen) end
    if type(value.extra) == 'table' then flattenArgs(out, value.extra, seen) end

    for i = 1, #value do
        flattenArgs(out, value[i], seen)
    end
end

local function normalizePayload(staffSrc, actionName, target, args)
    local payload = nil
    local rawActionText = type(actionName) == 'string' and actionName or ''

    if type(actionName) == 'table' then
        payload = actionName
        rawActionText = tostring(payload.action or payload.Action or payload.actionName or payload.ActionName or payload.frameworkAction or payload.FrameworkAction or payload.label or payload.Label or payload.name or payload.Name or '')
        actionName = actionFromAny(payload)
        target = payload.target or payload.targetId or payload.Target or payload.TargetId or payload.source or payload.src or payload.player or payload.playerId or payload.context or target
        args = payload.args or payload.values or payload.value or payload.extra or args
    end

    local action = actionFromAny(actionName)
    if action == '' and type(payload) == 'table' then action = actionFromAny(payload) end

    local rawActionKey = compact(rawActionText ~= '' and rawActionText or actionName)
    local rawActionLooksLikeJob = isJobActionValue(rawActionKey)
    local rawActionLooksLikeMoney = isMoneyAccountValue(rawActionKey)

    local resolvedTarget = resolveSource(target, 0)

    if action == '' then
        local swappedAction = actionFromAny(target)
        local swappedTarget = resolveSource(actionName, 0)
        if swappedAction ~= '' and swappedTarget > 0 then
            action = swappedAction
            resolvedTarget = swappedTarget
            rawActionText = type(target) == 'string' and target or rawActionText
        end
    end

    if resolvedTarget <= 0 and type(payload) == 'table' then resolvedTarget = resolveSource(payload, 0) end
    if resolvedTarget <= 0 then resolvedTarget = oneOnlinePlayerFallback() end
    if resolvedTarget <= 0 then resolvedTarget = resolveSource(staffSrc, 0) end

    local flat = {}
    flattenArgs(flat, args)
    if #flat == 0 and type(payload) == 'table' then
        flattenArgs(flat, payload.value)
        flattenArgs(flat, payload.values)
        flattenArgs(flat, payload.extra)
        flattenArgs(flat, payload.args)
    end

    if action == '' and #flat > 0 then
        local maybe = actionFromAny(flat[1])
        if ACTION_ALIASES[compact(flat[1])] then
            action = maybe
            table.remove(flat, 1)
        end
    end

    if action == '' and type(payload) == 'table' then
        local value = type(payload.value) == 'table' and payload.value or {}
        if value.job or payload.job then action = 'setjob'
        elseif value.amount or payload.amount then action = 'addmoney'
        elseif value.plate or payload.plate then action = 'keys' end
    end

    if type(payload) ~= 'table' then payload = {} end

    if rawActionLooksLikeJob then
        action = 'setjob'
        payload.__forcedJob = rawActionKey
        local already = false
        for _, v in ipairs(flat) do if compact(v) == rawActionKey then already = true break end end
        if not already then table.insert(flat, 1, rawActionKey) end
    elseif rawActionLooksLikeMoney then
        action = 'addmoney'
        payload.__forcedAccount = rawActionKey == 'money' and 'cash' or rawActionKey
        local already = false
        for _, v in ipairs(flat) do if compact(v) == rawActionKey then already = true break end end
        if not already then table.insert(flat, 1, payload.__forcedAccount) end
        if #flat < 2 then table.insert(flat, 2, 1000) end
    end

    payload.__rawActionText = rawActionText

    return action, resolvedTarget, flat, payload
end

local function getMoneyViaCallback(src)
    local p = promise.new()
    local done = false

    local ok = azCall('GetPlayerMoney', src, function(_err, data)
        if done then return end
        done = true
        p:resolve(type(data) == 'table' and data or {})
    end)

    if not ok then
        return {}
    end

    SetTimeout(1000, function()
        if done then return end
        done = true
        p:resolve({})
    end)

    local data = Citizen.Await(p)
    return type(data) == 'table' and data or {}
end

local function getSnapshot(src)
    src = tonumber(src or 0) or 0
    if not isPlayerOnline(src) then return nil end

    local discordId = getDiscordIdentifier(src)
    local activeCharId = resolveActiveCharacter(src)

    local charRow = activeCharId and dbActiveCharacterRow(discordId, activeCharId) or nil
    local moneyRow = activeCharId and dbMoneyRow(discordId, activeCharId) or nil

    local fallbackSnap = nil
    local okSnap, snap = azCall('GetBridgePlayerSnapshot', src)
    if okSnap and type(snap) == 'table' then fallbackSnap = snap end

    local name = nil
    if charRow and tostring(charRow.name or '') ~= '' then
        name = tostring(charRow.name)
    end
    if not name then
        local okName, exportName = azFirst({ 'GetPlayerCharacterNameSync' }, src)
        if okName and exportName and tostring(exportName) ~= '' then name = tostring(exportName) end
    end
    name = name or (fallbackSnap and fallbackSnap.name) or GetPlayerName(src) or ('Player ' .. tostring(src))

    local job = ''
    if charRow and tostring(charRow.active_department or '') ~= '' then
        job = tostring(charRow.active_department):lower()
    end
    if job == '' then
        local okJob, exportJob = azFirst({ 'getPlayerJob', 'GetPlayerJob' }, src)
        if okJob and exportJob then job = tostring(exportJob):lower() end
    end
    if job == '' and fallbackSnap then job = tostring(fallbackSnap.job or (type(fallbackSnap.jobInfo) == 'table' and fallbackSnap.jobInfo.name) or ''):lower() end
    if job == '' then job = 'unemployed' end

    local cash = tonumber(moneyRow and moneyRow.cash) or nil
    local bank = tonumber(moneyRow and moneyRow.bank) or nil
    if cash == nil or bank == nil then
        local okCash, exportCash = azCall('GetBridgeMoney', src, 'cash')
        local okBank, exportBank = azCall('GetBridgeMoney', src, 'bank')
        if cash == nil and okCash then cash = tonumber(exportCash) end
        if bank == nil and okBank then bank = tonumber(exportBank) end
    end
    if (cash == nil or bank == nil) and fallbackSnap then
        local m = type(fallbackSnap.money) == 'table' and fallbackSnap.money or fallbackSnap
        if cash == nil then cash = tonumber(m.cash or m.money) end
        if bank == nil then bank = tonumber(m.bank) end
    end
    cash = tonumber(cash or 0) or 0
    bank = tonumber(bank or 0) or 0

    local charid = tostring(activeCharId or '')
    if charid == '' then charid = 'unknown' end

    return {
        source = src,
        id = src,
        name = name,
        citizenid = charid,
        charid = charid,
        charId = charid,
        framework = 'Azure',
        job = job,
        jobInfo = { name = job, label = job, grade = 0, rank = 0, onduty = true },
        grade = 0,
        onduty = true,
        cash = cash,
        bank = bank,
        money = { cash = cash, bank = bank }
    }
end

local function playersForMenu()
    local list = {}
    for _, id in ipairs(GetPlayers()) do
        local src = tonumber(id) or 0
        local snap = getSnapshot(src)
        if snap then list[#list + 1] = snap end
    end
    table.sort(list, function(a, b) return (tonumber(a.source) or 0) < (tonumber(b.source) or 0) end)
    return list
end

local function jobFromArgs(flat, payload)
    payload = type(payload) == 'table' and payload or {}
    local value = type(payload.value) == 'table' and payload.value or {}

    local job = payload.__forcedJob or payload.job or payload.jobName or value.job or value.jobName
    local grade = payload.grade or payload.rank or value.grade or value.rank or 0

    local raw = tostring(payload.__rawActionText or '')
    if not job and raw ~= '' then
        local labelJob = raw:match('[Jj]ob:%s*([%w_%-]+)') or raw:match('[Ss]et%s+[Jj]ob%s+([%w_%-]+)')
        if labelJob then job = labelJob end
    end

    for _, v in ipairs(flat or {}) do
        local text = trim(v)
        local key = compact(text)
        if text ~= '' and not tonumber(text) and isJobActionValue(key) and (not job or job == '') then
            job = key
        elseif text ~= '' and not tonumber(text) and actionFromString(text) ~= text and not isJobActionValue(key) then

        elseif text ~= '' and not tonumber(text) and (not job or job == '') then
            job = text
        elseif tonumber(text) and (not grade or tonumber(grade) == 0) then
            grade = tonumber(text)
        end
    end

    job = lower(job)
    grade = tonumber(grade or 0) or 0
    return job, grade
end

local function moneyFromArgs(flat, payload)
    payload = type(payload) == 'table' and payload or {}
    local value = type(payload.value) == 'table' and payload.value or {}

    local account = payload.__forcedAccount or value.account or value.moneyType or value.type or payload.account or payload.moneyType or payload.type
    local amount = value.amount or payload.amount

    for _, v in ipairs(flat or {}) do
        local text = lower(v)
        if tonumber(text) and not amount then
            amount = tonumber(text)
        elseif text == 'cash' or text == 'money' or text == 'bank' then
            account = text
        end
    end

    if not account or account == '' then account = 'cash' end
    account = lower(account)
    if account == 'money' then account = 'cash' end

    amount = math.floor(tonumber(amount or 0) or 0)
    if amount <= 0 and payload.__forcedAccount then amount = 1000 end
    return account, amount
end

local function addMoney(src, account, amount, reason)
    account = lower(account)
    if account == 'money' then account = 'cash' end
    amount = math.floor(tonumber(amount or 0) or 0)
    if not isPlayerOnline(src) or amount <= 0 then return false end

    local ok, result = azFirst({ 'AddBridgeMoney', 'addBridgeMoney' }, src, account, amount, reason or 'vMenu Bridge')
    if ok and result == true then
        azCall('sendMoneyToClient', src, true)
        return true
    end

    if account == 'cash' then
        ok, result = azFirst({ 'AddMoney', 'addMoney' }, src, amount, reason or 'vMenu Bridge')
        if ok and result == true then
            azCall('sendMoneyToClient', src, true)
            return true
        end
    end

    local directOk, directErr = directMoney(src, account, amount, 'add')
    if directOk then return true end
    debugPrint('addMoney fallback failed', src, account, amount, directErr or '')
    return false
end

local function removeMoney(src, account, amount, reason)
    account = lower(account)
    if account == 'money' then account = 'cash' end
    amount = math.floor(tonumber(amount or 0) or 0)
    if not isPlayerOnline(src) or amount <= 0 then return false end

    local ok, result = azFirst({ 'RemoveBridgeMoney', 'removeBridgeMoney' }, src, account, amount, reason or 'vMenu Bridge')
    if ok and result == true then
        azCall('sendMoneyToClient', src, true)
        return true
    end

    if account == 'cash' then
        ok, result = azFirst({ 'DeductMoney', 'deductMoney' }, src, amount, reason or 'vMenu Bridge')
        if ok and result == true then
            azCall('sendMoneyToClient', src, true)
            return true
        end
    end

    local directOk, directErr = directMoney(src, account, amount, 'remove')
    if directOk then return true end
    debugPrint('removeMoney fallback failed', src, account, amount, directErr or '')
    return false
end

local function setJob(src, job, grade)
    job = lower(job)
    grade = tonumber(grade or 0) or 0
    if not isPlayerOnline(src) or job == '' then return false end

    local ok, result = azFirst({ 'setPlayerJob', 'SetPlayerJob' }, src, job, grade)
    if ok and result == true then
        TriggerClientEvent('hud:setDepartment', src, job)
        TriggerEvent('Az-Framework:jobChanged', src, job, nil)
        TriggerClientEvent('Az-Framework:jobChanged', src, job, nil)
        TriggerEvent('vMenu:QBCore:RefreshPermissions', src)
        debugPrint('setJob success', src, job, grade)
        return true
    end

    local directOk, directErr = directSetJob(src, job, grade)
    if directOk then return true end
    debugPrint('setJob failed', src, job, grade, directErr or '')
    return false
end

local function runPlayerAction(staffSrc, actionName, target, args)
    local action, resolvedTarget, flat, payload = normalizePayload(staffSrc, actionName, target, args)

    debugPrint('RunPlayerAction staff=', staffSrc, 'action=', action, 'target=', resolvedTarget, 'args=', json.encode(flat or {}))

    if action == '' then
        return { ok = false, message = 'Missing Az action.' }
    end

    if not isPlayerOnline(resolvedTarget) then
        return { ok = false, message = 'Target player not found.' }
    end

    if Config.RequireAdminForManagement ~= false and not hasAdmin(staffSrc) then
        return { ok = false, message = 'No vMenu/Az management permission.' }
    end

    if action == 'info' then
        local snap = getSnapshot(resolvedTarget) or {}
        local money = snap.money or {}
        local job = snap.jobInfo or { name = snap.job or 'unemployed' }
        local display = ('%s | ID: %s | Char: %s | Job: %s | Cash: $%s | Bank: $%s | Framework: Azure'):format(
            tostring(snap.name or GetPlayerName(resolvedTarget) or ('Player ' .. resolvedTarget)),
            tostring(resolvedTarget),
            tostring(snap.charid or snap.citizenid or 'unknown'),
            tostring(job.name or snap.job or 'unemployed'),
            tostring(money.cash or 0),
            tostring(money.bank or 0)
        )
        return { ok = true, message = 'Azure player info opened.', title = 'Azure Player Info', displayText = display }
    end

    if action == 'setjob' then
        local job, grade = jobFromArgs(flat, payload)
        if job == '' then return { ok = false, message = 'Missing Az job name.' } end
        local ok = setJob(resolvedTarget, job, grade)
        return { ok = ok, message = ok and ('Az job set to %s.'):format(job) or 'Az set job export failed.' }
    end

    if action == 'addmoney' or action == 'removemoney' then
        local account, amount = moneyFromArgs(flat, payload)
        if amount <= 0 then return { ok = false, message = 'Invalid Az money amount.' } end
        local ok = action == 'addmoney'
            and addMoney(resolvedTarget, account, amount, 'vMenu admin add money')
            or removeMoney(resolvedTarget, account, amount, 'vMenu admin remove money')
        return { ok = ok, message = ok and ('Az %s %s $%s.'):format(action == 'addmoney' and 'added' or 'removed', account, amount) or 'Az money export failed.' }
    end

    if action == 'revive' then
        TriggerClientEvent('az-vmenu-qb:client:playerAction', resolvedTarget, 'revive')
        TriggerClientEvent('vmenu_ui:qbPlayerAction', resolvedTarget, 'revive')
        return { ok = true, message = 'Az revive sent.' }
    end

    if action == 'heal' then
        TriggerClientEvent('az-vmenu-qb:client:playerAction', resolvedTarget, 'heal')
        TriggerClientEvent('vmenu_ui:qbPlayerAction', resolvedTarget, 'heal')
        return { ok = true, message = 'Az heal sent.' }
    end

    if action == 'duty' then
        return { ok = true, message = 'Az uses active department/job, not QBCore duty. Use Set Job.' }
    end

    if action == 'save' then
        azCall('sendMoneyToClient', resolvedTarget)
        return { ok = true, message = 'Az player HUD refreshed.' }
    end

    if action == 'kick' then
        local reason = 'Kicked by staff.'
        for _, v in ipairs(flat or {}) do
            local t = trim(v)
            if t ~= '' then reason = t break end
        end
        DropPlayer(resolvedTarget, reason)
        return { ok = true, message = 'Player kicked.' }
    end

    if action == 'keys' then
        local plate = ''
        for _, v in ipairs(flat or {}) do
            local t = trim(v)
            if t ~= '' then plate = t break end
        end
        local ok = false
        if Config.Keys and Config.Keys.ServerEvent and Config.Keys.ServerEvent ~= '' then
            TriggerEvent(Config.Keys.ServerEvent, resolvedTarget, plate)
            ok = true
        end
        if Config.Keys and Config.Keys.ClientEvent and Config.Keys.ClientEvent ~= '' then
            TriggerClientEvent(Config.Keys.ClientEvent, resolvedTarget, plate)
            ok = true
        end
        return { ok = true, message = ok and 'Key event sent.' or 'No Az key event configured; action accepted.' }
    end

    return { ok = false, message = ('Unknown Az action: %s.'):format(tostring(action)) }
end

local function canUseVehicleSpawner(src)
    src = tonumber(src or 0) or 0
    if src == 0 then return true, 'console' end
    if hasAdmin(src) then return true, 'admin' end
    if Config.RestrictVehicleSpawner ~= true then return true, 'open' end

    local snap = getSnapshot(src)
    local job = lower(snap and (snap.job or (snap.jobInfo and snap.jobInfo.name)) or '')
    if job ~= '' and Config.AllowedVehicleJobs and Config.AllowedVehicleJobs[job] then
        return true, job
    end

    return false, job ~= '' and job or 'no_job'
end

local function getSpawnCost(src, vehicleClass)
    if hasAdmin(src) then return 0 end
    local costs = Config.SpawnCosts or {}
    local classId = tonumber(vehicleClass) or -1
    local amount = tonumber(costs.Default or 0) or 0
    if type(costs.Classes) == 'table' and costs.Classes[classId] ~= nil then
        amount = tonumber(costs.Classes[classId]) or amount
    end
    return math.max(0, math.floor(amount))
end

local function chargePlayer(src, amount, reason)
    amount = math.floor(tonumber(amount or 0) or 0)
    if amount <= 0 then return true, 'free' end
    if removeMoney(src, 'cash', amount, reason or 'vMenu vehicle spawn') then return true, 'cash' end
    if removeMoney(src, 'bank', amount, reason or 'vMenu vehicle spawn') then return true, 'bank' end
    return false, 'none'
end

local function giveKeys(src, plate, netId, modelHash)
    src = tonumber(src or 0) or 0
    plate = trim(plate)
    if src <= 0 then return false end

    local sent = false
    if Config.Keys and Config.Keys.ServerEvent and Config.Keys.ServerEvent ~= '' then
        TriggerEvent(Config.Keys.ServerEvent, src, plate, netId, modelHash)
        sent = true
    end
    if Config.Keys and Config.Keys.ClientEvent and Config.Keys.ClientEvent ~= '' then
        TriggerClientEvent(Config.Keys.ClientEvent, src, plate, netId, modelHash)
        sent = true
    end
    return sent
end

exports('GetDetectedFramework', function()
    return 'az', 'Azure Framework'
end)

exports('GetStateForMenu', function(src)
    src = tonumber(src or source or 0) or 0
    local azStarted = GetResourceState(AZ_RESOURCE) == 'started'
    local admin = hasAdmin(src)
    local canSpawn, spawnReason = canUseVehicleSpawner(src)
    return {
        enabled = true,
        coreStarted = azStarted,
        framework = 'az',
        frameworkName = 'az',
        frameworkLabel = 'Azure Framework',
        label = 'Azure Framework',
        resource = AZ_RESOURCE,
        source = src,
        canAccessMenu = admin,
        canUseVehicleSpawner = canSpawn == true,
        vehicleSpawnerReason = spawnReason or '',
        player = getSnapshot(src),
        players = admin and playersForMenu() or {}
    }
end)

exports('GetPlayersForMenu', function()
    return playersForMenu()
end)

local function looksLikePayloadTable(value)
    if type(value) ~= 'table' then return false end
    return value.action ~= nil
        or value.Action ~= nil
        or value.actionName ~= nil
        or value.ActionName ~= nil
        or value.frameworkAction ~= nil
        or value.FrameworkAction ~= nil
        or value.target ~= nil
        or value.targetId ~= nil
        or value.Target ~= nil
        or value.TargetId ~= nil
        or value.source ~= nil
        or value.src ~= nil
        or value.args ~= nil
        or value.values ~= nil
        or value.value ~= nil
        or value.job ~= nil
        or value.jobName ~= nil
        or value.amount ~= nil
        or value.plate ~= nil
end

local function collectExportArgs(values, startIndex)
    local out = {}
    for i = startIndex, #values do
        local value = values[i]
        if value ~= nil then out[#out + 1] = value end
    end
    if #out == 1 and type(out[1]) == 'table' then return out[1] end
    return out
end

local function runPlayerActionExport(...)
    local values = { ... }

    if type(values[1]) == 'table' and not looksLikePayloadTable(values[1]) and #values >= 2 then
        table.remove(values, 1)
    end

    if #values == 1 and type(values[1]) == 'table' and looksLikePayloadTable(values[1]) then
        return runPlayerAction(tonumber(source or 0) or 0, values[1], nil, nil)
    end

    local staffSrc, actionName, target, args

    if type(values[1]) == 'string' and (tonumber(values[2] or 0) or 0) > 0 then

        staffSrc = tonumber(source or 0) or 0
        actionName = values[1]
        target = values[2]
        args = collectExportArgs(values, 3)
    else

        staffSrc = tonumber(values[1] or source or 0) or 0
        actionName = values[2]
        target = values[3]
        args = collectExportArgs(values, 4)
    end

    return runPlayerAction(staffSrc, actionName, target, args)
end

exports('RunPlayerAction', function(...)
    return runPlayerActionExport(...)
end)

exports('CanUseVehicleSpawner', function(src)
    return canUseVehicleSpawner(tonumber(src or source or 0) or 0)
end)

exports('GetSpawnCost', function(src, vehicleClass)
    return getSpawnCost(tonumber(src or source or 0) or 0, vehicleClass)
end)

exports('ChargePlayer', function(src, amount, reason)
    return chargePlayer(tonumber(src or source or 0) or 0, amount, reason)
end)

exports('GiveKeys', function(src, plate, netId, modelHash)
    return giveKeys(src, plate, netId, modelHash)
end)

exports('AddMoney', function(src, account, amount, reason)
    return addMoney(src, account, amount, reason)
end)

exports('RemoveMoney', function(src, account, amount, reason)
    return removeMoney(src, account, amount, reason)
end)

exports('RefreshPlayerAccess', function(src)
    TriggerEvent('vMenu:QBCore:RefreshPermissions', tonumber(src or 0) or 0)
    return true
end)

exports('IsBridgeAdmin', function(src)
    return hasAdmin(tonumber(src or source or 0) or 0)
end)

RegisterNetEvent('vMenu:QBCore:RequestPlayers', function()
    local src = source
    if src ~= 0 and not hasAdmin(src) then
        TriggerClientEvent('vMenu:QBCore:ReceivePlayers', src, json.encode({}))
        return
    end
    TriggerClientEvent('vMenu:QBCore:ReceivePlayers', src, json.encode(playersForMenu()))
end)

RegisterNetEvent('vMenu:QBCore:RunPlayerAction', function(actionName, target, a, b, c, d)
    local src = source
    local args = {}
    local values = { a, b, c, d }
    for i = 1, 4 do
        local value = values[i]
        if value ~= nil then args[#args + 1] = value end
    end
    local result = runPlayerAction(src, actionName, target, args)
    notify(src, result.message or 'Done.', result.ok and 'success' or 'error', result.ok and 5000 or 8000)
end)

RegisterNetEvent('vMenu:QBCore:CanSpawnVehicle', function(requestId, modelHash, vehicleClass)
    local src = source
    requestId = tonumber(requestId) or 0

    local allowed, reason = canUseVehicleSpawner(src)
    if not allowed then
        TriggerClientEvent('vMenu:QBCore:SpawnVehicleResponse', src, requestId, false, ('Az vehicle spawn blocked: %s'):format(tostring(reason or 'not allowed')), 0)
        return
    end

    local cost = getSpawnCost(src, vehicleClass)
    local paid, account = chargePlayer(src, cost, ('vMenu vehicle spawn class %s'):format(tostring(vehicleClass)))
    if not paid then
        TriggerClientEvent('vMenu:QBCore:SpawnVehicleResponse', src, requestId, false, ('Need $%s cash/bank to spawn this vehicle.'):format(cost), cost)
        return
    end

    TriggerClientEvent('vMenu:QBCore:SpawnVehicleResponse', src, requestId, true, cost > 0 and ('$' .. cost .. ' charged from ' .. tostring(account)) or 'Vehicle spawn approved.', cost)
end)

RegisterNetEvent('vMenu:QBCore:VehicleSpawned', function(netId, plate, modelHash, vehicleClass, cost)
    local src = source
    giveKeys(src, plate, netId, modelHash)
    TriggerClientEvent('az-vmenu-qb:client:applySpawnedVehicle', src, netId, plate, tostring(modelHash or ''), tonumber(vehicleClass) or -1, tonumber(cost) or 0)
end)

RegisterNetEvent('vMenu:QBCore:RefreshPermissions', function(target)
    local src = tonumber(target or source or 0) or 0
    if src > 0 then
        TriggerClientEvent('vMenu:QBCore:PermissionsRefreshed', src)
        TriggerClientEvent('vMenu:QBCore:ReceivePlayers', src, json.encode(playersForMenu()))
    end
end)

AddEventHandler('Az-Framework:jobChanged', function(changedSrc)
    local src = tonumber(changedSrc or source or 0) or 0
    if src > 0 then TriggerEvent('vMenu:QBCore:RefreshPermissions', src) end
end)

AddEventHandler('Az-Framework:characterSelected', function(changedSrc)
    local src = tonumber(changedSrc or source or 0) or 0
    if src > 0 then TriggerEvent('vMenu:QBCore:RefreshPermissions', src) end
end)

AddEventHandler('Az-Framework:Bridge:characterSelected', function(changedSrc)
    local src = tonumber(changedSrc or source or 0) or 0
    if src > 0 then TriggerEvent('vMenu:QBCore:RefreshPermissions', src) end
end)

local function runAzVmCommand(src, args)
    args = type(args) == 'table' and args or {}
    local sub = lower(args[1])
    if sub == '' then
        notify(src, 'Usage: /azvm active [id] | info [id] | setjob [id] police 0 | addmoney [id] cash 1000 | removemoney [id] cash 100', 'inform', 9000)
        return
    end

    local target = resolveSource(args[2], src)
    if target <= 0 then target = oneOnlinePlayerFallback() end
    if target <= 0 then
        notify(src, 'No target player found.', 'error')
        return
    end

    local result
    if sub == 'active' or sub == 'char' or sub == 'character' then
        local okA, active = azFirst({ 'GetActiveCharacter', 'getActiveCharacter', 'GetCharacter', 'getCharacter' }, target)
        local okP, playerChar = azFirst({ 'GetPlayerCharacter', 'getPlayerCharacter' }, target)
        local snap = getSnapshot(target) or {}
        result = {
            ok = true,
            message = 'Azure active-character debug opened.',
            displayText = ('Target %s | active=%s | playerChar=%s | snapshotChar=%s | name=%s | job=%s | cash=$%s | bank=$%s'):format(
                tostring(target),
                tostring((okA and active) or 'nil'),
                tostring((okP and playerChar) or 'nil'),
                tostring(snap.charid or snap.citizenid or 'nil'),
                tostring(snap.name or 'nil'),
                tostring(snap.job or (snap.jobInfo and snap.jobInfo.name) or 'nil'),
                tostring((snap.money and snap.money.cash) or snap.cash or 0),
                tostring((snap.money and snap.money.bank) or snap.bank or 0)
            )
        }
    elseif sub == 'info' then
        result = runPlayerAction(src, 'info', target, {})
    elseif sub == 'setjob' then
        result = runPlayerAction(src, 'setjob', target, { args[3] or 'unemployed', args[4] or 0 })
    elseif sub == 'addmoney' then
        result = runPlayerAction(src, 'addmoney', target, { args[3] or 'cash', args[4] or 1000 })
    elseif sub == 'removemoney' then
        result = runPlayerAction(src, 'removemoney', target, { args[3] or 'cash', args[4] or 100 })
    else
        result = { ok = false, message = 'Unknown azvm action.' }
    end

    notify(src, result.message or 'Done.', result.ok and 'success' or 'error', 8000)
    if result.displayText then notify(src, result.displayText, 'inform', 10000) end
end

RegisterCommand('azvmtest', function(src, args)
    runAzVmCommand(src, args)
end, false)

RegisterCommand('azvm', function(src, args)
    runAzVmCommand(src, args)
end, false)

CreateThread(function()
    Wait(1000)
    if GetResourceState(AZ_RESOURCE) ~= 'started' then
        print(('^1[%s]^7 Waiting for %s. Start order must be: ensure %s, ensure %s, ensure vMenu'):format(RESOURCE, AZ_RESOURCE, AZ_RESOURCE, RESOURCE))
    else
        print(('^2[%s]^7 AZ-ONLY bridge V20 loaded. Using %s exports directly.'):format(RESOURCE, AZ_RESOURCE))
    end
end)
