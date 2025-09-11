local Config = lib.load('shared.main')

local function CreatePedStarterpack(model, coords)
    lib.requestModel(model, 10000)
    local npc = CreatePed(4, model, coords.x, coords.y, (coords.z - 1.0), coords.w, false, true)
    SetEntityInvincible(npc, true)
    SetEntityAsMissionEntity(npc, true, true)
    SetPedRandomComponentVariation(npc, 1)
    SetBlockingOfNonTemporaryEvents(npc, true)
    SetPedDiesWhenInjured(npc, false)
    SetPedCanPlayAmbientAnims(npc, true)
    SetPedCanRagdollFromPlayerImpact(npc, false)
    FreezeEntityPosition(npc, true)
    return npc
end

local function GetStarterpack()
    local Checked = lib.callback.await('rzw-starterpack:server:Checked', false)
    if Checked then
        return lib.notify({
            title = 'Starterpack',
            description = 'You have successfully taken the starterpack.',
            duration = 8000,
            type = 'success',
            position = 'top',
            style = {
                backgroundColor = '#141517',
                color = '#C1C2C5',
                ['.description'] = {
                    color = '#909296'
                }
            }
        })
    end
end

Citizen.CreateThread(function ()
    Wait(1000)
    for key, value in pairs(Config.Location) do
        if value.ped and value.ped ~= '' then
            CreatePedStarterpack(value.ped, value.coords)
        end
        exports.ox_target:addSphereZone({
            coords = vec3(value.coords.x, value.coords.y, value.coords.z),
            radius = 2.0,
            options = {
                {
                    label = "Get Starterpack",
                    icon = "fa-solid fa-gift",
                    distance = 2.0,
                    onSelect = function ()
                        GetStarterpack()
                    end
                }
            }
        })
    end
end)