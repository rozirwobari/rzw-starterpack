local ESX = exports["es_extended"]:getSharedObject()
local playerStarterpack = {}

local function CreateDatabase()
    MySQL.query(
    [[
        CREATE TABLE IF NOT EXISTS `rzw_starterpack` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `identifier` varchar(150) NOT NULL,
            `name` varchar(250) NOT NULL,
            `time` int(11) NOT NULL DEFAULT 0,
            PRIMARY KEY (`id`)
        );
    ]]
    , {}, function(result)
        if result and result.warningStatus == 0 then
            print("^3[rzw-starterpack]^0 ^2Table rzw_starterpack Not Found! Creating Table...^0")
            Wait(3000)
            print("^3[rzw-starterpack]^0 ^2Table rzw_starterpack Created Successfully.^0")
        else
            print("^3[rzw-starterpack]^0 ^2Table rzw_starterpack is Already Available.^0")
        end
    end)
end

local function LoadedStarterpack()
    CreateDatabase()
    Wait(3000)
    local response = MySQL.query.await('SELECT * FROM rzw_starterpack', {})
    if response then
        for key, value in pairs(response) do
            playerStarterpack[value.identifier] = value
        end
    end
end

lib.callback.register('rzw-starterpack:server:Checked', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local Config = lib.load('shared.main')
    Wait(500)
    if playerStarterpack[xPlayer.identifier] then
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Starterpack',
            description = 'You have already taken the starterpack.',
            duration = 8000,
            type = 'error',
            position = 'top',
            style = {
                backgroundColor = '#141517',
                color = '#C1C2C5',
                ['.description'] = {
                    color = '#909296'
                }
            }
        })
        return false
    else
        local row = MySQL.single.await('SELECT identifier FROM rzw_starterpack WHERE identifier = ? LIMIT 1', {
            xPlayer.identifier
        })
        if row?.identifier then
            TriggerClientEvent('ox_lib:notify', source, {
                title = 'Starterpack',
                description = 'You have already taken the starterpack.',
                duration = 8000,
                type = 'error',
                position = 'top',
                style = {
                    backgroundColor = '#141517',
                    color = '#C1C2C5',
                    ['.description'] = {
                        color = '#909296'
                    }
                }
            })
            playerStarterpack[row?.identifier] = row
            return false
        end

        local os_time = os.time()
        local success, id = pcall(function ()
            local id = MySQL.insert.await('INSERT INTO rzw_starterpack (identifier, name, time) VALUES (?, ?, ?)', {
                xPlayer.identifier,
                xPlayer.name,
                os_time,
            })
            return id
        end)
        if success and id then
            playerStarterpack[xPlayer.identifier] = {
                time = os_time,
                identifier = xPlayer.identifier,
                name = xPlayer.name,
            }
            for key, value in pairs(Config.Items) do
                local itemData = exports.ox_inventory:Items(value.item)
                if itemData then
                    exports.ox_inventory:AddItem(xPlayer.source, value.item, value.count)
                end
            end
            return true
        end
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Starterpack',
            description = 'Failed to Retrieve Starterpack, Please Contact Admin Regarding This Issue.',
            duration = 8000,
            type = 'error',
            position = 'top',
            style = {
                backgroundColor = '#141517',
                color = '#C1C2C5',
                ['.description'] = {
                    color = '#909296'
                }
            }
        })
        return false
    end
end)

Citizen.CreateThread(function ()
    Wait(1000)
    LoadedStarterpack()
end)