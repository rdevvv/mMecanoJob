ESX = nil

ESX = exports["es_extended"]:getSharedObject()

TriggerEvent('esx_society:registerSociety', 'mechanic', 'mechanic', 'society_mechanic', 'society_mechanic', 'society_mechanic', {type = 'public'})

RegisterNetEvent('WLTD:RemoveItem')
AddEventHandler('WLTD:RemoveItem', function(Nom, Item)
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)
    xPlayer.removeInventoryItem(Item, 1)
end)


RegisterServerEvent('Mechanic:Ouvert')
AddEventHandler('Mechanic:Ouvert', function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local xPlayers    = ESX.GetPlayers()
    for i=1, #xPlayers, 1 do
        local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		TriggerClientEvent('esx:showAdvancedNotification', xPlayers[i], 'Mecano', '~p~Annonce', 'Le Bennys ouvres c\'est porte ~g~ouvert ~s~!', 'CHAR_CARSITE3', 8)
    end
end)

RegisterServerEvent('Mechanic:Fermer')
AddEventHandler('Mechanic:Fermer', function()
    local xPlayer = ESX.GetPlayerFromId(_source)
    local xPlayers    = ESX.GetPlayers()
    for i=1, #xPlayers, 1 do
        local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		TriggerClientEvent('esx:showAdvancedNotification', xPlayers[i], 'Mecano', '~p~Annonce', 'Le Bennys Est Fermer Repasser plus ~g~ouvert ~s~!', 'CHAR_CARSITE3', 8)
    end
end)

RegisterNetEvent('Mecaperso')
AddEventHandler('Mecaperso', function(msg)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local xPlayers    = ESX.GetPlayers()
    for i=1, #xPlayers, 1 do
        local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
        TriggerClientEvent('esx:showAdvancedNotification', xPlayers[i], 'Mécano', '~p~Annonce', msg, 'CHAR_CARSITE3', 8)
    end
end)

ESX.RegisterServerCallback('Mechanic:getItemAmount', function(source, cb, item)
    local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local quantity = xPlayer.getInventoryItem(item).count

	cb(quantity)
end)

RegisterNetEvent('Mechanic:removeItem')
AddEventHandler('Mechanic:removeItem', function(item)
    local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	xPlayer.removeInventoryItem(item, 1)
end)