ESX = nil
local diag = nil

Citizen.CreateThread(function()
	ESX = exports["es_extended"]:getSharedObject()

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	ESX.PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer 
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
	Citizen.Wait(10)
end)

------Diagnostique


local options = {
    {
        name = 'Target',
        event = 'esx_mecanojob:menu-diag',
        icon = 'fa-solid fa-road',
        label = 'Diag',
		groups= {['mechanic'] = 0}

	
    },
}
  
  exports.ox_target:addGlobalVehicle(options)


  RegisterNetEvent("esx_mecanojob:menu-diag")
  AddEventHandler("esx_mecanojob:menu-diag", function(data)
	  local playerPed = PlayerPedId()
	  local vehicle   = data.entity
	  local carModel = GetEntityModel(data.entity)
	  local coords    = GetEntityCoords(playerPed)
	  local text = "* L'individu diagnostique le véhicule *"
  
	  if IsPedSittingInAnyVehicle(playerPed) then
		  lib.notify({
			title = 'Mécano Infos',
			description = 'Ne fais pas sa à l\'intérieur du véhicules',
			type = 'error'
		})
		  return
	  end
  
	  if DoesEntityExist(vehicle) then
		  SetVehicleDoorOpen(data.id, 4, false)
		  IsBusy = true
		  TaskStartScenarioInPlace(playerPed, "PROP_HUMAN_BUM_BIN", 0, true)
		  Citizen.CreateThread(function()
			  TriggerServerEvent('3dme:shareDisplay', text)
			  Citizen.Wait(15000)
			  local veh_prop = ESX.Game.GetVehicleProperties(data.entity)
			  local etat_moteur = "Inconnu"
			  print(veh_prop)
			  print("ETAT MOTEUR : " .. tonumber(veh_prop.engineHealth))
			  if tonumber(veh_prop.engineHealth) >= 950 then
				  etat_moteur = "~g~Bon état~w~\n\nTemps de réparation : 5 min\nTarif : 100$"
			  elseif tonumber(veh_prop.engineHealth) < 950 and tonumber(veh_prop.engineHealth) >= 900 then
				  etat_moteur = "~y~Correct~w~\n\nTemps de réparation : 10 min\nTarif : 125$"
			  elseif tonumber(veh_prop.engineHealth) < 900 and tonumber(veh_prop.engineHealth) >= 850 then
				  etat_moteur = "~o~Médiocre~w~\n\nTemps de réparation : 30 min\nTarif : 150$"
			  elseif tonumber(veh_prop.engineHealth) < 850 then
				  etat_moteur = "~r~DANGER\n\nTemps de réparation : 60 min\nTarif : 175$"
			  end
			  diag = veh_prop.plate
			  ESX.ShowAdvancedNotification('Mécano', "Diagnostique", "Diagnostique du véhicule :\nMoteur : " .. etat_moteur, "CHAR_GANGAPP", 1)
			  ClearPedTasksImmediately(playerPed)
			  SetVehicleDoorShut(data.id, 4, false)
		  end)
	  else
		  lib.notify({
			title = 'Mécano Infos',
			description = 'Pas de voiture a cotée',
			type = 'error'
		})
	  end
  end)

-----Reparation


local options = {
    {
        name = 'Target',
        event = 'esx_mecanojob:menu-repair',
        icon = 'fa-solid fa-road',
        label = 'Repair',
		groups= 'mechanic',
    },
}
  
  exports.ox_target:addGlobalVehicle(options)

RegisterNetEvent("esx_mecanojob:menu-repair")
AddEventHandler("esx_mecanojob:menu-repair", function(data)
	local playerPed = PlayerPedId()
	local vehicle   = data.entity
	local coords    = GetEntityCoords(playerPed)
	local text = "* L'individu répare le véhicule *"

	if IsPedSittingInAnyVehicle(playerPed) then
		ESX.ShowNotification("Vous devez etre dans une voiture")
		return
	end

	if DoesEntityExist(vehicle) then
		if ESX.Game.GetVehicleProperties(vehicle).plate == diag then
			IsBusy = true
			SetVehicleDoorOpen(data.id, 4, false)
			TaskStartScenarioInPlace(playerPed, "PROP_HUMAN_BUM_BIN", 0, true)
			TriggerServerEvent('3dme:shareDisplay', text)
			Citizen.CreateThread(function()
				Citizen.Wait(15000)

				local fuel = GetVehicleFuelLevel(vehicle)
				SetVehicleFixed(vehicle)
				SetVehicleFuelLevel(vehicle, fuel)
				SetVehicleDeformationFixed(vehicle)
				SetVehicleUndriveable(vehicle, false)
				SetVehicleEngineOn(vehicle, true, true)
				ClearPedTasksImmediately(playerPed)
				SetVehicleDoorShut(data.id, 4, false)

				lib.notify({
					title = 'Mecano Infos',
					description = 'Vehicle Réparer',
					type = 'succes'
				})
				IsBusy = false
			end)
		else
			ESX.ShowNotification("Vous n'avez pas fait le diagnostique du véhicule.")
		end
	else
		lib.notify({
		title = 'Notification title',
		description = 'Pas de voiture a cotée',
		type = 'error'
		})
	end
end)



