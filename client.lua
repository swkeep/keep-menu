local QBCore = exports['qb-core']:GetCoreObject()
local Promise, ActiveMenu = nil, false
local inventoryName = 'qb-inventory' -- @swkeep: make sure script using correct name

RegisterNUICallback("dataPost", function(data, cb)
    local id = tonumber(data.id) + 1 or nil
    -- @swkeep: added PlaySoundFrontend to play menu sfx
    PlaySoundFrontend(-1, 'Highlight_Cancel', 'DLC_HEIST_PLANNING_BOARD_SOUNDS', 1)
    local rData = ActiveMenu[id]

    if rData then
        if Promise ~= nil then
            Promise:resolve(rData.args)
            Promise = nil
        end
        if rData.action then
            -- @swkeep: added action to trigger a function
            rData.action(rData.args)
        end
        if rData.event and Promise == nil then
            -- @swkeep: added qbcore/fivem command
            if rData.server then
                TriggerServerEvent(rData.event, UnpackParams(rData.args))
            elseif rData.command then
                ExecuteCommand(rData.event)
            elseif rData.QBCommand then
                TriggerServerEvent('QBCore:CallCommand', rData.event, UnpackParams(rData.args))
                TriggerEvent(rData.event, UnpackParams(rData.args))
            else
                TriggerEvent(rData.event, UnpackParams(rData.args))
            end
        end
    end
    CloseMenu()
    cb("ok")
end)

RegisterNUICallback("cancel", function(data, cb)
    if Promise ~= nil then
        Promise:resolve(nil)
        Promise = nil
    end
    CloseMenu()
    cb("ok")
end)

CreateMenu = function(data)
    ActiveMenu = ProcessParams(data)

    SendNUIMessage({
        action = "OPEN_MENU",
        data = data
    })
    SetNuiFocus(true, true)
end

ContextMenu = function(data)
    if not data or Promise ~= nil then return end
    while ActiveMenu do CloseMenu() Wait(0) end

    Promise = promise.new()

    CreateMenu(data)

    return UnpackParams(Citizen.Await(Promise))
end

-- @swkeep: overlay
Overlay = function(data)
    if not data then return end
    SendNUIMessage({
        action = "OPEN_OVERLAY",
        data = data
    })
end

-- @swkeep: overlay
CloseOverlay = function()
    SendNUIMessage({
        action = "CLOSE_OVERLAY",
    })
end

CloseMenu = function()
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = "CLOSE_MENU",
    })
    ActiveMenu = false
end

CancelMenu = function()
    SendNUIMessage({
        action = "CANCEL_MENU",
    })
end

ProcessParams = function(data)
    for _, v in pairs(data) do
        if v.args and type(v.args) == "table" and next(v.args) ~= nil then
            v.args = PackParams(v.args)
        end
        -- @swkeep: get images from user inventory
        if v.image then
            local img = "nui://" .. inventoryName .. "/html/"
            if QBCore.Shared.Items[tostring(v.image)] then
                if not string.find(QBCore.Shared.Items[tostring(v.image)].image, "images/") then
                    img = img .. "images/"
                end
                v.image = img .. QBCore.Shared.Items[tostring(v.image)].image
            end
        end
    end
    return data
end

PackParams = function(arguments)
    local args, pack = arguments, {}

    for i = 1, 15, 1 do
        pack[i] = args[i]
    end
    return pack
end

UnpackParams = function(arguments, i)
    if not arguments then return end
    local index = i or 1

    if index <= #arguments then
        return arguments[index], UnpackParams(arguments, index + 1)
    end
end

exports("createMenu", ContextMenu)
exports("closeMenu", CancelMenu)
-- @swkeep: overlay
exports("Overlay", Overlay)
exports("CloseOverlay", CloseOverlay)

RegisterNetEvent("keep-menu:createMenu", ContextMenu)
RegisterNetEvent("keep-menu:closeMenu", CancelMenu)
-- @swkeep: overlay
RegisterNetEvent("keep-menu:createMenu", Overlay)
RegisterNetEvent("keep-menu:closeOverlay", CloseOverlay)
