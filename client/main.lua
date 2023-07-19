local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57, 
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177, 
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70, 
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

ESX                             = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(10)
	end

	ScriptLoaded()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	PlayerData = xPlayer
end)

function ScriptLoaded()
	Citizen.Wait(1000)
	LoadMarkers()
end

local AnimalPositions = {
	{ x = 228.87, y = -1743.02, z = 29.24 },
	{ x = 140.62, y = -1601.22, z = 29.32 },
	{ x = -74.61, y = -1639.28, z = 29.31 },
	{ x = -41.47, y = -1805.05, z = 26.73 },
	{ x = 334.38, y = -1935.87, z = 24.65 },
	{ x = 358.81, y = -1795.98, z = 28.95 },
	{ x = 9.17, y = -1453.74, z = 30.5 },
}

local AnimalsInSession = {}

local Positions = {
	['StartHunting'] = { ['hint'] = '[E] Start Hunting', ['x'] = 1272.63, ['y'] = -1711.94, ['z'] = 54.77 },
	['Sell'] = { ['hint'] = '[E] Sell', ['x'] = -647.15, ['y'] = -1148.77, ['z'] = 9.62 },
	['SpawnATV'] = { ['x'] = 1276.23, ['y'] = -1723.88, ['z'] = 54.65 }
}

local Hunt = { ['x'] = 1272.63, ['y'] = -1711.94, ['z'] = 54.77 }
local Sell = { ['x'] = -647.15, ['y'] = -1148.77, ['z'] = 9.62 }

local OnGoingHuntSession = false
local HuntCar = nil

function BlipsMakerH(spot)
	Citizen.CreateThread(function()
		local StartBlip = AddBlipForCoord(spot.x, spot.y, spot.z)
				
		SetBlipSprite(StartBlip, 119)
		SetBlipColour(StartBlip, 0)
		SetBlipScale(StartBlip, 1.0)
		SetBlipAsShortRange(StartBlip, true)
		
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString('Murder Spot')
		EndTextCommandSetBlipName(StartBlip)
    end)
end 

function BlipsMakerS(spot)
	Citizen.CreateThread(function()
		local StartBlip = AddBlipForCoord(spot.x, spot.y, spot.z)
				
		SetBlipSprite(StartBlip, 119)
		SetBlipColour(StartBlip, 0)
		SetBlipScale(StartBlip, 1.0)
		SetBlipAsShortRange(StartBlip, true)
		
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString('Sell Murder Spot')
		EndTextCommandSetBlipName(StartBlip)
    end)
end 

function LoadMarkers()

	BlipsMakerH(Hunt)
	BlipsMakerS(Sell)

	LoadModel('blazer')
	LoadModel('bf400')

	LoadModel('u_m_m_fibarchitect')
	LoadAnimDict('amb@medic@standing@kneel@base')
	LoadAnimDict('anim@gangops@facility@servers@bodysearch@')

	Citizen.CreateThread(function()
		while true do
			local sleep = 500
			
			local plyCoords = GetEntityCoords(PlayerPedId())

			for index, value in pairs(Positions) do
				if value.hint ~= nil then

					if OnGoingHuntSession and index == 'StartHunting' then
						value.hint = '[E] Stop Search'
					elseif not OnGoingHuntSession and index == 'StartHunting' then
						value.hint = '[E] Start Search'
					end

					local distance = GetDistanceBetweenCoords(plyCoords, value.x, value.y, value.z, true)

					if distance < 5.0 then
						sleep = 5
						DrawM(value.hint, 27, value.x, value.y, value.z - 0.945, 255, 255, 255, 1.5, 15)
						if distance < 1.0 then
							if IsControlJustReleased(0, Keys['E']) then
								if index == 'StartHunting' then
									StartHuntingSession()
								else
									SellItems()
								end
							end
						end
					end

				end
				
			end
			Citizen.Wait(sleep)
		end
	end)
end