---------------TowTruck Remoquarge


local options = {
    {
        name = 'Target',
        event = 'white:tow',
        icon = 'fa-solid fa-road',
        label = 'Mettre sur le plateau',
		groups= 'mechanic',
    },
}
  
  exports.ox_target:addGlobalVehicle(options)

  local options = {
    {
        name = 'Target',
        event = 'white:tow',
        icon = 'fa-solid fa-road',
        label = 'Descendre du plateau',
		groups= 'mechanic',
    },
}


local currentlyTowedVehicle = nil

RegisterNetEvent('white:tow')
AddEventHandler('white:tow', function()
	
	local playerped = GetPlayerPed(-1)
	local vehicle = GetVehiclePedIsIn(playerped, true)
	
	local towmodel = GetHashKey('flatbed')
	local isVehicleTow = IsVehicleModel(vehicle, towmodel)
			
	if isVehicleTow then
	
		local coordA = GetEntityCoords(playerped, 1)
		local coordB = GetOffsetFromEntityInWorldCoords(playerped, 0.0, 5.0, 0.0)
		local targetVehicle = getVehicleInDirection(coordA, coordB)
		
		if currentlyTowedVehicle == nil then
			if targetVehicle ~= 0 then
				if not IsPedInAnyVehicle(playerped, true) then
					if vehicle ~= targetVehicle then
						AttachEntityToEntity(targetVehicle, vehicle, 20, -0.5, -5.0, 1.0, 0.0, 0.0, 0.0, false, false, false, false, 20, true)
						currentlyTowedVehicle = targetVehicle
						lib.notify({
							title = 'Mécnao Job',
							description = 'Véhicules attacher avec succès',
							type = 'success'
						})
					else
						lib.notify({
							title = 'Mécano Job',
							description = 'Es tu attardé? Vous ne pouvez pas remorquer votre propre dépanneuse avec votre propre dépanneuse?',
							type = 'error'
						})
					
					end
				end
			else
				lib.notify({
					title = 'Mécano Job',
					description = 'Es tu attardé? Vous ne pouvez pas remorquer votre propre dépanneuse avec votre propre dépanneuse?',
					type = 'error'
				})
			end
		else
			AttachEntityToEntity(currentlyTowedVehicle, vehicle, 20, -0.5, -12.0, 1.0, 0.0, 0.0, 0.0, false, false, false, false, 20, true)
			DetachEntity(currentlyTowedVehicle, true, true)
			currentlyTowedVehicle = nil
			lib.notify({
				title = 'Mécano Job',
				description = 'Le véhicule a été détaché avec succès!',
				type = 'succes'
			})
		
		end
	end
end)

function getVehicleInDirection(coordFrom, coordTo)
	local rayHandle = CastRayPointToPoint(coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z, 10, GetPlayerPed(-1), 0)
	local a, b, c, d, vehicle = GetRaycastResult(rayHandle)
	return vehicle
end






-------------Lave Auto

  exports.ox_target:addGlobalVehicle(options)


  local options = {
    {
        name = 'Target',
        event = 'LaverVoiture',
        icon = 'fa-solid fa-eraser fa-beat',--<<font-awesome-icon :icon="['fat', 'car-wash']" />
        label = 'Laver la voiture',
		groups= 'mechanic',
    },
}
  
  exports.ox_target:addGlobalVehicle(options)

  RegisterNetEvent("LaverVoiture")
  AddEventHandler("LaverVoiture", function(data)
    ESX.TriggerServerCallback("Mechanic:getItemAmount", function(amount)
      if amount >= 1 then
        TaskStartScenarioInPlace(PlayerPedId(), 'WORLD_HUMAN_MAID_CLEAN', 0, true)
        Citizen.Wait(10*1000)
        ClearPedTasks(PlayerPedId())
        WashDecalsFromVehicle(data.id, 1.0)
        SetVehicleDirtLevel(data.id)
		TriggerServerEvent('Mechanic:removeItem', 'chiffon')
		lib.notify({
			title = 'Mécano Job',
			description = 'Le véhicule est maintenant propre.',
			type = 'succes'
			})
      else
		lib.notify({
			title = 'Mécano Job',
			description = 'Tu n\'as pas de chiffon sur toi',
			type = 'error'
			})
      end
  end, "chiffon")
  end)



