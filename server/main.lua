ESX                = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('esx_murder:reward')
AddEventHandler('esx_murder:reward', function(Documents)
    local xPlayer = ESX.GetPlayerFromId(source)
    print(Documents)
    xPlayer.addInventoryItem('docs', Documents)
end)

RegisterServerEvent('esx_murder:sell')
AddEventHandler('esx_murder:sell', function()
    local xPlayer = ESX.GetPlayerFromId(source)

    local DocsPrice = 1500
    local DocsQuantity = xPlayer.getInventoryItem('docs').count

    if DocsQuantity > 0 then
        xPlayer.addAccountMoney('black_money', DocsQuantity * DocsPrice)

        xPlayer.removeInventoryItem('docs', DocsQuantity)
        TriggerClientEvent('esx:showNotification', xPlayer.source, 'You sold ' .. DocsQuantity .. ' and earned $' .. DocsQuantity * DocsPrice)
    else
        TriggerClientEvent('esx:showNotification', xPlayer.source, 'You don\'t have any documents')
    end
        
end)

function sendNotification(xsource, message, messageType, messageTimeout)
    TriggerClientEvent('notification', xsource, message)
end