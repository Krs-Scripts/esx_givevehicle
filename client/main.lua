
TriggerEvent('chat:addSuggestion', '/givecar', 'Dai un\'auto al giocatore', {
	{ name="id", help="L'ID del giocatore" },
    { name="vehicle", help="Modello Veicolo" },
    { name="<plate>", help="Targa del veicolo, salta se vuoi generare un numero di targa casuale" }
})

TriggerEvent('chat:addSuggestion', '/giveplane', 'Dai un aereo al giocatore', {
	{ name="id", help="L'ID del giocatore" },
    { name="vehicle", help="Modello Veicolo" },
    { name="<plate>", help="Targa del veicolo, salta se vuoi generare un numero di targa casuale" }
})

TriggerEvent('chat:addSuggestion', '/giveboat', 'Dai una barca al giocatore', {
	{ name="id", help="L'ID del giocatore" },
    { name="vehicle", help="Modello Veicolo" },
    { name="<plate>", help="Targa del veicolo, salta se vuoi generare un numero di targa casuale" }
})

TriggerEvent('chat:addSuggestion', '/giveheli', 'Dai un elicottero al giocatore', {
	{ name="id", help="L'ID del giocatore" },
    { name="vehicle", help="Modello Veicolo" },
    { name="<plate>", help="Targa del veicolo, salta se vuoi generare un numero di targa casuale" }
})

TriggerEvent('chat:addSuggestion', '/delcarplate', 'Elimina un veicolo di proprietà per numero di targa', {
	{ name="plate", help="Vehicle's plate number" }
})

RegisterNetEvent('esx_giveownedcar:spawnVehicle', function(playerID, model, playerName, type, vehicleType)
    local playerPed = cache.ped or PlayerPedId()
    local coords = cache.coords or GetEntityCoords(playerPed)
    local carExist = false
    local model = lib.requestModel(model) 
    if not model then return end
    -- Crea il veicolo
    local vehicle = CreateVehicle(model, coords, 0.0, true, false)      
    SetVehicleFuelLevel(vehicle, 100.0)
    SetModelAsNoLongerNeeded(model)
    -- ESX.Game.SpawnVehicle(model, coords, 0.0, function(vehicle) 
    if DoesEntityExist(vehicle) then
        carExist = true
        SetEntityVisible(vehicle, false, false)
        SetEntityCollision(vehicle, false)        
        local newPlate = exports.esx_vehicleshop:GeneratePlate()
        local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
        vehicleProps.plate = newPlate  
        TriggerServerEvent('esx_giveownedcar:setVehicle', vehicleProps, playerID, vehicleType)
        TriggerServerEvent('krs:discordLog', vehicleProps, playerID, true) 
        DeleteEntity(vehicle)
        -- ESX.Game.DeleteVehicle(vehicle)   
        if type ~= 'console' then
            ESX.ShowNotification('Veicolo ~y~%s ~s~con targa ~y~ %s ~s~è stato parcheggiato nel garage di ~g~%s~s~', model, newPlate, playerName)
        else
            local msg = ('addCar: ' ..model.. ', targa: ' ..newPlate.. ', aGiocatore: ' ..playerName)
            TriggerServerEvent('esx_giveownedcar:printToConsole', msg)
        end             
    end     
    Wait(2000)
    if not carExist then
        if type ~= 'console' then
            ESX.ShowNotification('~r~Modello veicolo sconosciuto ~y~%s', model)
        else
            TriggerServerEvent('esx_giveownedcar:printToConsole', "ERRORE: "..model.." è un modello veicolo sconosciuto")
        end        
    end
end)

RegisterNetEvent('esx_giveownedcar:spawnVehiclePlate', function(playerID, model, plate, playerName, type, vehicleType)
    local playerPed = cache.ped or PlayerPedId()
    local coords = cache.coords or GetEntityCoords(playerPed)
    local generatedPlate = string.upper(plate)
    local carExist = false
    ESX.TriggerServerCallback('esx_vehicleshop:isPlateTaken', function (isPlateTaken)
        if not isPlateTaken then
            local model = lib.requestModel(model) 
			if not model then return end
            -- Crea il veicolo
            local vehicle = CreateVehicle(model, coords, 0.0, true, false)      
            SetVehicleFuelLevel(vehicle, 100.0)
            SetModelAsNoLongerNeeded(model)
			print('veicolo spawnato', model)
			-- ESX.Game.SpawnVehicle(model, coords, 0.0, function(vehicle) 
            if DoesEntityExist(vehicle) then
                carExist = true
                SetEntityVisible(vehicle, false, false)
                SetEntityCollision(vehicle, false)    
                local newPlate = string.upper(plate)
                local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
                vehicleProps.plate = newPlate
                TriggerServerEvent('esx_giveownedcar:setVehicle', vehicleProps, playerID, vehicleType)
                TriggerServerEvent('krs:discordLog', vehicleProps, playerID, true) 
				DeleteEntity(vehicle)
                -- ESX.Game.DeleteVehicle(vehicle)
                if type ~= 'console' then                 
					ESX.ShowNotification('Veicolo ~y~%s ~s~con targa ~y~%s ~s~è stato parcheggiato nell\'impound ~g~%s~s~', model, newPlate, playerName)
                else
                    local msg = ('addCar: ' ..model.. ', targa: ' ..newPlate.. ', aGiocatore: ' ..playerName)
                    TriggerServerEvent('esx_giveownedcar:printToConsole', msg)
                end                
            end
        else
            carExist = true
            if type ~= 'console' then
                ESX.ShowNotification('~r~Questa targa è già in uso su un altro veicolo')
            else
                local msg = ('ERROR: Questa targa è già in uso su un altro veicolo')
                TriggerServerEvent('esx_giveownedcar:printToConsole', msg)
            end                    
        end
    end, generatedPlate)
    Wait(2000)
    if not carExist then
        if type ~= 'console' then
            ESX.ShowNotification('~r~Modello veicolo sconosciuto ~y~%s', model)
        else
            TriggerServerEvent('esx_giveownedcar:printToConsole', "ERROR: "..model.." è un modello veicolo sconosciuto")
        end        
    end    
end)