------------------Menu Annonce

RegisterNetEvent('Mechanic:ouvert')
AddEventHandler('Mechanic:ouvert', function()
TriggerServerEvent('Mechanic:Ouvert')
end)

RegisterNetEvent('Mechanic:fermer')
AddEventHandler('Mechanic:fermer', function()
TriggerServerEvent('Mechanic:Fermer')
end)

RegisterNetEvent('Mecaperso')
AddEventHandler('Mecaperso', function()
local msg = KeyboardInput("Message", "", 100)
TriggerServerEvent('Mecaperso', msg)
end)

CreateThread(function()
	for k, v in pairs(Config.Ano) do
  exports.ox_target:addBoxZone({
    coords = vec3(v.coords),
    size = vec3(1, 1, 2),
    rotation = 45,
    debug = drawZones,
    options = {
        {
            name = 'box',
			event = "white:annonce",
            icon = 'fa-brands fa-snapchat fa-beat',
            label = 'Annonce Mécano',
        }
    }
})
end
end)

RegisterNetEvent('white:annonce', function(data)
	lib.registerContext({
		id = 'Menu Annonce',
		title = 'Menu Annonce',
		onExit = function()
			print('Menu fermer')
		end,
		options = {
			{
				title = 'Annonce Ouverture ',
				description = 'Faire l\'annonce d\'ouverture',
				arrow = true,
				event = "Mechanic:ouvert",
			},
			{
				title = 'Annonce Fermeture',
				description = 'Faire l\'annonce de la fermeture',
				arrow = true,
				event = 'Mechanic:fermer',
			},
			{
				title = 'Annonce Perso',
				description = 'Faire l\'annonce Personalisée',
				arrow = true,
				event = 'Mecaperso',
			}
			
		},
	})

	lib.showContext('Menu Annonce')
	
end)


function KeyboardInput(TextEntry, ExampleText, MaxStringLenght)
    AddTextEntry('FMMC_KEY_TIP1', TextEntry)
    blockinput = true
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLenght)
    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do 
        Wait(0)
    end 
        
    if UpdateOnscreenKeyboard() ~= 2 then
        local result = GetOnscreenKeyboardResult()
        Wait(500)
        blockinput = false
        return result
    else
        Wait(500)
        blockinput = false
        return nil
    end
end



---------------Bossss

CreateThread(function()
	for k, v in pairs(Config.Boss) do
exports.ox_target:addBoxZone({
    coords = vec3(v.coords),
    size = vec3(1, 1, 2),
    rotation = 45,
    debug = drawZones,
    options = {
        {
            name = 'box',
			event = "Mecanojob:OpenBossMenu",
            icon = 'fa-solid fa-desktop',
            label = 'BossAction',
        }
    }
})
end
end)



RegisterNetEvent('Mecanojob:OpenBossMenu')
AddEventHandler('Mecanojob:OpenBossMenu',function()
    OpenBossMenu()
end)

function OpenBossMenu()
	TriggerEvent('esx_society:openBossMenu', 'mechanic', function(data, menu)
		menu.close()
		end, { wash = false })
end






----------- Vestiaire


CreateThread(function()
	for k, v in pairs(Config.vet) do
	exports.ox_target:addBoxZone({
		coords = vec3(v.coords),
		size = vec3(1, 1, 1),
		rotation = 45,
		debug = drawZones,
		options = {
			{
				name = 'Vestiaire',
				event = 'white:mechanic',
				icon = 'fa-solid fa-shirt fa-beat',
				label = 'Vestiaire Mécano',
				canInteract = function(entity, distance, coords, name)
					return true
				end
			}
		}
	})
	end
	end)

