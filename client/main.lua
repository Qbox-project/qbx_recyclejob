local config = require 'config.client'
local isLoggedIn = false
local carryPackage = nil
local packageCoords = nil
local onDuty = false

-- zone check
local entranceTargetID = 'entranceTarget'

local exitTargetID = 'exitTarget'
local exitZone = nil

local deliveryTargetID = 'deliveryTarget'
local deliveryZone = nil

local dutyTargetID = 'dutyTarget'
local dutyZone = nil

local pickupTargetID = 'pickupTarget'
local pickupZone = nil

-- Functions
local function destroyPickupTarget()
    if not pickupZone then
        return
    end

    if config.useTarget then
        exports.ox_target:removeZone(pickupTargetID)
        pickupZone = nil
    else
        pickupZone:remove()
        pickupZone = nil
    end
end

local function registerEntranceTarget()
    local coords = vector3(config.outsideLocation.x, config.outsideLocation.y, config.outsideLocation.z)

    if config.useTarget then
        exports.ox_target:addBoxZone({
            name = entranceTargetID,
            coords = coords,
            rotation = config.outsideLocation.w,
            size = vec3(4.7, 1.7, 3.75),
            debug = config.debugPoly,
            options = {
                {
                    icon = 'fa-solid fa-house',
                    type = 'client',
                    event = 'qbx_recyclejob:client:target:enterLocation',
                    label = locale("text.enter_warehouse"),
                    distance = 1
                },
            },
        })
    else
        lib.zones.box({
            coords = coords,
            rotation = config.outsideLocation.w,
            size = vec3(4.7, 1.7, 3.75),
            debug = config.debugPoly,
            onEnter = function()
                lib.showTextUI(locale("text.point_enter_warehouse"))
            end,
            onExit = function()
                lib.hideTextUI()
            end,
            inside = function()
                if IsControlJustReleased(0, 38) then
                    TriggerEvent('qbx_recyclejob:client:target:enterLocation')
                    lib.hideTextUI()
                end
            end
        })
    end
end

local function registerExitTarget()
    local coords = vector3(config.insideLocation.x, config.insideLocation.y, config.insideLocation.z)

    if config.useTarget then
        exitZone = exports.ox_target:addBoxZone({
            name = exitTargetID,
            coords = coords,
            rotation = 0.0,
            size = vec3(1.7, 4.7, 3.75),
            debug = config.debugPoly,
            options = {
                {
                    icon = 'fa-solid fa-house',
                    type = 'client',
                    event = 'qbx_recyclejob:client:target:exitLocation',
                    label = locale("text.exit_warehouse"),
                    distance = 1
                },
            },
        })
    else
        exitZone = lib.zones.box({
            coords = coords,
            rotation = 0.0,
            size = vec3(1.55, 4.95, 3.75),
            debug = config.debugPoly,
            onEnter = function()
                lib.showTextUI(locale("text.point_exit_warehouse"))
            end,
            onExit = function()
                lib.hideTextUI()
            end,
            inside = function()
                if IsControlJustReleased(0, 38) then
                    TriggerEvent('qbx_recyclejob:client:target:exitLocation')
                    lib.hideTextUI()
                end
            end
        })
    end
end

local function destroyExitTarget()
    if not exitZone then
        return
    end

    if config.useTarget then
        exports.ox_target:removeZone(exitTargetID)
        exitZone = nil
    else
        exitZone:remove()
        exitZone = nil
    end
end

local function getDutyTargetText()
    if config.useTarget then
        local text = onDuty and locale("text.clock_out") or locale("text.clock_in")
        return text
    else
        local text = onDuty and locale("text.point_clock_out") or locale("text.point_clock_in")
        return text
    end
end

local function registerDutyTarget()
    local coords = vector3(config.dutyLocation.x, config.dutyLocation.y, config.dutyLocation.z)

    if config.useTarget then
        dutyZone = exports.ox_target:addBoxZone({
            name = dutyTargetID,
            coords = coords,
            rotation = 0.0,
            size = vec3(1.8, 2.65, 2.0),
            distance = 1.0,
            debug = config.debugPoly,
            options = {
                {
                    icon = 'fa-solid fa-house',
                    type = 'client',
                    event = 'qbx_recyclejob:client:target:toggleDuty',
                    label = getDutyTargetText(),
                    distance = 1
                },
            },
        })
    else
        dutyZone = lib.zones.box({
            coords = coords,
            rotation = 0.0,
            size = vec3(1.8, 2.65, 2.0),
            debug = config.debugPoly,
            onEnter = function()
                lib.showTextUI(getDutyTargetText())
            end,
            onExit = function()
                lib.hideTextUI()
            end,
            inside = function()
                if IsControlJustReleased(0, 38) then
                    TriggerEvent('qbx_recyclejob:client:target:toggleDuty')
                    lib.hideTextUI()
                end
            end
        })
    end
end

