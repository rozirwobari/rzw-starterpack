local ESX = exports["es_extended"]:getSharedObject()
local RZWStarterpack = {}
local Config = lib.load('shared.main')

function RZWStarterpack:Init()
    self.StarterpackDataCache = {}
    self:DatabaseSetUp()

    lib.callback.register('rzw-starterpack:server:CheckPlayer', function(source)
        return self:Checking(source)
    end)

    RegisterServerEvent("rzw-starterpack:server:GetStarterpack")
    AddEventHandler("rzw-starterpack:server:GetStarterpack", function ()
        local xPlayer = ESX.GetPlayerFromId(source)
        if not xPlayer then return false end
        if self:Checking(xPlayer.source) then
            self:GivingItems(xPlayer)
        end
    end)
end

function RZWStarterpack:GivingItems(xPlayer)
    for key, value in pairs(Config.Items) do
        exports.ox_inventory:AddItem(xPlayer.source, value.item, value.count)
    end

    local GetTime = os.time()
    local id = MySQL.insert.await('INSERT INTO rzw_starterpack (identifier, name, time) VALUES (?, ?, ?)', {
        xPlayer.identifier,
        xPlayer.name,
        GetTime
    })
    if id > 0 then
        self.StarterpackDataCache[xPlayer.identifier] = {
            time = GetTime
        }
    end
end

function RZWStarterpack:Checking(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        TriggerClientEvent('ox_lib:notify', xPlayer.source, {
            title = 'Failed',
            description = 'Player not found',
            type = 'warning',
            icon = 'fa-solid fa-triangle-exclamation',
            position = 'top-center',
            duration = 5000,
        })
        return false
    end

    local GetData = self.StarterpackDataCache[xPlayer.identifier]
    if GetData then
        TriggerClientEvent('ox_lib:notify', xPlayer.source, {
            title = 'Failed',
            description = 'You already have starterpack.\n\n'..self:FormatDate(GetData.time),
            type = 'warning',
            icon = 'fa-solid fa-triangle-exclamation',
            position = 'top-center',
            duration = 5000,
        })
        return false
    end

    local row = MySQL.single.await('SELECT time FROM rzw_starterpack WHERE identifier = ? LIMIT 1', {
        xPlayer.identifier
    })
    if row then
        self.StarterpackDataCache[xPlayer.identifier] = {
            time = row.time
        }
        TriggerClientEvent('ox_lib:notify', xPlayer.source, {
            title = 'Failed',
            description = 'You already have starterpack.\n\n'..self:FormatDate(row.time),
            type = 'warning',
            icon = 'fa-solid fa-triangle-exclamation',
            position = 'top-center',
            duration = 5000,
        })
        return false
    end
    return true
end

function RZWStarterpack:DatabaseSetUp()
    local response = MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `rzw_starterpack` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `identifier` varchar(150) NOT NULL,
            `name` varchar(250) NOT NULL,
            `time` int(11) NOT NULL DEFAULT 0,
            PRIMARY KEY (`id`)
        );
    ]], {})
    if response and response.warningStatus == 0 then
        print("^3[rzw-starterpack]^0 ^2Table rzw_starterpack Not Found! Creating Table...^0")
        Wait(1000)
        print("^3[rzw-starterpack]^0 ^2Table rzw_starterpack Created Successfully.^0")
    else
        print("^3[rzw-starterpack]^0 ^2Table rzw_starterpack is Already Available.^0")
    end
end

function RZWStarterpack:FormatDate(time)
    return os.date("%d %B %Y | %H:%M", time)
end

RZWStarterpack:Init()