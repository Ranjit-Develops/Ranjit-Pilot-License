QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('ranjit-pilot:driverpaymentpassed', function ()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.AddItem("driver_license", 1)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["driver_license"], 'add')
end)

RegisterNetEvent('ranjit-pilot:driverpaymentfailed', function ()
    local amount = Config.Amount['driving']/2
    local _source = source
    local Player = QBCore.Functions.GetPlayer(_source)
    Player.Functions.RemoveMoney(Config.PaymentType, amount)
    TriggerClientEvent('ranjit-pilot:Notify', source, 'You paid $'..amount, 3000, 'error', 'Paid')
end)

