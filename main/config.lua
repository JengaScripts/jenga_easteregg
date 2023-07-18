Config = {}

Config.LeaderboardCommand = "eggpas"
Config.LevelPanelCommand = "egg"
Config.ItemsImgPath = "qb-inventory/html/images/" -- For ESX ox_inventory/web/images/ or esx_inventory/html/img/items/

Config.Center_X = -1951.52
Config.Center_Y = 1536.36
Config.Radius = 650.0

-- Config.CreateEggInterval = (60 * 1000) * 15 -- 15 Min, When egg is opened, it will create again in 15 Min
Config.CreateEggInterval = 5000
Config.Prop = `prop_alien_egg_01`

Config.Target = true
Config.TargetExport = "qb-target"

Config.Debug = false

if IsDuplicityVersion then
    Config.CarReward = function(vehicleModel)

    end
end

Config.EasterEggReward = 20 -- Each Egg Will Give 50 Point

Config.Levels = {
    ["1"] = {
        level = 1,
        maxPoint = 0,
        rewards = {
            {
                type = "car",
                name = "t20",
                point = 20
            },
            {
                type = "item",
                name = "weapon_pistol",
                count = 1,
                point = 40
            },
            {
                type = "money",
                name = "cash",
                count = 1,
                point = 60
            },
            {
                type = "money",
                name = "bank",
                count = 1,
                point = 80
            },
            {
                type = "car",
                name = "t20",
                point = 100
            }
        }
    },
    ["2"] = {
        level = 2,
        maxPoint = 100,
        rewards = {
            {
                type = "car",
                name = "t20",
                point = 120
            },
            {
                type = "item",
                name = "weapon_pistol",
                count = 1,
                point = 140
            },
            {
                type = "money",
                name = "cash",
                count = 1,
                point = 160
            },
            {
                type = "money",
                name = "bank",
                count = 1,
                point = 180
            },
            {
                type = "car",
                name = "t20",
                point = 200
            }
        }
    },
    ["3"] = {
        level = 3,
        maxPoint = 200,
        rewards = {
            {
                type = "car",
                name = "t20",
                point = 220
            },
            {
                type = "item",
                name = "weapon_pistol",
                count = 1,
                point = 240
            },
            {
                type = "money",
                name = "cash",
                count = 1,
                point = 260
            },
            {
                type = "money",
                name = "bank",
                count = 1,
                point = 280
            },
            {
                type = "car",
                name = "t20",
                point = 300
            }
        }
    }
}