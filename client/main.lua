local RZWStarterpack = {}
local Config = lib.load('shared.main')

function RZWStarterpack:Init()
    for key, value in pairs(Config.Location) do
        if value.ped and value.ped ~= '' then
            self:CreatePed(value.ped, value.coords)
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
                        self:GetStarterpack()
                    end
                }
            }
        })
    end
end

function RZWStarterpack:GetStarterpack()
    local CheckPlayer = lib.callback.await('rzw-starterpack:server:CheckPlayer', false)
    if not CheckPlayer then return end
    if lib.progressBar({
        duration = 10000,
        label = 'Get Starterpack',
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = true,
            car = true,
            combat = true,
            sprint = true,
        },
        anim = {
            scenario = 'CODE_HUMAN_MEDIC_TIME_OF_DEATH',
        }
    }) then
        TriggerServerEvent("rzw-starterpack:server:GetStarterpack")
    end
end

function RZWStarterpack:CreatePed(model, coords)
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
end

RZWStarterpack:Init()