local config = require 'config.server'

RegisterNetEvent('qbx_recycle:server:getItem', function()
    local src = source

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
end)
