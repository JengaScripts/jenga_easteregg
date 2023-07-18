ESX,QBCore = nil,nil
local FrameWork = GetResourceState('es_extended') ==  'started' and 'ESX' or GetResourceState('qb-core') ==  'started' and 'QBCORE'
local createdProp = nil
local eggCoord = nil
local blip = nil
local attempt = 0

if FrameWork == "ESX" then
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    if not ESX then
        ESX = exports['es_extended']:getSharedObject()
    end
elseif FrameWork == 'QBCORE' then
	QBCore = exports['qb-core']:GetCoreObject()
else
    print("FrameWork Not Detected!")
end

print("Framework: ".. FrameWork)

local function GetCoordinate()
    attempt = attempt + 1
    local angle = math.random() * 2 * math.pi
    local distance = math.random() * Config.Radius
    local x = Config.Center_X + distance * math.cos(angle)
    local y = Config.Center_Y + distance * math.sin(angle)
    local foundGround, z = GetGroundZFor_3dCoord(x, y, 500.0, false)
    if attempt >= 100 then
        return nil
    elseif z == 0.0 then
        Wait(100)
        GetCoordinate()
    end
    return vector3(x, y, z)
end

CreateThread(function()
    while true do
        Wait(5000)
        if not createdProp then
            if QBCore then
                QBCore.Functions.TriggerCallback('jenga_easteregg:server:getEgg', function(data)
                    if data then
                        RequestModel(Config.Prop)
                        while not HasModelLoaded(Config.Prop) do
                            Wait(10)
                        end
                        eggCoord = data
                        if Config.Debug then
                            blip = AddBlipForCoord(data.x, data.y, data.z)
                        end
                        createdProp = CreateObject(Config.Prop, data.x, data.y, data.z, false, false, false)
                        FreezeEntityPosition(createdProp, true)
                    end
                end, GetCoordinate())
            else
                ESX.TriggerServerCallback('jenga_easteregg:server:getEgg', function(data)
                    if data then
                        RequestModel(Config.Prop)
                        while not HasModelLoaded(Config.Prop) do
                            Wait(10)
                        end
                        eggCoord = data
                        if Config.Debug then
                            blip = AddBlipForCoord(data.x, data.y, data.z)
                        end
                        createdProp = CreateObject(Config.Prop, data.x, data.y, data.z, false, false, false)
                        FreezeEntityPosition(createdProp, true)
                    end
                end, GetCoordinate())
            end
        end
    end
end)

RegisterNetEvent("jenga_easteregg:client:requestEgg", function()
    attempt = 0
    TriggerEvent("jenga_easteregg:client:removeEgg")
    if QBCore then
        QBCore.Functions.TriggerCallback('jenga_easteregg:server:getEgg', function(data)
            if data then
                RequestModel(Config.Prop)
                while not HasModelLoaded(Config.Prop) do
                    Wait(10)
                end
                eggCoord = data
                if Config.Debug then
                    blip = AddBlipForCoord(data.x, data.y, data.z)
                end
                createdProp = CreateObject(Config.Prop, data.x, data.y, data.z, false, false, false)
                FreezeEntityPosition(createdProp, true)
            end
        end, GetCoordinate())
    else
        ESX.TriggerServerCallback('jenga_easteregg:server:getEgg', function(data)
            if data then
                RequestModel(Config.Prop)
                while not HasModelLoaded(Config.Prop) do
                    Wait(10)
                end
                eggCoord = data
                if Config.Debug then
                    blip = AddBlipForCoord(data.x, data.y, data.z)
                end
                createdProp = CreateObject(Config.Prop, data.x, data.y, data.z, false, false, false)
                FreezeEntityPosition(createdProp, true)
            end
        end, GetCoordinate())
    end
end)

RegisterNetEvent("jenga_easteregg:client:removeEgg", function()
    if createdProp and DoesEntityExist(createdProp) then
        SetEntityAsMissionEntity(createdProp, true, true)
        DeleteEntity(createdProp)
        SetEntityAsNoLongerNeeded(createdProp)
        createdProp = nil
        if blip and DoesBlipExist(blip) then
            RemoveBlip(blip)
            blip = nil
        end
    end
end)

CreateThread(function()
    if Config.Target then
        exports[Config.TargetExport]:AddTargetModel(Config.Prop, {
            options = {
                {
                    event = "jenga_easteregg:client:openEgg",
                    icon = "fas fa-hands",
                    label = "Open Egg"
                },
            },
            distance = 3.5,
        })
    else
        while true do
            local sleep = 1000
            if eggCoord then
                local pedCoord = GetEntityCoords(PlayerPedId())
                local distance = #(eggCoord - pedCoord)
                if distance <= 3.5 then
                    sleep = 1
                    if QBCore then
                        exports['qb-core']:DrawText("[E] Open Egg", 'left')
                    else
                        ESX.Game.Utils.DrawText3D({
                            x = eggCoord.x,
                            y = eggCoord.y,
                            z = eggCoord.z
                        }, "[E] Open Egg", 0.5)
                    end
                    if IsControlJustPressed(0, 38) then
                        TriggerEvent("jenga_easteregg:client:openEgg")
                        if QBCore then
                            exports['qb-core']:HideText()
                        end
                    end
                else
                    if QBCore then
                        exports['qb-core']:HideText()
                    end
                end
            end
            Wait(sleep)
        end
    end
end)

