local config = require 'config.server'
local clientConfig = require 'config.client'
local workSessions = {}

---@param source number
---@param coords vector3
---@param maxDistance number
---@return boolean
local function isNear(source, coords, maxDistance)
    return #(GetEntityCoords(GetPlayerPed(source)) - coords) <= maxDistance
end

---@param src number
local function giveRewards(src)

    for _ = 1, math.random(1, config.maxItemsReceived), 1 do
        local randItem = config.itemTable[math.random(1, #config.itemTable)]
        local amount = math.random(config.minItemReceivedQty, config.maxItemReceivedQty)
        if exports.ox_inventory:CanCarryItem(src, randItem, amount) then
            exports.ox_inventory:AddItem(src, randItem, amount)
            Wait(500)
        else
            exports.qbx_core:Notify(src, locale('error.overweight_check'), 'error')
        end
    end

    local chance = math.random(1, 100)
    if chance < 7 then
        if exports.ox_inventory:CanCarryItem(src, config.chanceItem, 1) then
            exports.ox_inventory:AddItem(src, config.chanceItem, 1)
        else
            exports.qbx_core:Notify(src, locale('error.overweight_check'), 'error')
        end
    end

    local luck = math.random(1, 10)
    local odd = math.random(1, 10)
    if luck == odd then
        local random = math.random(1, 3)
        if exports.ox_inventory:CanCarryItem(src, config.luckyItem, random) then
            exports.ox_inventory:AddItem(src, config.luckyItem, random)
        else
            exports.qbx_core:Notify(src, locale('error.overweight_check'), 'error')
        end
    end
end

lib.callback.register('qbx_recyclejob:server:startShift', function(source)
    if not isNear(source, clientConfig.dutyLocation.xyz, 3.0) then return end

    local pickupIndex = math.random(1, #clientConfig.pickupLocations)
    workSessions[source] = { pickupIndex = pickupIndex, carrying = false }
    return clientConfig.pickupLocations[pickupIndex]
end)

lib.callback.register('qbx_recyclejob:server:pickupPackage', function(source)
    local session = workSessions[source]
    if not session or session.carrying then return false end

    local pickupCoords = clientConfig.pickupLocations[session.pickupIndex]
    if not pickupCoords or not isNear(source, pickupCoords.xyz, 3.0) then return false end

    session.carrying = true
    session.pickupTime = os.time()
    return true
end)

lib.callback.register('qbx_recyclejob:server:deliverPackage', function(source)
    local session = workSessions[source]
    local minimumDeliveryTime = math.max(1, math.floor(clientConfig.deliveryActionDuration / 1000))
    if not session or not session.carrying or not session.pickupTime
        or os.time() - session.pickupTime < minimumDeliveryTime
        or not isNear(source, clientConfig.dropLocation.xyz, 3.0)
    then
        return
    end

    giveRewards(source)
    session.pickupIndex = math.random(1, #clientConfig.pickupLocations)
    session.carrying = false
    session.pickupTime = nil
    return clientConfig.pickupLocations[session.pickupIndex]
end)

RegisterNetEvent('qbx_recyclejob:server:endShift', function()
    workSessions[source] = nil
end)

AddEventHandler('playerDropped', function()
    workSessions[source] = nil
end)
