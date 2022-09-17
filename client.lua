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

        if rData.leave then
            CloseMenu()
            return
        end

        local args = rData.args
        if rData.unpack then
            args = table.unpack(rData.args or {})
        end

        if rData.action then
            -- @swkeep: added action to trigger a function
            rData.action(args)
        end

        -- this part should not triggered at all!
        if not rData.event and rData.server then
            assert(rData.event, 'The Server event was called but no event name was passed!')
        elseif not rData.event and rData.client then
            assert(rData.event, 'The Client event was called but no event name was passed!')
        end

        if rData.event and Promise == nil then
            -- @swkeep: added qbcore/fivem command

            if rData.server then
                TriggerServerEvent(rData.event, args)
            elseif not rData.server then
                TriggerEvent(rData.event, args)
            elseif rData.client then
                TriggerEvent(rData.event, args)
            end

            if rData.command then
                ExecuteCommand(rData.event)
            end

            if rData.QBCommand then
                TriggerServerEvent('QBCore:CallCommand', rData.event, args)
                TriggerEvent(rData.event, args)
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
    Wait(1) -- wait 1 frame or Promise wont be nil
    if not data or Promise ~= nil then return end
    while ActiveMenu do CloseMenu() Wait(1) end

    Promise = promise.new()

    CreateMenu(data)
    return table.unpack(Citizen.Await(Promise) or {})
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

local function length(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

PackParams = function(arguments)
    local args, pack = arguments, {}

    for i = 1, 15, 1 do
        pack[i] = args[i]
    end
    if not (#pack == length(args)) then
        local index = #pack + 1
        pack[index] = {}
        for key, value in pairs(args) do
            if not (type(key) == "number") then
                pack[index][key] = value
            end
        end
    end
    return pack
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
