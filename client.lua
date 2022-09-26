local QBCore = nil
if GetResourceState('qb-core') == 'started' then
    QBCore = exports['qb-core']:GetCoreObject()
end

local Promise, ActiveMenu = nil, false
local inventoryName = 'qb-inventory' -- @swkeep: make sure script using correct name
local img = "nui://" .. inventoryName .. "/html/"


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

        if rData.action then
            -- @swkeep: added action to trigger a function
            if rData.unpack then
                rData.action(table.unpack(rData.args or {}))
            else
                rData.action(rData.args)
            end
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
                if rData.unpack then
                    TriggerServerEvent(rData.event, table.unpack(rData.args or {}))
                else
                    TriggerServerEvent(rData.event, rData.args)
                end
            elseif not rData.server then
                if rData.unpack then
                    TriggerEvent(rData.event, table.unpack(rData.args or {}))
                else
                    TriggerEvent(rData.event, rData.args)
                end

            elseif rData.client then
                if rData.unpack then
                    TriggerEvent(rData.event, table.unpack(rData.args or {}))
                else
                    TriggerEvent(rData.event, rData.args)
                end
            end

            if rData.command then
                ExecuteCommand(rData.event)
            end

            if QBCore and rData.QBCommand then
                if rData.unpack then
                    TriggerServerEvent('QBCore:CallCommand', rData.event, table.unpack(rData.args or {}))
                    TriggerEvent(rData.event, rData.args)
                else
                    TriggerServerEvent('QBCore:CallCommand', rData.event, rData.args)
                    TriggerEvent(rData.event, rData.args)
                end
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
            if not v.hide then
                v.args = PackParams(v.args)
            end
        end
        -- @swkeep: get images from user inventory
        if v.image then
            if QBCore then
                if QBCore.Shared.Items[tostring(v.image)] then
                    if not string.find(QBCore.Shared.Items[tostring(v.image)].image, "images/") then
                        img = img .. "images/"
                    end
                    v.image = img .. QBCore.Shared.Items[tostring(v.image)].image
                end
            else
                v.image = img .. v.image
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

function print_table(node)
    local cache, stack, output = {}, {}, {}
    local depth = 1
    local output_str = "{\n"

    while true do
        local size = 0
        for k, v in pairs(node) do
            size = size + 1
        end

        local cur_index = 1
        for k, v in pairs(node) do
            if (cache[node] == nil) or (cur_index >= cache[node]) then

                if (string.find(output_str, "}", output_str:len())) then
                    output_str = output_str .. ",\n"
                elseif not (string.find(output_str, "\n", output_str:len())) then
                    output_str = output_str .. "\n"
                end

                -- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
                table.insert(output, output_str)
                output_str = ""

                local key
                if (type(k) == "number" or type(k) == "boolean") then
                    key = "[" .. tostring(k) .. "]"
                else
                    key = "['" .. tostring(k) .. "']"
                end

                if (type(v) == "number" or type(v) == "boolean") then
                    output_str = output_str .. string.rep('\t', depth) .. key .. " = " .. tostring(v)
                elseif (type(v) == "table") then
                    output_str = output_str .. string.rep('\t', depth) .. key .. " = {\n"
                    table.insert(stack, node)
                    table.insert(stack, v)
                    cache[node] = cur_index + 1
                    break
                else
                    output_str = output_str .. string.rep('\t', depth) .. key .. " = '" .. tostring(v) .. "'"
                end

                if (cur_index == size) then
                    output_str = output_str .. "\n" .. string.rep('\t', depth - 1) .. "}"
                else
                    output_str = output_str .. ","
                end
            else
                -- close the table
                if (cur_index == size) then
                    output_str = output_str .. "\n" .. string.rep('\t', depth - 1) .. "}"
                end
            end

            cur_index = cur_index + 1
        end

        if (size == 0) then
            output_str = output_str .. "\n" .. string.rep('\t', depth - 1) .. "}"
        end

        if (#stack > 0) then
            node = stack[#stack]
            stack[#stack] = nil
            depth = cache[node] == nil and depth + 1 or depth - 1
        else
            break
        end
    end

    -- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
    table.insert(output, output_str)
    output_str = table.concat(output)

    print(output_str)
end
