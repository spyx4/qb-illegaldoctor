local QBCore = exports['qb-core']:GetCoreObject()
local doctorPed = nil
local doctorCoords = vector4(1664.1, -28.18, 182.77, 104.69)

-- Spawn shady doctor ped
CreateThread(function()
    local model = `s_m_m_doctor_01`
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end

    -- Ensure collision is loaded at coords
    RequestCollisionAtCoord(doctorCoords.x, doctorCoords.y, doctorCoords.z)
    while not HasCollisionLoadedAroundEntity(PlayerPedId()) do Wait(0) end

    doctorPed = CreatePed(4, model, doctorCoords.x, doctorCoords.y, doctorCoords.z, doctorCoords.w, false, true)

    -- Place correctly on ground
    SetEntityCoords(doctorPed, doctorCoords.x, doctorCoords.y, doctorCoords.z, false, false, false, true)
    PlaceObjectOnGroundProperly(doctorPed)

    -- Doctor attributes (no fleeing, no combat, no ragdoll)
    SetEntityInvincible(doctorPed, true)
    SetBlockingOfNonTemporaryEvents(doctorPed, true)
    SetPedFleeAttributes(doctorPed, 0, false)  -- disable fleeing
    SetPedCombatAttributes(doctorPed, 46, true) -- disable combat
    SetPedCanRagdoll(doctorPed, false) -- prevent ragdoll physics

    -- Idle clipboard animation
    TaskStartScenarioInPlace(doctorPed, "WORLD_HUMAN_CLIPBOARD", 0, true)

    -- qb-target interaction
    exports['qb-target']:AddTargetEntity(doctorPed, {
        options = {
            {
                type = "client",
                event = "qb-illegaldoctor:startTreatment",
                icon = "fas fa-user-md",
                label = "Get Treated ($1500)",
            }
        },
        distance = 2.5
    })
end)

-- Make sure doctor always goes back to clipboard animation
CreateThread(function()
    while true do
        Wait(5000) -- check every 5 seconds
        if doctorPed and DoesEntityExist(doctorPed) then
            if not IsPedUsingScenario(doctorPed, "WORLD_HUMAN_CLIPBOARD") then
                ClearPedTasks(doctorPed)
                TaskStartScenarioInPlace(doctorPed, "WORLD_HUMAN_CLIPBOARD", 0, true)
            end
        end
    end
end)

-- Progressbar treatment
RegisterNetEvent("qb-illegaldoctor:startTreatment", function()
    local ped = PlayerPedId()

    -- Play lying animation
    RequestAnimDict("amb@world_human_sunbathe@male@back@base")
    while not HasAnimDictLoaded("amb@world_human_sunbathe@male@back@base") do Wait(0) end
    TaskPlayAnim(ped, "amb@world_human_sunbathe@male@back@base", "base", 2.0, -1, -1, 1, 0, false, false, false)

    QBCore.Functions.Progressbar("illegal_doctor_heal", "The shady doctor is treating your wounds...", 60000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() -- On complete
        ClearPedTasks(ped)
        TriggerServerEvent("qb-illegaldoctor:payAndHeal")
    end, function() -- On cancel
        ClearPedTasks(ped)
        QBCore.Functions.Notify("Treatment cancelled...", "error")
    end)
end)

-- Heal client
RegisterNetEvent("qb-illegaldoctor:clientDoHeal", function()
    TriggerEvent('hospital:client:Revive')
    QBCore.Functions.Notify("The shady doctor patched you up after a long treatment.", "success")
end)