function StartHuntingSession()

	if OnGoingHuntSession then

		OnGoingHuntSession = false

		--RemoveWeaponFromPed(PlayerPedId(), GetHashKey("WEAPON_HEAVYSNIPER"), true, true)
		--RemoveWeaponFromPed(PlayerPedId(), GetHashKey("WEAPON_KNIFE"), true, true)

		DeleteEntity(HuntCar)

		for index, value in pairs(AnimalsInSession) do
			if DoesEntityExist(value.id) then
				DeleteEntity(value.id)
			end
		end

	else
		OnGoingHuntSession = true

		--Car
		
		HuntCar = CreateVehicle(GetHashKey('bf400'), Positions['SpawnATV'].x, Positions['SpawnATV'].y, Positions['SpawnATV'].z, 169.79, true, false)
		--HuntCar = CreateVehicle(GetHashKey('blazer'), Positions['SpawnATV'].x, Positions['SpawnATV'].y, Positions['SpawnATV'].z, 169.79, true, false)

		--GiveWeaponToPed(PlayerPedId(), GetHashKey("WEAPON_HEAVYSNIPER"),45, true, false)
		--GiveWeaponToPed(PlayerPedId(), GetHashKey("WEAPON_KNIFE"),0, true, false)

		--Animals

		Citizen.CreateThread(function()

				
			for index, value in pairs(AnimalPositions) do
				local Animal = CreatePed(5, GetHashKey('u_m_m_fibarchitect'), value.x, value.y, value.z, 0.0, true, false) 
				TaskWanderStandard(Animal, true, true)
				SetEntityAsMissionEntity(Animal, true, true)
				--Blips

				local AnimalBlip = AddBlipForEntity(Animal)
				SetBlipSprite(AnimalBlip, 270)
				SetBlipColour(AnimalBlip, 1)
				SetBlipScale(AnimalBlip, 0.7)
				BeginTextCommandSetBlipName("STRING")
				AddTextComponentString('FIB - Agent')
				EndTextCommandSetBlipName(AnimalBlip)


				table.insert(AnimalsInSession, {id = Animal, x = value.x, y = value.y, z = value.z, Blipid = AnimalBlip})
			end

			while OnGoingHuntSession do
				local sleep = 500
				for index, value in ipairs(AnimalsInSession) do
					if DoesEntityExist(value.id) then
						local AnimalCoords = GetEntityCoords(value.id)
						local PlyCoords = GetEntityCoords(PlayerPedId())
						local AnimalHealth = GetEntityHealth(value.id)
						
						local PlyToAnimal = GetDistanceBetweenCoords(PlyCoords, AnimalCoords, true)

						if AnimalHealth <= 0 then
							SetBlipColour(value.Blipid, 3)
							if PlyToAnimal < 2.0 then
								sleep = 5

								ESX.Game.Utils.DrawText3D({x = AnimalCoords.x, y = AnimalCoords.y, z = AnimalCoords.z + 1}, '[E] Procure Documentos', 0.4)

								if IsControlJustReleased(0, Keys['E']) then
									--if GetSelectedPedWeapon(PlayerPedId()) == GetHashKey('WEAPON_KNIFE')  then
										if DoesEntityExist(value.id) then
											table.remove(AnimalsInSession, index)
											SlaughterAnimal(value.id)
										end
									--else
									--	ESX.ShowNotification('You need to use the knife!')
									--end
								end

							end
						end
					end
				end

				Citizen.Wait(sleep)

			end
				
		end)
	end
end

function SlaughterAnimal(AnimalId)

	TaskPlayAnim(PlayerPedId(), "amb@medic@standing@kneel@base" ,"base" ,8.0, -8.0, -1, 1, 0, false, false, false )
	TaskPlayAnim(PlayerPedId(), "anim@gangops@facility@servers@bodysearch@" ,"player_search" ,8.0, -8.0, -1, 48, 0, false, false, false )

	Citizen.Wait(5000)

	ClearPedTasksImmediately(PlayerPedId())

	local Docs = math.random(1, 10)
	print(Docs)

	ESX.ShowNotification('Mataste o Agente e encontraste '..Docs..' documentos!')

	TriggerServerEvent('esx_murder:reward', Docs)

	DeleteEntity(AnimalId)
end

function SellItems()
	TriggerServerEvent('esx_murder:sell')
end

function LoadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Citizen.Wait(10)
    end    
end

function LoadModel(model)
    while not HasModelLoaded(model) do
          RequestModel(model)
          Citizen.Wait(10)
    end
end

function DrawM(hint, type, x, y, z)
	ESX.Game.Utils.DrawText3D({x = x, y = y, z = z + 1.0}, hint, 0.4)
	DrawMarker(type, x, y, z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.5, 1.5, 1.5, 255, 255, 255, 100, false, true, 2, false, false, false, false)
end