RegisterNetEvent("jenga_easteregg:client:openEgg", function()
    TriggerServerEvent("jenga_easteregg:server:openEgg", eggCoord)
end)

RegisterNetEvent('jenga_easteregg:client:RequestReward', function(data)
    SendNUIMessage({ nui = "getReward", reward = data, path = Config.ItemsImgPath })
    SetNuiFocus(true, true)
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    Wait(1000)
    local redzone = AddBlipForRadius(Config.Center_X, Config.Center_Y, 0, Config.Radius)
    SetBlipColour(redzone, 1)
    SetBlipAlpha(redzone, 50)
    SetBlipSprite(redzone, 9)
    QBCore.Functions.TriggerCallback('jenga_easteregg:server:getEgg', function(data)
        if data then
            RequestModel(Config.Prop)
            while not HasModelLoaded(Config.Prop) do
                Wait(10)
            end
            eggCoord = data
            if Config.Debug then
                blip = AddBlipForCoord(data.x, data.y, data.z)
            end
            createdProp = CreateObject(Config.Prop, data.x, data.y, data.z, false, false, false)
            FreezeEntityPosition(createdProp, true)
        end
    end, GetCoordinate())
end)

RegisterNetEvent('esx:playerLoaded', function()
    Wait(1000)
    local redzone = AddBlipForRadius(Config.Center_X, Config.Center_Y, 0, Config.Radius)
    SetBlipColour(redzone, 1)
    SetBlipAlpha(redzone, 50)
    SetBlipSprite(redzone, 9)
    ESX.TriggerServerCallback('jenga_easteregg:server:getEgg', function(data)
        if data then
            RequestModel(Config.Prop)
            while not HasModelLoaded(Config.Prop) do
                Wait(10)
            end
            eggCoord = data
            if Config.Debug then
                blip = AddBlipForCoord(data.x, data.y, data.z)
            end
            createdProp = CreateObject(Config.Prop, data.x, data.y, data.z, false, false, false)
            FreezeEntityPosition(createdProp, true)
        end
    end, GetCoordinate())
end)

RegisterNuiCallback("exit", function()
    SetNuiFocus(false, false)
end)

RegisterCommand(Config.LevelPanelCommand, function(source, args)
    if QBCore then
        QBCore.Functions.TriggerCallback('jenga_easteregg:server:getData', function(data)
            SendNUIMessage({ nui = "level", playerData = data, config = Config.Levels, path = Config.ItemsImgPath })
            SetNuiFocus(true, true)
        end)
    else
        ESX.TriggerServerCallback('jenga_easteregg:server:getData', function(data)
            SendNUIMessage({ nui = "level", playerData = data, config = Config.Levels, path = Config.ItemsImgPath })
            SetNuiFocus(true, true)
        end)
    end
end)

RegisterCommand(Config.LeaderboardCommand, function(source, args)
    if QBCore then
        QBCore.Functions.TriggerCallback('jenga_easteregg:server:getFullData', function(data)
            SendNUIMessage({ nui = "leaderboard", list = data })
            SetNuiFocus(true, true)
        end)
    else
        ESX.TriggerServerCallback('jenga_easteregg:server:getFullData', function(data)
            SendNUIMessage({ nui = "leaderboard", list = data })
            SetNuiFocus(true, true)
        end)
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        if createdProp and DoesEntityExist(createdProp) then
            SetEntityAsMissionEntity(createdProp, true, true)
            DeleteEntity(createdProp)
            createdProp = nil
            if blip and DoesBlipExist(blip) then
                RemoveBlip(blip)
                blip = nil
            end
        end
    end
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        Wait(1000)  
        local redzone = AddBlipForRadius(Config.Center_X, Config.Center_Y, 0, Config.Radius)
        SetBlipColour(redzone, 1)
        SetBlipAlpha(redzone, 50)
		SetBlipSprite(redzone, 9)
        if QBCore then
            QBCore.Functions.TriggerCallback('jenga_easteregg:server:getEgg', function(data)
                if data then
                    RequestModel(Config.Prop)
                    while not HasModelLoaded(Config.Prop) do
                        Wait(10)
                    end
                    eggCoord = data
                    if Config.Debug then
                        blip = AddBlipForCoord(data.x, data.y, data.z)
                    end
                    createdProp = CreateObject(Config.Prop, data.x, data.y, data.z, false, false, false)
                    FreezeEntityPosition(createdProp, true)
                end
            end, GetCoordinate())
        else
            ESX.TriggerServerCallback('jenga_easteregg:server:getEgg', function(data)
                if data then
                    RequestModel(Config.Prop)
                    while not HasModelLoaded(Config.Prop) do
                        Wait(10)
                    end
                    eggCoord = data
                    if Config.Debug then
                        blip = AddBlipForCoord(data.x, data.y, data.z)
                    end
                    createdProp = CreateObject(Config.Prop, data.x, data.y, data.z, false, false, false)
                    FreezeEntityPosition(createdProp, true)
                end
            end, GetCoordinate())
        end
    end
end)