RegisterNetEvent('white:mechanic', function(data)
	lib.registerContext({
		id = 'Menu Vetements',
		title = 'Menu Vetements',
		onExit = function()
		end,
		options = {
			{
				title = 'Tenue Civil',
				description = 'Prendre sa tenue civil',
				arrow = true,
				event = 'mechanicclothes',
				args = {value1 = 300, value2 = 'Other value'}
			},
			{
				title = 'Tenue De servic',
				description = 'Prendre sa tenue de service',
				arrow = true,
				event = 'mechanictenue',
				args = {value1 = 300, value2 = 'Other value'}
			}
		}
	})

	lib.showContext('Menu Vetements')
	
end)

RegisterNetEvent('mechanicclothes')
AddEventHandler('mechanicclothes', function()
    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
        local isMale = skin.sex == 0

        TriggerEvent('skinchanger:loadDefaultModel', isMale, function()
            ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
                TriggerEvent('skinchanger:loadSkin', skin)
                TriggerEvent('esx:restoreLoadout')
            end)
        end)

    end)
end)

RegisterNetEvent('mechanictenue')
AddEventHandler('mechanictenue', function()
    local playerPed = PlayerPedId()
    setUniform('mechanic_wear', playerPed)
end)

function setUniform(job, playerPed)
    TriggerEvent('skinchanger:getSkin', function(skin)
        if skin.sex == 0 then
            if Config.Uniforms[job].male ~= nil then
                TriggerEvent('skinchanger:loadClothes', skin, Config.Uniforms[job].male)
            else
                ESX.ShowNotification(('Pas d\'outfits'))
            end

            if job == 'mechanic_wear' then
                SetPedArmour(playerPed, 100)
            end
        else
            if Config.Uniforms[job].female ~= nil then
                TriggerEvent('skinchanger:loadClothes', skin, Config.Uniforms[job].female)
            else
                ESX.ShowNotification(('Pas d\'outfits'))
            end

            if job == 'mechanic_wear' then
                SetPedArmour(playerPed, 100)
            end
        end
    end)
end




-----Blips

Citizen.CreateThread(function()

    local blipMarker = Config.Blips.MECHANIC
    local blipCoord = AddBlipForCoord(blipMarker.Pos.x, blipMarker.Pos.y, blipMarker.Pos.z)

    SetBlipSprite (blipCoord, blipMarker.Sprite)
    SetBlipDisplay(blipCoord, blipMarker.Display)
    SetBlipScale  (blipCoord, blipMarker.Scale)
    SetBlipColour (blipCoord, blipMarker.Colour)
    SetBlipAsShortRange(blipCoord, true)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Bennys")
    EndTextCommandSetBlipName(blipCoord)


end)





---------------Menu F6




RegisterNetEvent('white:diag', function(data)
	lib.registerContext({
		id = 'Menu Diag',
		title = 'Menu Diag',
		onExit = function()
			print('Hello there')
		end,
		options = {
			{
				title = 'Annonce Diag ',
				description = 'Faire l\'Diag d\'ouverture',
				arrow = true,
				event = "esx_mecanojob:menu-diag",
			},
			{
				title = 'Annonce Fermeture',
				description = 'Faire l\'annonce de la fermeture',
				arrow = true,
				event = 'Mechanic:fermer',
			},
			{
				title = 'Annonce Perso',
				description = 'Faire l\'annonce Personalisée',
				arrow = true,
				event = 'Mecaperso',
			}
			
		},
	})

	lib.showContext('Menu Diag')
	
end)


RegisterNetEvent('white:annonce', function(data)
	lib.registerContext({
		id = 'Menu Annonce',
		title = 'Menu Annonce',
		onExit = function()
			print('Hello there')
		end,
		options = {
			{
				title = 'Annonce Ouverture ',
				description = 'Faire l\'annonce d\'ouverture',
				arrow = true,
				event = "Mechanic:ouvert",
			},
			{
				title = 'Annonce Fermeture',
				description = 'Faire l\'annonce de la fermeture',
				arrow = true,
				event = 'Mechanic:fermer',
			},
			{
				title = 'Annonce Perso',
				description = 'Faire l\'annonce Personalisée',
				arrow = true,
				event = 'Mecaperso',
			}
			
		},
	})

	lib.showContext('Menu Annonce')
	
end)


function menuf6mecano()
	if ESX.PlayerData.job and ESX.PlayerData.job.name == 'mechanic' then
        lib.registerContext({
            id = 'mecanof6',
            title = 'Menu Mecano',
            onExit = function()
            end,
            options = {
                {
                    title = 'Annonce',
                    description = 'Annonce',
                    event = 'white:annonce'
                },
				{
                    title = 'Diag',
                    description = 'Diag',
                    event = 'white:diag'
                },
            }
        })
    lib.showContext('mecanof6')
	end