local function destroyDutyTarget()
    if not dutyZone then
        return
    end

    if config.useTarget then
        exports.ox_target:removeZone(dutyTargetID)
        dutyZone = nil
    else
        dutyZone:remove()
        dutyZone = nil
    end
end

local function refreshDutyTarget()
    destroyDutyTarget()
    registerDutyTarget()
end

local function registerDeliveryTarget()
    local coords = vector3(config.dropLocation.x, config.dropLocation.y, config.dropLocation.z)

    if config.useTarget then
        deliveryZone = exports.ox_target:addBoxZone({
            name = deliveryTargetID,
            coords = coords,
            rotation = 0.0,
            size = vec3(0.95, 1.25, 2.5),
            debug = config.debugPoly,
            options = {
                {
                    icon = 'fa-solid fa-house',
                    type = 'client',
                    event = 'qbx_recyclejob:client:target:dropPackage',
                    label = locale("text.hand_in_package"),
                    distance = 1
                },
            },
        })
    else
        deliveryZone = lib.zones.box({
            coords = coords,
            rotation = 0.0,
            size = vec3(0.95, 1.25, 2.5),
            debug = config.debugPoly,
            onEnter = function()
                lib.showTextUI(locale("text.point_hand_in_package"))
            end,
            onExit = function()
                lib.hideTextUI()
            end,
            inside = function()
                if carryPackage then
                    if IsControlJustReleased(0, 38) then
                        TriggerEvent('qbx_recyclejob:client:target:dropPackage')
                        lib.hideTextUI()
                    end
                end
            end
        })
    end
end

local function destroyDeliveryTarget()
    if not deliveryZone then
        return
    end

    if config.useTarget then
        exports.ox_target:removeZone(deliveryTargetID)
        deliveryZone = nil
    else
        deliveryZone:remove()
        deliveryZone = nil
    end
end

local function destroyInsideZones()
    destroyPickupTarget()
    destroyExitTarget()
    destroyDutyTarget()
    destroyDeliveryTarget()
end

local function scrapAnim()
    local time = 5

    lib.playAnim(cache.ped, 'mp_car_bomb', 'car_bomb_mechanic', 3.0, 3.0, -1, 16, 0, false, false, false)
    local openingDoor = true

    CreateThread(function()
        while openingDoor do
            lib.playAnim(cache.ped, 'mp_car_bomb', 'car_bomb_mechanic', 3.0, 3.0, -1, 16, 0, false, false, false)
            Wait(1000)
            time = time - 1
            if time <= 0 then
                openingDoor = false
                StopAnimTask(cache.ped, 'mp_car_bomb', 'car_bomb_mechanic', 1.0)
            end
        end
    end)
end

