local RESOURCE = GetCurrentResourceName()

local function trim(value)
    return tostring(value or ''):gsub('^%s+', ''):gsub('%s+$', '')
end

local function lower(value)
    return trim(value):lower()
end

local function debugPrint(...)
    if not Config.Debug then return end
    local parts = {}
    for i = 1, select('#', ...) do
        parts[#parts + 1] = tostring(select(i, ...))
    end
    print(('^3[%s]^7 %s'):format(RESOURCE, table.concat(parts, ' ')))
end

local function frameworkConfig()
    Config.Framework = Config.Framework or {}
    Config.Framework.Resources = Config.Framework.Resources or {}
    return Config.Framework
end

local function isStarted(resource)
    resource = tostring(resource or '')
    return resource ~= '' and GetResourceState(resource) == 'started'
end

local function isPlayerOnline(src)
    src = tonumber(src or 0) or 0
    return src > 0 and GetPlayerName(src) ~= nil
end

local function callMethod(target, name, ...)
    if not target or not name then return false, nil, 'missing_target' end
    local okFn, fn = pcall(function() return target[name] end)
    if not okFn or type(fn) ~= 'function' then return false, nil, 'missing_method' end

    local ok, a, b, c, d = pcall(fn, ...)
    if ok then return true, a, b, c, d end

    local firstErr = a
    ok, a, b, c, d = pcall(fn, target, ...)
    if ok then return true, a, b, c, d end

    return false, nil, tostring(a or firstErr or 'method_failed')
end

local function getExports(resource)
    if not isStarted(resource) then return nil end
    local ok, exp = pcall(function() return exports[resource] end)
    if ok then return exp end
    return nil
end

local function callExport(resource, name, ...)
    local exp = getExports(resource)
    if not exp then return false, nil, 'exports_unavailable' end
    return callMethod(exp, name, ...)
end

local FRAMEWORK_LABELS = {
    az = 'Az-Framework',
    esx = 'ESX Legacy',
    nd = 'NDCore',
    qb = 'QBCore',
    standalone = 'Standalone'
}

local function configuredResource(key)
    local cfg = frameworkConfig()
    local resources = cfg.Resources or {}
    return resources[key] or ({ az = 'Az-Framework', esx = 'es_extended', nd = 'ND_Core', qb = 'qb-core' })[key]
end

local function detectFramework()
    local cfg = frameworkConfig()
    local mode = lower(cfg.Mode or 'auto')
    if mode == 'ndcore' or mode == 'nd_core' then mode = 'nd' end
    if mode == 'qbcore' or mode == 'qb-core' then mode = 'qb' end
    if mode == 'azure' or mode == 'az-framework' then mode = 'az' end
    if mode == 'es_extended' then mode = 'esx' end

    if mode ~= '' and mode ~= 'auto' then
        if mode == 'standalone' then return 'standalone', FRAMEWORK_LABELS.standalone, '' end
        local res = configuredResource(mode)
        if isStarted(res) then return mode, FRAMEWORK_LABELS[mode] or mode, res end
        return 'standalone', FRAMEWORK_LABELS.standalone, res or ''
    end

    local priority = cfg.Priority or { 'az', 'esx', 'nd', 'qb' }
    for _, key in ipairs(priority) do
        key = lower(key)
        if key == 'ndcore' then key = 'nd' end
        if key == 'qbcore' then key = 'qb' end
        local res = configuredResource(key)
        if isStarted(res) then return key, FRAMEWORK_LABELS[key] or key, res end
    end

    return 'standalone', FRAMEWORK_LABELS.standalone, ''
end

local function getESX()
    local resource = configuredResource('esx') or 'es_extended'
    if not isStarted(resource) then return nil end
    local ok, obj = callExport(resource, 'getSharedObject')
    if ok and obj then return obj end
    if ESX then return ESX end
    return nil
end

local function getQBCore()
    local resource = configuredResource('qb') or 'qb-core'
    if not isStarted(resource) then return nil end
    local ok, obj = callExport(resource, 'GetCoreObject')
    if ok and obj then return obj end
    if QBCore then return QBCore end
    return nil
end

local function getNDCore()
    local resource = configuredResource('nd') or 'ND_Core'
    if not isStarted(resource) then return nil end
    local exp = getExports(resource)
    if exp then return exp end
    if NDCore then return NDCore end
    return nil
end

local function getAzResource()
    return configuredResource('az') or Config.AzResource or 'Az-Framework'
end

local function azCall(exportName, ...)
    return callExport(getAzResource(), exportName, ...)
end

local function notify(src, message, msgType, duration)
    src = tonumber(src or 0) or 0
    if src <= 0 then
        print(('[%s] %s'):format(RESOURCE, tostring(message or '')))
        return
    end

    local fw = select(1, detectFramework())
    if fw == 'az' then
        local ok, result = azCall('BridgeNotify', src, tostring(message or ''), msgType or 'inform', tonumber(duration) or 5000)
        if ok and result ~= false then return end
    end

    if Config.Notifications and Config.Notifications.UseOxLibFallback then
        TriggerClientEvent('ox_lib:notify', src, {
            title = (Config.Notifications and Config.Notifications.Title) or 'AMenu Bridge',
            description = tostring(message or ''),
            type = msgType or 'inform',
            duration = tonumber(duration) or 5000
        })
    end

    TriggerClientEvent('chat:addMessage', src, {
        args = { '^3AMenu Bridge', tostring(message or '') }
    })
end

local function getIdentifier(src, prefix)
    for _, id in ipairs(GetPlayerIdentifiers(tonumber(src or 0) or 0) or {}) do
        if not prefix or id:sub(1, #prefix) == prefix then return id end
    end
    return ''
end

local function getESXPlayer(src)
    local ESXObj = getESX()
    if not ESXObj then return nil end
    local ok, player = callMethod(ESXObj, 'GetPlayerFromId', tonumber(src))
    if ok and player then return player end
    ok, player = callMethod(ESXObj, 'Player', tonumber(src))
    if ok and player then return player end
    return nil
end

local function getNDPlayer(src)
    local nd = getNDCore()
    if not nd then return nil end
    local ok, player = callMethod(nd, 'getPlayer', tonumber(src))
    if ok and player then return player end
    ok, player = callMethod(nd, 'GetPlayer', tonumber(src))
    if ok and player then return player end
    return nil
end

local function getQBPlayer(src)
    local core = getQBCore()
    if not core or not core.Functions then return nil end
    local ok, player = callMethod(core.Functions, 'GetPlayer', tonumber(src))
    if ok and player then return player end
    ok, player = callMethod(core.Functions, 'GetPlayer', tostring(src))
    if ok and player then return player end
    return nil
end

local function getAzSnapshot(src)
    local snap
    local ok = false
    ok, snap = azCall('GetBridgePlayerSnapshot', src)
    if ok and type(snap) == 'table' then return snap end

    local name = GetPlayerName(src) or ('Player ' .. tostring(src))
    local job = 'unemployed'
    local cash, bank = 0, 0

    ok, job = azCall('getPlayerJob', src)
    if not ok or not job then ok, job = azCall('GetPlayerJob', src) end
    ok, cash = azCall('GetBridgeMoney', src, 'cash')
    if not ok then cash = 0 end
    ok, bank = azCall('GetBridgeMoney', src, 'bank')
    if not ok then bank = 0 end

    return {
        source = src,
        id = src,
        name = name,
        citizenid = getIdentifier(src, 'license:'),
        charid = getIdentifier(src, 'license:'),
        framework = 'Az-Framework',
        job = lower(job or 'unemployed'),
        jobInfo = { name = lower(job or 'unemployed'), label = tostring(job or 'Unemployed'), grade = 0, rank = 0, onduty = true },
        grade = 0,
        onduty = true,
        cash = tonumber(cash or 0) or 0,
        bank = tonumber(bank or 0) or 0,
        money = { cash = tonumber(cash or 0) or 0, bank = tonumber(bank or 0) or 0 }
    }
end

local function getMoneyAccountFromESX(xPlayer, account)
    account = account == 'cash' and 'money' or account
    if account == 'money' then
        local ok, value = callMethod(xPlayer, 'getMoney')
        if ok and tonumber(value) then return tonumber(value) end
    end
    local ok, data = callMethod(xPlayer, 'getAccount', account)
    if ok and type(data) == 'table' then return tonumber(data.money or data.amount or data.balance or 0) or 0 end
    return 0
end

local function getSnapshot(src)
    src = tonumber(src or 0) or 0
    if not isPlayerOnline(src) then return nil end

    local fw, label = detectFramework()

    if fw == 'az' then
        local snap = getAzSnapshot(src)
        snap.framework = label
        return snap
    end

    if fw == 'esx' then
        local xPlayer = getESXPlayer(src)
        if not xPlayer then return nil end
        local okName, name = callMethod(xPlayer, 'getName')
        local okId, identifier = callMethod(xPlayer, 'getIdentifier')
        local okJob, job = callMethod(xPlayer, 'getJob')
        job = type(job) == 'table' and job or {}
        local grade = tonumber(job.grade or job.grade_level or 0) or 0
        local cash = getMoneyAccountFromESX(xPlayer, 'cash')
        local bank = getMoneyAccountFromESX(xPlayer, 'bank')
        return {
            source = src,
            id = src,
            name = tostring((okName and name) or GetPlayerName(src) or ('Player ' .. src)),
            citizenid = tostring((okId and identifier) or getIdentifier(src, 'license:') or 'unknown'),
            charid = tostring((okId and identifier) or getIdentifier(src, 'license:') or 'unknown'),
            framework = label,
            job = tostring(job.name or 'unemployed'),
            jobLabel = tostring(job.label or job.name or 'Unemployed'),
            jobInfo = { name = tostring(job.name or 'unemployed'), label = tostring(job.label or job.name or 'Unemployed'), grade = grade, rank = grade, onduty = job.onDuty ~= false },
            grade = grade,
            onduty = job.onDuty ~= false,
            cash = cash,
            bank = bank,
            money = { cash = cash, bank = bank }
        }
    end

    if fw == 'nd' then
        local player = getNDPlayer(src)
        if not player then return nil end
        local okJob, jobName, jobInfo = callMethod(player, 'getJob')
        if not okJob then jobName, jobInfo = 'unemployed', {} end
        jobInfo = type(jobInfo) == 'table' and jobInfo or {}
        local function getData(key)
            local ok, value = callMethod(player, 'getData', key)
            if ok then return value end
        end
        local moneyData = getData('money') or getData('accounts') or {}
        local cash = tonumber(player.cash or player.money or (type(moneyData) == 'table' and (moneyData.cash or moneyData.money)) or getData('cash') or 0) or 0
        local bank = tonumber(player.bank or (type(moneyData) == 'table' and moneyData.bank) or getData('bank') or 0) or 0
        local fullName = getData('fullname') or getData('name') or trim((player.firstname or '') .. ' ' .. (player.lastname or ''))
        if fullName == '' then fullName = GetPlayerName(src) or ('Player ' .. tostring(src)) end
        local identifier = player.id or player.identifier or player.citizenid or player.characterId or player.charid or getIdentifier(src, 'license:')
        local grade = tonumber(jobInfo.rank or jobInfo.grade or 0) or 0
        return {
            source = src,
            id = src,
            name = tostring(fullName),
            citizenid = tostring(identifier or 'unknown'),
            charid = tostring(identifier or 'unknown'),
            framework = label,
            job = tostring(jobName or 'unemployed'),
            jobLabel = tostring(jobInfo.label or jobName or 'Unemployed'),
            jobInfo = { name = tostring(jobName or 'unemployed'), label = tostring(jobInfo.label or jobName or 'Unemployed'), grade = grade, rank = grade, onduty = true },
            grade = grade,
            onduty = true,
            cash = cash,
            bank = bank,
            money = { cash = cash, bank = bank }
        }
    end

    if fw == 'qb' then
        local Player = getQBPlayer(src)
        if not Player or not Player.PlayerData then return nil end
        local pdata = Player.PlayerData
        local job = pdata.job or {}
        local gradeData = type(job.grade) == 'table' and job.grade or {}
        local grade = tonumber(gradeData.level or job.grade or 0) or 0
        local money = pdata.money or {}
        local name = GetPlayerName(src) or pdata.name or ('Player ' .. tostring(src))
        if type(pdata.charinfo) == 'table' then
            local full = trim((pdata.charinfo.firstname or '') .. ' ' .. (pdata.charinfo.lastname or ''))
            if full ~= '' then name = full end
        end
        return {
            source = src,
            id = src,
            name = tostring(name),
            citizenid = tostring(pdata.citizenid or getIdentifier(src, 'license:') or 'unknown'),
            charid = tostring(pdata.citizenid or getIdentifier(src, 'license:') or 'unknown'),
            framework = label,
            job = tostring(job.name or 'unemployed'),
            jobLabel = tostring(job.label or job.name or 'Unemployed'),
            jobInfo = { name = tostring(job.name or 'unemployed'), label = tostring(job.label or job.name or 'Unemployed'), grade = grade, rank = grade, onduty = job.onduty == true },
            grade = grade,
            onduty = job.onduty == true,
            cash = tonumber(money.cash or 0) or 0,
            bank = tonumber(money.bank or 0) or 0,
            money = { cash = tonumber(money.cash or 0) or 0, bank = tonumber(money.bank or 0) or 0 }
        }
    end

    return {
        source = src,
        id = src,
        name = GetPlayerName(src) or ('Player ' .. tostring(src)),
        citizenid = getIdentifier(src, 'license:') or 'unknown',
        charid = getIdentifier(src, 'license:') or 'unknown',
        framework = label,
        job = 'unemployed',
        jobInfo = { name = 'unemployed', label = 'Unemployed', grade = 0, rank = 0, onduty = true },
        grade = 0,
        onduty = true,
        cash = 0,
        bank = 0,
        money = { cash = 0, bank = 0 }
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

local function hasAdmin(src)
    src = tonumber(src or 0) or 0
    if src == 0 then return true end

    local cfg = frameworkConfig()
    local aces = cfg.AdminAces or Config.AdminAces or {}
    for _, ace in ipairs(aces) do
        ace = tostring(ace or '')
        if ace ~= '' and IsPlayerAceAllowed(src, ace) then return true end
    end

    local fw = select(1, detectFramework())

    if fw == 'az' then
        local ok, result = azCall('isAdmin', src)
        if ok and result == true then return true end
        ok, result = azCall('IsAdmin', src)
        if ok and result == true then return true end
    elseif fw == 'esx' then
        local xPlayer = getESXPlayer(src)
        if xPlayer then
            local groups = cfg.ESXAdminGroups or {}
            local ok, group = callMethod(xPlayer, 'getGroup')
            group = tostring((ok and group) or xPlayer.group or ''):lower()
            if groups[group] then return true end
            if xPlayer.admin == true then return true end
        end
    elseif fw == 'nd' then
        local player = getNDPlayer(src)
        if player then
            for group, minRank in pairs(cfg.NDAdminGroups or {}) do
                local ok, data = callMethod(player, 'getGroup', group)
                if ok and type(data) == 'table' then
                    local rank = tonumber(data.rank or data.grade or 0) or 0
                    if rank >= (tonumber(minRank) or 0) then return true end
                elseif ok and data then
                    return true
                end
            end
        end
    elseif fw == 'qb' then
        local core = getQBCore()
        if core and core.Functions then
            for _, perm in ipairs(cfg.QBCoreAdminPermissions or { 'god', 'admin' }) do
                local ok, allowed = callMethod(core.Functions, 'HasPermission', src, perm)
                if ok and allowed then return true end
            end
        end
    end

    return false
end

local function normalizeAction(action)
    local key = lower(action):gsub('[^%w]', '')
    local aliases = {
        playerinfo = 'info', qbinfo = 'info', azinfo = 'info', esxinfo = 'info', ndinfo = 'info', details = 'info', inspect = 'info',
        setjob = 'setjob', customjob = 'setjob', jobpreset = 'setjob',
        addmoney = 'addmoney', addcash = 'addmoney', addbank = 'addmoney', givemoney = 'addmoney', givecash = 'addmoney', givebank = 'addmoney',
        removemoney = 'removemoney', removecash = 'removemoney', removebank = 'removemoney', takemoney = 'removemoney', takecash = 'removemoney', takebank = 'removemoney', deductmoney = 'removemoney',
        reviveplayer = 'revive', healplayer = 'heal', setduty = 'duty', dutyon = 'duty', dutyoff = 'duty', onduty = 'duty', offduty = 'duty',
        givekeys = 'keys', giveplatekeys = 'keys', givecurrentkeys = 'keys', kickplayer = 'kick'
    }
    return aliases[key] or key
end

local function flattenArgs(out, value, seen)
    if value == nil then return end
    if type(value) ~= 'table' then
        out[#out + 1] = value
        return
    end
    seen = seen or {}
    if seen[value] then return end
    seen[value] = true
    for _, key in ipairs({ 'account', 'moneyType', 'type', 'amount', 'job', 'jobName', 'grade', 'rank', 'plate', 'duty', 'reason' }) do
        if value[key] ~= nil then out[#out + 1] = value[key] end
    end
    flattenArgs(out, value.value, seen)
    flattenArgs(out, value.values, seen)
    flattenArgs(out, value.args, seen)
    flattenArgs(out, value.extra, seen)
    for i = 1, #value do flattenArgs(out, value[i], seen) end
end

local function resolveSource(value, fallback)
    if type(value) == 'number' and isPlayerOnline(value) then return math.floor(value) end
    if type(value) == 'string' then
        local n = tonumber(value)
        if n and isPlayerOnline(n) then return math.floor(n) end
        local bracketed = value:match('%[(%d+)%]')
        if bracketed and isPlayerOnline(tonumber(bracketed)) then return tonumber(bracketed) end
    elseif type(value) == 'table' then
        for _, key in ipairs({ 'target', 'targetId', 'source', 'src', 'serverId', 'playerId', 'id', 'player', 'context' }) do
            local found = resolveSource(value[key])
            if found > 0 then return found end
        end
    end
    fallback = tonumber(fallback or 0) or 0
    if isPlayerOnline(fallback) then return fallback end
    return 0
end

local function normalizePayload(staffSrc, actionName, target, args)
    local payload = type(actionName) == 'table' and actionName or nil
    if payload then
        target = payload.target or payload.targetId or payload.source or payload.src or payload.player or payload.playerId or payload.context or target
        args = payload.args or payload.values or payload.value or payload.extra or args
        actionName = payload.action or payload.Action or payload.actionName or payload.ActionName or payload.frameworkAction or payload.FrameworkAction or payload.command or payload.cmd or payload.name or payload.label or payload.title or actionName
    end

    local action = normalizeAction(actionName)
    local resolvedTarget = resolveSource(target, 0)
    if resolvedTarget <= 0 and payload then resolvedTarget = resolveSource(payload, 0) end
    if resolvedTarget <= 0 then resolvedTarget = resolveSource(staffSrc, 0) end

    local flat = {}
    flattenArgs(flat, args)
    if #flat == 0 and payload then flattenArgs(flat, payload) end

    if action == '' or action == 'nil' or action:find('^table') then
        for _, v in ipairs(flat) do
            local maybe = normalizeAction(v)
            if maybe ~= '' and maybe ~= 'nil' then action = maybe break end
        end
    end

    return action, resolvedTarget, flat, payload or {}
end

local function jobFromArgs(flat, payload)
    payload = type(payload) == 'table' and payload or {}
    local value = type(payload.value) == 'table' and payload.value or {}
    local job = payload.job or payload.jobName or value.job or value.jobName
    local grade = payload.grade or payload.rank or value.grade or value.rank or 0
    for _, v in ipairs(flat or {}) do
        local text = trim(v)
        if text ~= '' and not tonumber(text) and not job then job = text end
        if tonumber(text) and (not grade or tonumber(grade) == 0) then grade = tonumber(text) end
    end
    return lower(job or 'unemployed'), tonumber(grade or 0) or 0
end

local function moneyFromArgs(flat, payload)
    payload = type(payload) == 'table' and payload or {}
    local value = type(payload.value) == 'table' and payload.value or {}
    local account = value.account or value.moneyType or value.type or payload.account or payload.moneyType or payload.type or 'cash'
    local amount = value.amount or payload.amount
    for _, v in ipairs(flat or {}) do
        local text = lower(v)
        if tonumber(text) and not amount then amount = tonumber(text)
        elseif text == 'cash' or text == 'money' or text == 'bank' then account = text end
    end
    account = lower(account)
    if account == 'money' then account = 'cash' end
    return account, math.floor(tonumber(amount or 0) or 0)
end

local function setJob(src, job, grade)
    src = tonumber(src or 0) or 0
    if not isPlayerOnline(src) or job == '' then return false end
    local fw = select(1, detectFramework())

    if fw == 'az' then
        local ok, result = azCall('setPlayerJob', src, job, grade)
        if ok and result ~= false then return true end
        ok, result = azCall('SetPlayerJob', src, job, grade)
        if ok and result ~= false then return true end
    elseif fw == 'esx' then
        local xPlayer = getESXPlayer(src)
        if xPlayer then
            local ok, result = callMethod(xPlayer, 'setJob', job, grade, true)
            return ok and result ~= false
        end
    elseif fw == 'nd' then
        local player = getNDPlayer(src)
        if player then
            local ok, result = callMethod(player, 'setJob', job, grade)
            return ok and result ~= false
        end
    elseif fw == 'qb' then
        local Player = getQBPlayer(src)
        if Player and Player.Functions then
            local ok, result = callMethod(Player.Functions, 'SetJob', job, grade)
            return ok and result ~= false
        end
    end

    return false
end

local function addMoney(src, account, amount, reason)
    src = tonumber(src or 0) or 0
    amount = math.floor(tonumber(amount or 0) or 0)
    if not isPlayerOnline(src) or amount <= 0 then return false end
    account = lower(account)
    if account == 'money' then account = 'cash' end
    local fw = select(1, detectFramework())

    if fw == 'az' then
        local ok, result = azCall('AddBridgeMoney', src, account, amount, reason or 'AMenu admin add money')
        if ok and result == true then return true end
        ok, result = azCall('addBridgeMoney', src, account, amount, reason or 'AMenu admin add money')
        if ok and result == true then return true end
        if account == 'cash' then
            ok, result = azCall('AddMoney', src, amount, reason or 'AMenu admin add money')
            if ok and result == true then return true end
        end
    elseif fw == 'esx' then
        local xPlayer = getESXPlayer(src)
        if xPlayer then
            if account == 'cash' then
                local ok, result = callMethod(xPlayer, 'addMoney', amount, reason or 'AMenu admin add money')
                if ok and result ~= false then return true end
                ok, result = callMethod(xPlayer, 'addAccountMoney', 'money', amount, reason or 'AMenu admin add money')
                if ok and result ~= false then return true end
            else
                local ok, result = callMethod(xPlayer, 'addAccountMoney', account, amount, reason or 'AMenu admin add money')
                if ok and result ~= false then return true end
            end
        end
    elseif fw == 'nd' then
        local player = getNDPlayer(src)
        if player then
            local ok, result = callMethod(player, 'addMoney', account, amount, reason or 'AMenu admin add money')
            return ok and result ~= false
        end
    elseif fw == 'qb' then
        local Player = getQBPlayer(src)
        if Player and Player.Functions then
            local ok, result = callMethod(Player.Functions, 'AddMoney', account, amount, reason or 'AMenu admin add money')
            return ok and result == true
        end
    end

    return false
end

local function removeMoney(src, account, amount, reason)
    src = tonumber(src or 0) or 0
    amount = math.floor(tonumber(amount or 0) or 0)
    if not isPlayerOnline(src) or amount <= 0 then return false end
    account = lower(account)
    if account == 'money' then account = 'cash' end
    local fw = select(1, detectFramework())

    if fw == 'az' then
        local ok, result = azCall('RemoveBridgeMoney', src, account, amount, reason or 'AMenu admin remove money')
        if ok and result == true then return true end
        ok, result = azCall('removeBridgeMoney', src, account, amount, reason or 'AMenu admin remove money')
        if ok and result == true then return true end
        if account == 'cash' then
            ok, result = azCall('DeductMoney', src, amount, reason or 'AMenu admin remove money')
            if ok and result == true then return true end
        end
    elseif fw == 'esx' then
        local xPlayer = getESXPlayer(src)
        if xPlayer then
            if account == 'cash' then
                local ok, result = callMethod(xPlayer, 'removeMoney', amount, reason or 'AMenu admin remove money')
                if ok and result ~= false then return true end
                ok, result = callMethod(xPlayer, 'removeAccountMoney', 'money', amount, reason or 'AMenu admin remove money')
                if ok and result ~= false then return true end
            else
                local ok, result = callMethod(xPlayer, 'removeAccountMoney', account, amount, reason or 'AMenu admin remove money')
                if ok and result ~= false then return true end
            end
        end
    elseif fw == 'nd' then
        local player = getNDPlayer(src)
        if player then
            local ok, result = callMethod(player, 'deductMoney', account, amount, reason or 'AMenu admin remove money')
            return ok and result ~= false
        end
    elseif fw == 'qb' then
        local Player = getQBPlayer(src)
        if Player and Player.Functions then
            local ok, result = callMethod(Player.Functions, 'RemoveMoney', account, amount, reason or 'AMenu admin remove money')
            return ok and result == true
        end
    end

    return false
end

local function savePlayer(src)
    local fw = select(1, detectFramework())
    if fw == 'az' then
        azCall('sendMoneyToClient', src, true)
        return true
    elseif fw == 'esx' then
        local xPlayer = getESXPlayer(src)
        if xPlayer then
            local ok = callMethod(xPlayer, 'save')
            return ok
        end
    elseif fw == 'nd' then
        local player = getNDPlayer(src)
        if player then
            local ok, result = callMethod(player, 'save')
            return ok and result ~= false
        end
    elseif fw == 'qb' then
        local Player = getQBPlayer(src)
        if Player and Player.Functions then
            local ok, result = callMethod(Player.Functions, 'Save')
            return ok and result ~= false
        end
    end
    return true
end

local function runReviveOrHeal(target, action)
    local fw = select(1, detectFramework())
    if fw == 'nd' and action == 'revive' then
        local player = getNDPlayer(target)
        if player then
            local ok = callMethod(player, 'revive')
            if ok then return true end
        end
    end

    TriggerClientEvent('az-amenu-qb:client:playerAction', target, action)
    TriggerClientEvent('amenu_ui:qbPlayerAction', target, action)
    return true
end

local function runPlayerAction(staffSrc, actionName, target, args)
    local action, resolvedTarget, flat, payload = normalizePayload(staffSrc, actionName, target, args)
    debugPrint('RunPlayerAction staff=', staffSrc, 'action=', action, 'target=', resolvedTarget)

    if action == '' then return { ok = false, message = 'Missing framework action.' } end
    if not isPlayerOnline(resolvedTarget) then return { ok = false, message = 'Target player not found.' } end
    if Config.RequireAdminForManagement ~= false and not hasAdmin(staffSrc) then return { ok = false, message = 'No AMenu framework management permission.' } end

    local fw, label = detectFramework()

    if action == 'info' then
        local snap = getSnapshot(resolvedTarget) or {}
        local money = snap.money or {}
        local job = snap.jobInfo or { name = snap.job or 'unemployed' }
        local display = ('%s | ID: %s | Char: %s | Job: %s | Cash: $%s | Bank: $%s | Framework: %s'):format(
            tostring(snap.name or GetPlayerName(resolvedTarget) or ('Player ' .. resolvedTarget)),
            tostring(resolvedTarget),
            tostring(snap.charid or snap.citizenid or 'unknown'),
            tostring(job.name or snap.job or 'unemployed'),
            tostring(money.cash or 0),
            tostring(money.bank or 0),
            label
        )
        return { ok = true, message = label .. ' player info opened.', title = label .. ' Player Info', displayText = display }
    elseif action == 'setjob' then
        local job, grade = jobFromArgs(flat, payload)
        if job == '' then return { ok = false, message = 'Missing job name.' } end
        local ok = setJob(resolvedTarget, job, grade)
        TriggerEvent('AMenu:QBCore:RefreshPermissions', resolvedTarget)
        return { ok = ok, message = ok and ('Job set to %s (%s).'):format(job, label) or ('%s set job failed.'):format(label) }
    elseif action == 'addmoney' or action == 'removemoney' then
        local account, amount = moneyFromArgs(flat, payload)
        if amount <= 0 then return { ok = false, message = 'Invalid money amount.' } end
        local ok = action == 'addmoney'
            and addMoney(resolvedTarget, account, amount, 'AMenu admin add money')
            or removeMoney(resolvedTarget, account, amount, 'AMenu admin remove money')
        return { ok = ok, message = ok and ('%s %s %s $%s.'):format(label, action == 'addmoney' and 'added' or 'removed', account, amount) or ('%s money update failed.'):format(label) }
    elseif action == 'revive' or action == 'heal' then
        local ok = runReviveOrHeal(resolvedTarget, action)
        return { ok = ok, message = ok and (action == 'revive' and 'Revive sent.' or 'Heal sent.') or 'Action failed.' }
    elseif action == 'duty' then
        local duty = lower(flat[1] or payload.duty or '')
        local dutyValue = duty == 'true' or duty == '1' or duty == 'yes' or duty == 'on'
        if fw == 'qb' then
            local Player = getQBPlayer(resolvedTarget)
            if Player and Player.Functions then
                local ok = callMethod(Player.Functions, 'SetJobDuty', dutyValue)
                return { ok = ok, message = dutyValue and 'Duty enabled.' or 'Duty disabled.' }
            end
        end
        return { ok = true, message = label .. ' uses job/duty through its framework resource. Use Set Job where applicable.' }
    elseif action == 'save' then
        local ok = savePlayer(resolvedTarget)
        return { ok = ok, message = ok and 'Player saved/refreshed.' or 'Save failed.' }
    elseif action == 'kick' then
        local reason = 'Kicked by staff.'
        for _, v in ipairs(flat or {}) do
            local t = trim(v)
            if t ~= '' then reason = t break end
        end
        local ndPlayer = fw == 'nd' and getNDPlayer(resolvedTarget) or nil
        if ndPlayer then
            local ok = callMethod(ndPlayer, 'drop', reason)
            if ok then return { ok = true, message = 'Player kicked.' } end
        end
        DropPlayer(resolvedTarget, reason)
        return { ok = true, message = 'Player kicked.' }
    elseif action == 'keys' then
        local plate = trim(flat[1] or payload.plate or '')
        local sent = false
        if Config.Keys and Config.Keys.ServerEvent and Config.Keys.ServerEvent ~= '' then
            TriggerEvent(Config.Keys.ServerEvent, resolvedTarget, plate)
            sent = true
        end
        if Config.Keys and Config.Keys.ClientEvent and Config.Keys.ClientEvent ~= '' then
            TriggerClientEvent(Config.Keys.ClientEvent, resolvedTarget, plate)
            sent = true
        end
        return { ok = true, message = sent and 'Key event sent.' or 'No key event configured; action accepted.' }
    end

    return { ok = false, message = ('Unknown framework action: %s.'):format(tostring(action)) }
end

local function canUseVehicleSpawner(src)
    src = tonumber(src or 0) or 0
    if src == 0 then return true, 'console' end
    if hasAdmin(src) then return true, 'admin' end

    local cfg = frameworkConfig()
    local restrict = cfg.RestrictVehicleSpawner
    if restrict == nil then restrict = Config.RestrictVehicleSpawner end
    if restrict ~= true then return true, 'open' end

    local snap = getSnapshot(src)
    local job = lower(snap and (snap.job or (snap.jobInfo and snap.jobInfo.name)) or '')
    local allowedJobs = cfg.AllowedVehicleJobs or Config.AllowedVehicleJobs or {}
    if job ~= '' and allowedJobs[job] then return true, job end
    return false, job ~= '' and job or 'no_job'
end

local function getSpawnCost(src, vehicleClass)
    if hasAdmin(src) then return 0 end
    local cfg = frameworkConfig()
    local costs = cfg.SpawnCosts or Config.SpawnCosts or {}
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
    if removeMoney(src, 'cash', amount, reason or 'AMenu vehicle spawn') then return true, 'cash' end
    if removeMoney(src, 'bank', amount, reason or 'AMenu vehicle spawn') then return true, 'bank' end
    return false, 'none'
end

local function giveKeys(src, plate, netId, modelHash)
    src = tonumber(src or 0) or 0
    if src <= 0 then return false end
    plate = trim(plate)
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
    local fw, label = detectFramework()
    return fw, label
end)

exports('GetStateForMenu', function(src)
    src = tonumber(src or source or 0) or 0
    local fw, label, resource = detectFramework()
    local canSpawn, spawnReason = canUseVehicleSpawner(src)
    local admin = hasAdmin(src)
    return {
        enabled = true,
        coreStarted = fw ~= 'standalone',
        framework = fw,
        frameworkName = fw,
        frameworkLabel = label,
        label = label,
        resource = resource,
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

exports('RunPlayerAction', function(...)
    local values = { ... }
    if type(values[1]) == 'table' and #values >= 2 then table.remove(values, 1) end
    if #values == 1 and type(values[1]) == 'table' then
        return runPlayerAction(tonumber(source or 0) or 0, values[1], nil, nil)
    end
    local staffSrc = tonumber(values[1] or source or 0) or 0
    local out = {}
    for i = 4, #values do out[#out + 1] = values[i] end
    return runPlayerAction(staffSrc, values[2], values[3], out)
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
    TriggerEvent('AMenu:QBCore:RefreshPermissions', tonumber(src or 0) or 0)
    return true
end)

exports('IsBridgeAdmin', function(src)
    return hasAdmin(tonumber(src or source or 0) or 0)
end)

RegisterNetEvent('AMenu:QBCore:RequestPlayers', function()
    local src = source
    if src ~= 0 and not hasAdmin(src) then
        TriggerClientEvent('AMenu:QBCore:ReceivePlayers', src, json.encode({}))
        return
    end
    TriggerClientEvent('AMenu:QBCore:ReceivePlayers', src, json.encode(playersForMenu()))
end)

RegisterNetEvent('AMenu:QBCore:RunPlayerAction', function(actionName, target, a, b, c, d)
    local src = source
    local args = {}
    for _, value in ipairs({ a, b, c, d }) do if value ~= nil then args[#args + 1] = value end end
    local result = runPlayerAction(src, actionName, target, args)
    notify(src, result.message or 'Done.', result.ok and 'success' or 'error', result.ok and 5000 or 8000)
end)

RegisterNetEvent('AMenu:QBCore:CanSpawnVehicle', function(requestId, modelHash, vehicleClass)
    local src = source
    requestId = tonumber(requestId) or 0
    local allowed, reason = canUseVehicleSpawner(src)
    if not allowed then
        TriggerClientEvent('AMenu:QBCore:SpawnVehicleResponse', src, requestId, false, ('AMenu vehicle spawn blocked: %s'):format(tostring(reason or 'not allowed')), 0)
        return
    end
    local cost = getSpawnCost(src, vehicleClass)
    local paid, account = chargePlayer(src, cost, ('AMenu vehicle spawn class %s'):format(tostring(vehicleClass)))
    if not paid then
        TriggerClientEvent('AMenu:QBCore:SpawnVehicleResponse', src, requestId, false, ('Need $%s cash/bank to spawn this vehicle.'):format(cost), cost)
        return
    end
    TriggerClientEvent('AMenu:QBCore:SpawnVehicleResponse', src, requestId, true, cost > 0 and ('$' .. cost .. ' charged from ' .. tostring(account)) or 'Vehicle spawn approved.', cost)
end)

RegisterNetEvent('AMenu:QBCore:VehicleSpawned', function(netId, plate, modelHash, vehicleClass, cost)
    local src = source
    giveKeys(src, plate, netId, modelHash)
    TriggerClientEvent('az-amenu-qb:client:applySpawnedVehicle', src, netId, plate, tostring(modelHash or ''), tonumber(vehicleClass) or -1, tonumber(cost) or 0)
end)

RegisterNetEvent('AMenu:QBCore:RefreshPermissions', function(target)
    local src = tonumber(target or source or 0) or 0
    if src > 0 then
        TriggerClientEvent('AMenu:QBCore:PermissionsRefreshed', src)
        TriggerClientEvent('AMenu:QBCore:ReceivePlayers', src, json.encode(playersForMenu()))
    end
end)

AddEventHandler('esx:playerLoaded', function(playerId)
    TriggerEvent('AMenu:QBCore:RefreshPermissions', tonumber(playerId or source or 0) or 0)
end)

AddEventHandler('esx:setJob', function(playerId)
    TriggerEvent('AMenu:QBCore:RefreshPermissions', tonumber(playerId or source or 0) or 0)
end)

AddEventHandler('ND:characterLoaded', function(player)
    local src = type(player) == 'table' and (player.source or player.src) or player
    TriggerEvent('AMenu:QBCore:RefreshPermissions', tonumber(src or source or 0) or 0)
end)

AddEventHandler('ND:setJob', function(src)
    TriggerEvent('AMenu:QBCore:RefreshPermissions', tonumber(src or source or 0) or 0)
end)

AddEventHandler('QBCore:Server:PlayerLoaded', function(Player)
    local src = type(Player) == 'table' and Player.PlayerData and Player.PlayerData.source or source
    TriggerEvent('AMenu:QBCore:RefreshPermissions', tonumber(src or 0) or 0)
end)

AddEventHandler('QBCore:Server:OnJobUpdate', function(src)
    TriggerEvent('AMenu:QBCore:RefreshPermissions', tonumber(src or source or 0) or 0)
end)

AddEventHandler('Az-Framework:jobChanged', function(changedSrc)
    TriggerEvent('AMenu:QBCore:RefreshPermissions', tonumber(changedSrc or source or 0) or 0)
end)

AddEventHandler('Az-Framework:characterSelected', function(changedSrc)
    TriggerEvent('AMenu:QBCore:RefreshPermissions', tonumber(changedSrc or source or 0) or 0)
end)

RegisterCommand('amenubridge', function(src, args)
    args = type(args) == 'table' and args or {}
    local sub = lower(args[1])
    local fw, label, res = detectFramework()
    if sub == '' or sub == 'status' then
        notify(src, ('AMenu Bridge: %s (%s) resource=%s'):format(label, fw, res ~= '' and res or 'none'), 'inform', 9000)
        return
    end
    if sub == 'refresh' then
        TriggerEvent('AMenu:QBCore:RefreshPermissions', tonumber(args[2] or src or 0) or 0)
        notify(src, 'AMenu permissions refreshed.', 'success')
        return
    end
    notify(src, 'Usage: /amenubridge status | refresh [id]', 'inform', 9000)
end, false)

CreateThread(function()
    Wait(1000)
    local fw, label, res = detectFramework()
    print(('^2[%s]^7 loaded. Framework: %s (%s)%s'):format(RESOURCE, label, fw, res ~= '' and (' via ' .. res) or ''))
end)
