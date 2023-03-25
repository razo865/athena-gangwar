local PlayerKilledByPlayer = function(killerServerId, killerClientId, deathCause)
	local victimCoords = GetEntityCoords(PlayerPedId())
	local killerCoords = GetEntityCoords(GetPlayerPed(killerClientId))
	local distance = #(victimCoords - killerCoords)

	local data = {
		victimCoords = {x = math.round(victimCoords.x, 1), y = math.round(victimCoords.y, 1), z = math.round(victimCoords.z, 1)},
		killerCoords = {x = math.round(killerCoords.x, 1), y = math.round(killerCoords.y, 1), z = math.round(killerCoords.z, 1)},

		killedByPlayer = true,
		deathCause = deathCause,
		distance = math.round(distance, 1),

		killerServerId = killerServerId,
		killerClientId = killerClientId
	}

	TriggerEvent('ath:OnPlayerDeath', data)
	TriggerServerEvent('ath:OnPlayerDeath', data)
end

local PlayerKilled = function(deathCause)
	local playerPed = PlayerPedId()
	local victimCoords = GetEntityCoords(playerPed)
	local data = {
		victimCoords = {x = math.round(victimCoords.x, 1), y = math.round(victimCoords.y, 1), z = math.round(victimCoords.z, 1)},

		killedByPlayer = false,
		deathCause = deathCause
	}

	TriggerEvent('ath:OnPlayerDeath', data)
	TriggerServerEvent('ath:OnPlayerDeath', data)
end

CreateThread(function()
	while true do
		local sleep = 100
		local player = PlayerId()

		if NetworkIsPlayerActive(player) then
			local playerPed = ATH.PlayerData.ped

			if IsPedFatallyInjured(playerPed) and not ATH.PlayerData.isDead then
				sleep = 0
				ATH.PlayerData.isDead = true

				local killerEntity, deathCause = GetPedSourceOfDeath(playerPed), GetPedCauseOfDeath(playerPed)
				local killerClientId = NetworkGetPlayerIndexFromPed(killerEntity)

				if killerEntity ~= playerPed and killerClientId and NetworkIsPlayerActive(killerClientId) then
					PlayerKilledByPlayer(GetPlayerServerId(killerClientId), killerClientId, deathCause)
				else
					PlayerKilled(deathCause)
				end

				ATH.LoadAnim('missarmenian2')

				while IsPedRagdoll(playerPed) do Wait() end

				if ATH.PlayerData.isDead then
					Wait(10000)
					if ATH.PlayerData.isDead then
						ATH.RevivePed()
					end	
				end
			end

			if ATH.PlayerData.isDead then
				DisableControlAction(0, 37, true)
				DisableControlAction(0, 140, true)
				if not IsEntityPlayingAnim(playerPed, 'missarmenian2', 'corpse_search_exit_ped', 3) then
					TaskPlayAnim(playerPed, 'missarmenian2', 'corpse_search_exit_ped', 8.0, -8.0, -1, 0, 0, false, false, false)
				end
			end
		end
	    Wait(sleep)
	end
end)