local function getRandomPackage()
    packageCoords = config.pickupLocations[math.random(1, #config.pickupLocations)]
    RegisterPickupTarget(packageCoords)
end

local function pickupPackage()
    local pos = GetEntityCoords(cache.ped, true)
    local boxModel = config.pickupBoxModel
    lib.requestModel(boxModel, 5000)
    lib.playAnim(cache.ped, 'anim@heists@box_carry@', 'idle', 5.0, -1, -1, 50, 0, false, false, false)
    local object = CreateObject(boxModel, pos.x, pos.y, pos.z, true, true, true)
    SetModelAsNoLongerNeeded(boxModel)
    AttachEntityToEntity(object, cache.ped, GetPedBoneIndex(cache.ped, 57005), 0.05, 0.1, -0.3, 300.0, 250.0, 20.0, true, true, false, true, 1, true)
    carryPackage = object
end

local function dropPackage()
    ClearPedTasks(cache.ped)
    DetachEntity(carryPackage, true, true)
    DeleteObject(carryPackage)
    carryPackage = nil
end

local function setLocationBlip()
    local RecycleBlip = AddBlipForCoord(config.outsideLocation.x, config.outsideLocation.y, config.outsideLocation.z)
    SetBlipSprite(RecycleBlip, 365)
    SetBlipColour(RecycleBlip, 2)
    SetBlipScale(RecycleBlip, 0.8)
    SetBlipAsShortRange(RecycleBlip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString('Recycle Center')
    EndTextCommandSetBlipName(RecycleBlip)
end

local function buildInteriorDesign()
    for _, pickuploc in pairs(config.pickupLocations) do
        local model = GetHashKey(config.warehouseObjects[math.random(1, #config.warehouseObjects)])
        lib.requestModel(model, 5000)
        local obj = CreateObject(model, pickuploc.x, pickuploc.y, pickuploc.z, false, true, true)
        SetModelAsNoLongerNeeded(model)
        PlaceObjectOnGroundProperly(obj)
        FreezeEntityPosition(obj, true)
    end
end

local function enterLocation()
    DoScreenFadeOut(500)

    while not IsScreenFadedOut() do
        Wait(10)
    end

    SetEntityCoords(cache.ped, config.insideLocation.x, config.insideLocation.y, config.insideLocation.z)
    buildInteriorDesign()
    DoScreenFadeIn(500)

    destroyInsideZones()
    registerExitTarget()
    registerDutyTarget()
end

local function exitLocation()
    DoScreenFadeOut(500)

    while not IsScreenFadedOut() do
        Wait(10)
    end

    SetEntityCoords(cache.ped, config.outsideLocation.x, config.outsideLocation.y, config.outsideLocation.z + 1)
    DoScreenFadeIn(500)

    onDuty = false

    destroyInsideZones()

    if carryPackage then
        dropPackage()
    end
end

function RegisterPickupTarget(coords)
    local targetCoords = vector3(coords.x, coords.y, coords.z)

    if config.useTarget then
        pickupZone = exports.ox_target:addBoxZone({
            name = pickupTargetID,
            coords = targetCoords,
            rotation = 0.0,
            size = vec3(2.4, 2.35, 4.0),
            debug = config.debugPoly,
            options = {
                {
                    icon = 'fa-solid fa-house',
                    type = 'client',
                    event = 'qbx_recyclejob:client:target:pickupPackage',
                    label = locale("text.get_package"),
                    distance = 1
                },
            },
        })
    else
        pickupZone = lib.zones.box({
            coords = targetCoords,
            rotation = 0.0,
            size = vec3(2.4, 2.45, 4.0),
            debug = config.debugPoly,
            onEnter = function()
                lib.showTextUI(locale("text.point_get_package"))
            end,
            onExit = function()
                lib.hideTextUI()
            end,
            inside = function ()
                if onDuty then
                    if not carryPackage then
                        if IsControlJustReleased(0, 38) then
                            TriggerEvent('qbx_recyclejob:client:target:pickupPackage')
                            lib.hideTextUI()
                        end
                    end
                end
            end
        })
    end
end

local function DrawPackageLocationBlip()
    if not config.drawPackageLocationBlip then
        return
    end

    DrawMarker(2, packageCoords.x, packageCoords.y, packageCoords.z + 3, 0, 0, 0, 180.0, 0, 0, 0.5, 0.5, 0.5, 255, 255, 0, 100, false, false, 2, true, nil, nil, false)
end

-- Events
RegisterNetEvent('qbx_recyclejob:client:target:enterLocation', function()
    enterLocation()
end)

RegisterNetEvent('qbx_recyclejob:client:target:exitLocation', function()
    exitLocation()
end)

RegisterNetEvent('qbx_recyclejob:client:target:toggleDuty', function()
    onDuty = not onDuty

    if onDuty then
        exports.qbx_core:Notify(locale("success.you_have_been_clocked_in"), 'success')
        getRandomPackage()
    else
        exports.qbx_core:Notify(locale("error.you_have_clocked_out"), 'error')
        destroyPickupTarget()
    end

    if carryPackage then
        dropPackage()
    end

    refreshDutyTarget()
    destroyDeliveryTarget()
end)

RegisterNetEvent('qbx_recyclejob:client:target:pickupPackage', function()
    if not pickupZone or carryPackage then
        return
    end

    scrapAnim()

    if lib.progressBar({
        duration = config.pickupActionDuration,
        label = locale("text.picking_up_the_package"),
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = true,
            car = true,
            mouse = true,
            combat = true
        },
    }) then
        packageCoords = nil
        StopAnimTask(cache.ped, 'mp_car_bomb', 'car_bomb_mechanic', 1.0)
        ClearPedTasks(cache.ped)
        pickupPackage()
        destroyPickupTarget()
        registerDeliveryTarget()
    else
        exports.qbx_core:Notify(locale('error.canceled'), 'error')
    end
end)

RegisterNetEvent('qbx_recyclejob:client:target:dropPackage', function()
    if not carryPackage or not deliveryZone then
        return
    end

    dropPackage()
    scrapAnim()
    destroyDeliveryTarget()

    if lib.progressBar({
        duration = config.deliveryActionDuration,
        label = locale("text.unpacking_the_package"),
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = true,
            car = true,
            mouse = true,
            combat = true
        },
    }) then
        StopAnimTask(cache.ped, 'mp_car_bomb', 'car_bomb_mechanic', 1.0)
        TriggerServerEvent('qbx_recycle:server:getItem')
        getRandomPackage()
    else
        exports.qbx_core:Notify(locale('error.canceled'), 'error')
    end
end)

local function startPackageBlipDraw()
    CreateThread(function()
        while isLoggedIn do
            if onDuty and packageCoords and not carryPackage and config.drawPackageLocationBlip then
                DrawPackageLocationBlip()
                Wait(0)
            else
                Wait(500)
            end
        end
    end)
end

AddStateBagChangeHandler('isLoggedIn', ('player:%s'):format(cache.serverId), function(_, _, loginState)
    if isLoggedIn == loginState then return end
    isLoggedIn = loginState
    startPackageBlipDraw()
end)

CreateThread(function()
    setLocationBlip()
    registerEntranceTarget()
end)