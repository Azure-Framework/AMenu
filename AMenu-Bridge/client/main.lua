local RESOURCE = GetCurrentResourceName()

local function debugPrint(...)
    if not Config.Debug then return end
    local parts = {}
    for i = 1, select('#', ...) do
        parts[#parts + 1] = tostring(select(i, ...))
    end
    print(('[%s/client] %s'):format(RESOURCE, table.concat(parts, ' ')))
end

local function notify(message, msgType, duration)
    if Config.Notifications and Config.Notifications.UseOxLibFallback then
        pcall(function()
            TriggerEvent('ox_lib:notify', {
                title = (Config.Notifications and Config.Notifications.Title) or 'AMenu Bridge',
                description = tostring(message or ''),
                type = msgType or 'inform',
                duration = tonumber(duration) or 5000
            })
        end)
    end
end

local function healPlayer()
    local ped = PlayerPedId()
    if ped == 0 then return end
    ClearPedBloodDamage(ped)
    ResetPedVisibleDamage(ped)
    ClearPedLastWeaponDamage(ped)
    SetEntityHealth(ped, GetEntityMaxHealth(ped))
    SetPedArmour(ped, 0)
end

local function revivePlayer()
    local ped = PlayerPedId()
    if ped == 0 then return end

    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)

    if IsEntityDead(ped) then
        NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z + 0.5, heading, true, false)
        Wait(100)
        ped = PlayerPedId()
    end

    ClearPedTasksImmediately(ped)
    healPlayer()
end

RegisterNetEvent('az-amenu-qb:client:playerAction', function(action)
    action = tostring(action or ''):lower()
    debugPrint('playerAction', action)

    if action == 'revive' then
        revivePlayer()
        notify('You were revived by staff.', 'success')
    elseif action == 'heal' then
        healPlayer()
        notify('You were healed by staff.', 'success')
    end
end)

RegisterNetEvent('amenu_ui:qbPlayerAction', function(action)
    TriggerEvent('az-amenu-qb:client:playerAction', action)
end)

RegisterNetEvent('az-amenu-qb:client:applySpawnedVehicle', function(netId, plate, modelHash, vehicleClass, cost)
    debugPrint('spawned vehicle', 'netId=', netId, 'plate=', plate, 'model=', modelHash, 'class=', vehicleClass, 'cost=', cost)

end)

RegisterNetEvent('AMenu:QBCore:PermissionsRefreshed', function()
    debugPrint('permissions refreshed')
end)

CreateThread(function()
    Wait(2500)
    TriggerServerEvent('AMenu:QBCore:RequestPlayers')
    debugPrint('AMenu client bridge loaded')
end)
