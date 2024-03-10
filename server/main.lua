
--give car with a random plate- 1: playerID 2: carModel (3: plate)
RegisterCommand('givecar', function(source, args)
	givevehicle(source, args, 'car')
end)

--give car with a random plate- 1: playerID 2: carModel (3: plate)
RegisterCommand('giveplane', function(source, args)
	givevehicle(source, args, 'airplane')
end)

--give car with a random plate- 1: playerID 2: carModel (3: plate)
RegisterCommand('giveboat', function(source, args)
	givevehicle(source, args, 'boat')
end)

--give car with a random plate- 1: playerID 2: carModel (3: plate)
RegisterCommand('giveheli', function(source, args)
	givevehicle(source, args, 'helicopter')
end)

function givevehicle(_source, _args, vehicleType)
	if havePermission(_source) then
		if _args[1] == nil or _args[2] == nil then
			TriggerClientEvent('esx:showNotification', _source, '~r~/givevehicle playerID modello di auto [targa]')
		elseif _args[3] ~= nil then
			local playerName = GetPlayerName(_args[1])
			local plate = _args[3]
			if #_args > 3 then
				for i=4, #_args do
					plate = plate.." ".._args[i]
				end
			end	
			plate = string.upper(plate)
			TriggerClientEvent('esx_giveownedcar:spawnVehiclePlate', _source, _args[1], _args[2], plate, playerName, 'player', vehicleType)
		else
			local playerName = GetPlayerName(_args[1])
			TriggerClientEvent('esx_giveownedcar:spawnVehicle', _source, _args[1], _args[2], playerName, 'player', vehicleType)
		end
	else
		TriggerClientEvent('esx:showNotification', _source, '~r~Non hai il permesso per eseguire questo comando!')
	end
end

RegisterCommand('_givecar', function(source, args)
	_givevehicle(source, args, 'car')
end)

RegisterCommand('_giveplane', function(source, args)
	_givevehicle(source, args, 'airplane')
end)

RegisterCommand('_giveboat', function(source, args)
	_givevehicle(source, args, 'boat')
end)

RegisterCommand('_giveheli', function(source, args)
	_givevehicle(source, args, 'helicopter')
end)

function _givevehicle(_source, _args, vehicleType)
	if _source == 0 then
		local sourceID = _args[1]
		if _args[1] == nil or _args[2] == nil then
			print("SYNTAX ERROR: _givevehicle <playerID> <carModel> [plate]")
		elseif _args[3] ~= nil then
			local playerName = GetPlayerName(sourceID)
			local plate = _args[3]
			if #_args > 3 then
				for i=4, #_args do
					plate = plate.." ".._args[i]
				end
			end
			plate = string.upper(plate)
			TriggerClientEvent('esx_giveownedcar:spawnVehiclePlate', sourceID, _args[1], _args[2], plate, playerName, 'console', vehicleType)
		else
			local playerName = GetPlayerName(_args[1])
			TriggerClientEvent('esx_giveownedcar:spawnVehicle', sourceID, _args[1], _args[2], playerName, 'console', vehicleType)
		end
	end
end

RegisterCommand('delcarplate', function(source, args)
    if havePermission(source) then
        if args[1] == nil then
            TriggerClientEvent('esx:showNotification', source, '~r~/delcarplate <plate>')
        else
            local plate = args[1]
            if #args > 1 then
                for i=2, #args do
                    plate = plate.." "..args[i]
                end
            end
            plate = string.upper(plate)
            
            local result = MySQL.Sync.execute('DELETE FROM owned_vehicles WHERE plate = @plate', {
                ['@plate'] = plate
            })
            if result == 1 then
                TriggerClientEvent('esx:showNotification', source, 'Hai cancellato un veicolo con targa ~y~%s', plate)

                local bool = false 
                TriggerEvent('krs:discordLog', {plate = plate}, source, bool)
            elseif result == 0 then
                TriggerClientEvent('esx:showNotification', source, 'Impossibile trovare il veicolo con targa ~y~%s', plate)
            end
        end
    else
        TriggerClientEvent('esx:showNotification', source, '~r~Non hai il permesso per eseguire questo comando!')
    end
end)

RegisterCommand('_delcarplate', function(source, args)
    if source == 0 then
        if args[1] == nil then
            print("SYNTAX ERROR: _delcarplate <plate>")
        else
            local plate = args[1]
            if #args > 1 then
                for i=2, #args do
                    plate = plate.." "..args[i]
                end
            end
            plate = string.upper(plate)
            
            local result = MySQL.Sync.execute('DELETE FROM owned_vehicles WHERE plate = @plate', {
                ['@plate'] = plate
            })
            if result == 1 then
                print('Deleted car plate: ' ..plate)

                local bool = false 
                TriggerEvent('krs:discordLog', {plate = plate}, 0, bool)
            elseif result == 0 then
                print('Can\'t find car with plate is ' ..plate)
            end
        end
    end
end)

RegisterServerEvent('krs:discordLog', function(vehicleProps, playerID, bool)
    local xPlayer = ESX.GetPlayerFromId(playerID)
    local nome = xPlayer.getName()
    local webhook
    local message

    if bool then
        webhook = Config.webhookSpawnVehicle
        message = 'L\'admin **' .. nome .. '** ha spawnato un veicolo nell\'impound con targa **' .. vehicleProps.plate .. '**'
    else
        webhook = Config.webhookDeleteVehicle
        message = 'L\'admin **' .. nome .. '** ha cancellato un veicolo nell\'impound con targa **' .. vehicleProps.plate .. '**'
    end

    local embedData = {
        {
            ['title'] = 'Krs Give Vehicle Log',
            ['color'] = 1867478, -- Decimal value -- https://www.spycolor.com/339af0
            ['footer'] = {
                ['text'] = 'Data: ' .. os.date("%d/%m/%Y") .. ' | Ora: ' .. os.date("%H:%M"),  -- Data e ora
            },
            ['description'] = message,
            ['author'] = {
                ['name'] = 'Nome Server',
                ['icon_url'] = 'https://cdn.discordapp.com/attachments/1165234834227085372/1167866540796940308/Krs-logo.png', -- Logo --
            },
        }
    }

    local jsonData = json.encode({embeds = embedData})

    PerformHttpRequest(webhook, function(statusCode, text, headers)
        
    end, 'POST', jsonData, { ['Content-Type'] = 'application/json' })
end)

RegisterNetEvent('esx_giveownedcar:setVehicle', function (vehicleProps, playerID, vehicleType)
	local _source = playerID
	local xPlayer = ESX.GetPlayerFromId(_source)

	MySQL.Async.execute('INSERT INTO owned_vehicles (owner, plate, vehicle, type) VALUES (@owner, @plate, @vehicle, @type)',
	{
		['@owner']   = xPlayer.identifier,
		['@plate']   = vehicleProps.plate,
		['@vehicle'] = json.encode(vehicleProps),
		['type'] = vehicleType
	}, function ()
		TriggerClientEvent('esx:showNotification', _source, "Hai ricevuto un veicolo con targa ".. string.upper(vehicleProps.plate))
	end)
end)


RegisterNetEvent('esx_giveownedcar:printToConsole', function(msg)
	print(msg)
end)

function havePermission(_source)
	local xPlayer = ESX.GetPlayerFromId(_source)
	local playerGroup = xPlayer.getGroup()
	local isAdmin = false
	for k,v in pairs(Config.AuthorizedRanks) do
		if v == playerGroup then
			isAdmin = true
			break
		end
	end
	
	if IsPlayerAceAllowed(_source, "giveownedcar.command") then isAdmin = true end
	
	return isAdmin
end