end


RegisterCommand("mecano", function()
    local user = PlayerPedId()	
	menuf6mecano()
end)

RegisterKeyMapping("mecano", "Open your car menu", "keyboard", "i")



local posMenu = Config.Ano.Ano.coords

Citizen.CreateThread(function()
        while true do
            local Timer = 500
            local plyPos = GetEntityCoords(PlayerPedId())
            local dist = #(plyPos-posMenu)
            if ESX.PlayerData.job and ESX.PlayerData.job.name == 'mechanic' then
                if dist <= 2.0 then
                    Timer = 0
                    DrawMarker(26, posMenu, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.45, 0.45, 0.45, 0, 178, 255, 255, 0, false, true, 0, false, false, false, false)
                end
                if dist <= 1.5 then
                    Timer = 0
                    TriggerEvent("ui:showInteraction", "E", "INTERACTION") 
                    if IsControlJustPressed(1,51) then
                       TriggerEvent('white:annonce')
                    end
                end
            end
        Citizen.Wait(Timer)
    end
end)


local posMenu = Config.Boss.Boss.coords

Citizen.CreateThread(function()
        while true do
            local Timer = 500
            local plyPos = GetEntityCoords(PlayerPedId())
            local dist = #(plyPos-posMenu)
            if ESX.PlayerData.job and ESX.PlayerData.job.name == 'mechanic' and ESX.PlayerData.job.grade_name == 'boss' then
                if dist <= 2.0 then
                    Timer = 0
                    DrawMarker(26, posMenu, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.45, 0.45, 0.45, 0, 178, 255, 255, 0, false, true, 0, false, false, false, false)
                end
                if dist <= 1.5 then
                    Timer = 0
                    TriggerEvent("ui:showInteraction", "E", "INTERACTION") 
                    if IsControlJustPressed(1,51) then
                       TriggerEvent('Mecanojob:OpenBossMenu')
                    end
                end
            end
        Citizen.Wait(Timer)
    end
end)

local posMenu = Config.vet.vet.coords

Citizen.CreateThread(function()
        while true do
            local Timer = 500
            local plyPos = GetEntityCoords(PlayerPedId())
            local dist = #(plyPos-posMenu)
            if ESX.PlayerData.job and ESX.PlayerData.job.name == 'mechanic' then
                if dist <= 2.0 then
                    Timer = 0
                    DrawMarker(26, posMenu, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.45, 0.45, 0.45, 0, 178, 255, 255, 0, false, true, 0, false, false, false, false)
                end
                if dist <= 1.5 then
                    Timer = 0
                    TriggerEvent("ui:showInteraction", "E", "INTERACTION") 
                    if IsControlJustPressed(1,51) then
                       TriggerEvent('white:mechanic')
                    end
                end
            end
        Citizen.Wait(Timer)
    end
end)





------ Fourrierre

local options = {
    {
        name = 'Target',
        event = 'fourriere',
        icon = 'fa-solid fa-road',
        label = 'Mettre en fourrière',
		groups= {['mechanic'] = 0}
    },
}
  
  exports.ox_target:addGlobalVehicle(options)

  RegisterNetEvent("fourriere")
  AddEventHandler("fourriere", function()
	local playerPed = PlayerPedId()

	if IsPedSittingInAnyVehicle(playerPed) then
		local vehicle = GetVehiclePedIsIn(playerPed, false)

		if GetPedInVehicleSeat(vehicle, -1) == playerPed then
			lib.notify({
				title = 'Mécano Infos',
				description = 'la voiture a été mis en fourrière',
				type = 'succes'
			})
			ESX.Game.DeleteVehicle(vehicle)
		   
		else
			lib.notify({
				title = 'Mécano Infos',
				description = 'Mais toi place conducteur, ou sortez de la voiture',
				type = 'error'
			})
		end
	else
		local vehicle = ESX.Game.GetVehicleInDirection()

		if DoesEntityExist(vehicle) then
			TaskStartScenarioInPlace(PlayerPedId(), 'WORLD_HUMAN_CLIPBOARD', 0, true)
			Citizen.Wait(5000)
			ClearPedTasks(playerPed)
			lib.notify({
				title = 'Mécano Infos',
				description = 'la voiture a été mis en fourrière',
				type = 'succes'
			})
			ESX.Game.DeleteVehicle(vehicle)

		else
			lib.notify({
				title = 'Mécano Infos',
				description = 'Aucune voitures autour',
				type = 'error'
			})
		end
	end
end)