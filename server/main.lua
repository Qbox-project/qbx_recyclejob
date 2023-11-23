local config = require 'config.server'

RegisterNetEvent('qbx_recycle:server:getItem', function()
    local src = source

    for _ = 1, math.random(1, config.maxItemsReceived), 1 do
        local randItem = config.itemTable[math.random(1, #config.itemTable)]
        local amount = math.random(config.minItemReceivedQty, config.maxItemReceivedQty)
        exports.ox_inventory:AddItem(src, randItem, amount)
        Wait(500)
    end

    local chance = math.random(1, 100)
    if chance < 7 then
        exports.ox_inventory:AddItem(src, config.chanceItem, 1)
    end

    local luck = math.random(1, 10)
    local odd = math.random(1, 10)
    if luck == odd then
        local random = math.random(1, 3)
        exports.ox_inventory:AddItem(src, config.luckyItem, random)
    end
end)
