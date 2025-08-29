local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('qb-illegaldoctor:payAndHeal', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local price = 1500

    if Player.Functions.RemoveMoney("cash", price, "illegal-doctor") then
        TriggerClientEvent("qb-illegaldoctor:clientDoHeal", src)
    else
        TriggerClientEvent('QBCore:Notify', src, "You don’t have enough cash!", "error")
    end
end)
