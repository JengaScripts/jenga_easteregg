ESX,QBCore = nil,nil
local FrameWork = GetResourceState('es_extended') ==  'started' and 'ESX' or GetResourceState('qb-core') ==  'started' and 'QBCORE'
local eggs = {
    coord = nil,
    isFound = false
}

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

CreateThread(function()
    while true do
        local sleep = Config.CreateEggInterval
        if not eggs.coord and eggs.isFound then
            if QBCore then
                local players = QBCore.Functions.GetPlayers()
                if #players > 0 then
                    TriggerClientEvent("jenga_easteregg:client:requestEgg", -1)
                    if Config.Debug then
                        print("Egg Created")
                    end
                end
            else
                local players = ESX.GetPlayers()
                if #players > 0 then
                    TriggerClientEvent("jenga_easteregg:client:requestEgg", -1)
                    if Config.Debug then
                        print("Egg Created")
                    end
                end
            end
        end
        Wait(sleep)
    end
end)

local function AddPoint(source, Player)
    local identifier = nil
    local fullname = nil
    if QBCore then
        identifier = Player.PlayerData.citizenid
        fullname = Player.PlayerData.charinfo.firstname.." "..Player.PlayerData.charinfo.lastname
    else
        identifier = Player.identifier
        fullname = Player.get('firstName').." "..Player.get('lastName')
    end
    exports.oxmysql:execute('INSERT INTO jenga_easteregg (owner, level, point, name, openedEgg) VALUES (@owner, @level, @point, @name, @openedEgg) ON DUPLICATE KEY UPDATE level = level, openedEgg = openedEgg + 1, point = point + '..Config.EasterEggReward, {
        ['@owner'] = identifier,
        ['@level'] = 1,
        ['@point'] = Config.EasterEggReward,
        ['@name'] = fullname,
        ['@openedEgg'] = 1
    })
    Wait(100)
    local data = exports.oxmysql:executeSync('SELECT * FROM jenga_easteregg WHERE owner = @owner', {['@owner'] = identifier})
    if Config.Levels[tostring(data[1].level + 1)] then
        if data[1].point >= Config.Levels[tostring(data[1].level + 1)].maxPoint then
            exports.oxmysql:execute('UPDATE jenga_easteregg SET level = @level WHERE owner = @owner', {['@level'] = Config.Levels[tostring(data[1].level + 1)].level, ['@owner'] = identifier})
        end
        for key, value in pairs(Config.Levels[tostring(data[1].level)].rewards) do
            if value.point == data[1].point then
                if Config.Debug then
                    print("Reward: "..value.name.." Reward Type: "..value.type)
                end
                if value.type == "money" then
                    Player.Functions.AddMoney(value.name, value.count, 'EasterEgg-Reward')
                elseif value.type == "item" then
                    Player.Functions.AddItem(value.name, value.count)
                elseif value.type == "car" then
                    Config.CarReward(value.name)
                end
                TriggerClientEvent("jenga_easteregg:client:RequestReward", source, value)
                break
            end
        end

        if Config.Debug then
            print("User Point: "..data[1].point, "Level UP Point: "..Config.Levels[tostring(data[1].level + 1)].maxPoint, "Level UP Level: "..data[1].level + 1, "Current Level: "..data[1].level, "Current Point: "..data[1].point, "Current User: "..data[1].owner)
        end
    end
end

if QBCore then
    QBCore.Functions.CreateCallback('jenga_easteregg:server:getFullData', function (source, cb, data)
        local data = exports.oxmysql:executeSync('SELECT * FROM jenga_easteregg', {})
        if data[1] then
            cb(data)
        end
    end)

    QBCore.Functions.CreateCallback('jenga_easteregg:server:getData', function (source, cb)
        local Player = QBCore.Functions.GetPlayer(source)
        local data = exports.oxmysql:executeSync('SELECT * FROM jenga_easteregg WHERE owner = @owner', {['@owner'] = Player.PlayerData.citizenid})
        if data[1] then
            cb({ owner = Player.PlayerData.citizenid, level = data[1].level, point = data[1].point})
        else
            exports.oxmysql:execute('INSERT INTO jenga_easteregg (owner, level, point, name) VALUES (@owner, @level, @point, @name)', {
                ['@owner'] = Player.PlayerData.citizenid,
                ['@level'] = 1,
                ['@point'] = 0,
                ['@name'] = Player.PlayerData.charinfo.firstname.." "..Player.PlayerData.charinfo.lastname
            })
            
            cb({ owner = Player.PlayerData.citizenid, level = 1, point = 0})
        end
    end)

    QBCore.Functions.CreateCallback('jenga_easteregg:server:getEgg', function (source, cb, data)
        if not eggs.isFound and eggs.coord then
            cb(eggs.coord)
        elseif not eggs.coord then
            if data and data.z ~= 0.0 then
                eggs.isFound = false
                eggs.coord = data
                cb(eggs.coord)
            else
                TriggerClientEvent("jenga_easteregg:client:requestEgg", -1)
                cb(false)
            end
        else
            cb(false)
        end
        if Config.Debug then
            print(eggs.coord)
        end
    end)

    RegisterNetEvent("jenga_easteregg:server:openEgg", function(egg)
        local src = source
        if not eggs.isFound and eggs.coord == egg then
            eggs.isFound = true
            eggs.coord = nil
            TriggerClientEvent("jenga_easteregg:client:removeEgg", -1)
            local Player = QBCore.Functions.GetPlayer(src)
            AddPoint(source, Player)
        end
    end)
else
    ESX.RegisterServerCallback('jenga_easteregg:server:getFullData', function (source, cb, data)
        local data = exports.oxmysql:executeSync('SELECT * FROM jenga_easteregg', {})
        if data[1] then
            cb(data)
        end
    end)

    ESX.RegisterServerCallback('jenga_easteregg:server:getData', function (source, cb)
        local Player = ESX.GetPlayerFromId(source)
        local result = exports.oxmysql:executeSync('SELECT * FROM jenga_easteregg WHERE owner = @owner', {['@owner'] = Player.identifier })
        if result[1] then
            cb({ owner = Player.identifier, level = result[1].level, point = result[1].point})
        else
            exports.oxmysql:execute('INSERT INTO jenga_easteregg (owner, level, point, name) VALUES (@owner, @level, @point, @name)', {
                ['@owner'] = Player.identifier,
                ['@level'] = 1,
                ['@point'] = 0,
                ['@name'] = Player.PlayerData.charinfo.firstname.." "..Player.PlayerData.charinfo.lastname
            })

            cb({ owner = Player.identifier, level = 1, point = 0})
        end
    end)

    ESX.RegisterServerCallback('jenga_easteregg:server:getEgg', function (source, cb, data)
        if not eggs.isFound and eggs.coord then
            cb(eggs.coord)
        elseif not eggs.coord then
            if data and data.z ~= 0.0 then
                eggs.isFound = false
                eggs.coord = data
                cb(eggs.coord)
            else
                TriggerClientEvent("jenga_easteregg:client:requestEgg", -1)
                cb(false)
            end
        else
            cb(false)
        end
        if Config.Debug then
            print(eggs.coord)
        end
    end)

    RegisterNetEvent("jenga_easteregg:server:openEgg", function(egg)
        local src = source
        if not eggs.isFound and eggs.coord == egg then
            eggs.isFound = true
            eggs.coord = nil
            TriggerClientEvent("jenga_easteregg:client:removeEgg", -1)
            local Player = ESX.GetPlayerFromId(src)
            AddPoint(source, Player)
        end
    end)
end