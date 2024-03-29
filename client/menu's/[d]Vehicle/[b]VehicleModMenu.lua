
local _ = {
    rank = nil;
    aPerms = _Admin.Permissions.Button_Vehicle.inside.ModMenu.inside,
    vehColors = {1,1,1,1},
    boost = 1,
    colorList = {},
    colorIndex = 1,
    colorIndex2 = 1,
}


for k,v in pairs(_Admin.Vehicle.PaintIndexes) do
    table.insert(_.colorList, v[1])
end


function _Admin.Vehicle:Options(type, inVehicle, args)
    local vehicle
    if inVehicle then
        if not IsPedInAnyVehicle(PlayerPedId(), false) then
            ESX.ShowNotification("~r~Vous n'êtes pas dans un véhicule")
            return
        else
            vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
        end
    end

    if type == "repair" then
        SetVehicleEngineHealth(vehicle, 1000)
        SetVehicleEngineOn( vehicle, true, true )
        SetVehicleFixed(vehicle)
    elseif type == "clean" then
		SetVehicleDirtLevel(vehicle, 0)
    elseif type == "plate" then
        SetVehicleNumberPlateText(vehicle, args.plate)
    elseif type == "open-doors" then
        for i = 0, 5 do SetVehicleDoorOpen(vehicle, i, false, true) end
    elseif type == "close-doors" then
        for i = 0, 5 do SetVehicleDoorShut(vehicle, i, false) end
    elseif type == "change-color" then
        SetVehicleColours(vehicle, args.primaryColor, args.secondaryColor)
    elseif type == "couple-boost" then
        if args.couplespeed ~= 1 then
            _Admin.addThread[9][3] = vehicle 
            _Admin.addThread[9][4] = args.couplespeed
            _Admin.addThread[9][1] = true
        else
            _Admin.addThread[9][1] = true
        end
    elseif type == "dirty" then
        SetVehicleDirtLevel(vehicle, 15.0)
    elseif type == "fullperf" then
        FullVehicleBoost(vehicle)
    end
end





function _Admin.Panel:VehicleModMenu(rank)
    _.rank = rank
    _Admin.Menu.sub_VehicleModMenu.EnableMouse = false

    RageUI.Button('Réparer', nil, {RightLabel = "~c~→→→"}, _Admin:HaveAccess(_.rank, _.aPerms.Repair), {
        onSelected = function()
            _Admin.Print("[^1".._.rank.name.." ^7- ^2"..GetPlayerName(PlayerId()).."^7] Véhicule Options → [^6Réparer^7]")
            _Admin.SendServerLogs("[".._.rank.name.." - "..GetPlayerName(PlayerId()).."] Véhicule Options → [Réparer]")
            _Admin.Vehicle:Options("repair", true)
        end
    });

    RageUI.Button('Salir au maximum', nil, {RightLabel = "~c~→→→"}, _Admin:HaveAccess(_.rank, _.aPerms.Dirty), {
        onSelected = function()
            _Admin.Vehicle:Options("dirty")
        end
    });

    RageUI.Button('Néttoyer', nil, {RightLabel = "~c~→→→"}, _Admin:HaveAccess(_.rank, _.aPerms.Clean), {
        onSelected = function()
            _Admin.Print("[^1".._.rank.name.." ^7- ^2"..GetPlayerName(PlayerId()).."^7] Véhicule Options → [^6Néttoyer^7]")
            _Admin.SendServerLogs("[".._.rank.name.." - "..GetPlayerName(PlayerId()).."] Véhicule Options → [Néttoyer]")
            _Admin.Vehicle:Options("clean", true)
        end
    });

    RageUI.Button('Modifier la plaque d\'immatriculation', nil, {RightLabel = "~c~→→→"}, _Admin:HaveAccess(_.rank, _.aPerms.Plate), {
        onSelected = function()
            local plate = KI("Plaque du véhicule", "", 7)
            _Admin.Vehicle:Options("plate", true, {plate = plate})
            _Admin.Print("[^1".._.rank.name.." ^7- ^2"..GetPlayerName(PlayerId()).."^7] Véhicule Options → [^6Modification plaque : "..plate.."^7]")
            _Admin.SendServerLogs("[".._.rank.name.." - "..GetPlayerName(PlayerId()).."] Véhicule Options → [Modification plaque : "..plate.."]")
        end
    });

    RageUI.Button('Ouvrir toutes les portes', nil, {RightLabel = "~c~→→→"}, _Admin:HaveAccess(_.rank, _.aPerms.OpenDoords), {
        onSelected = function()
            Citizen.CreateThread(function()
                _Admin.Vehicle:Options("open-doors", true)
                Wait(5)
                _Admin.Vehicle:Options("open-doors", true)
            end)
        end
    });

    RageUI.Button('Fermer toutes les portes', nil, {RightLabel = "~c~→→→"}, _Admin:HaveAccess(_.rank, _.aPerms.CloseDoords), {
        onSelected = function()
            _Admin.Vehicle:Options("close-doors", true)
        end
    });
    

    RageUI.Line()    

    RageUI.List("Couleur principale", _.colorList, _.colorIndex, nil, {}, _Admin:HaveAccess(_.rank, _.aPerms.ChangeColor), {
        onListChange = function(Index, Item)
            _.colorIndex = Index;
            _Admin.Print("[^1".._.rank.name.." ^7- ^2"..GetPlayerName(PlayerId()).."^7] Véhicule Options → [^6Couleur principale : ^5"..Item.." ^7]")
            _Admin.Vehicle:Options("change-color", true, {primaryColor = _Admin.Vehicle.PaintIndexes[_.colorIndex][2], secondaryColor = _Admin.Vehicle.PaintIndexes[_.colorIndex2][2]})
        end,
    })


    RageUI.List("Couleur secondaire", _.colorList, _.colorIndex2, nil, {}, _Admin:HaveAccess(_.rank, _.aPerms.ChangeColor), {
        onListChange = function(Index, Item)
            _.colorIndex2 = Index;
            _Admin.Print("[^1".._.rank.name.." ^7- ^2"..GetPlayerName(PlayerId()).."^7] Véhicule Options → [^6Couleur secondaire : ^5"..Item.." ^7]")
            _Admin.Vehicle:Options("change-color", true, {primaryColor = _Admin.Vehicle.PaintIndexes[_.colorIndex][2], secondaryColor = _Admin.Vehicle.PaintIndexes[_.colorIndex2][2]})
        end,
    })


    RageUI.List("Améliorer le couple moteur", {0, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024}, _.boost, nil, {}, _Admin:HaveAccess(_.rank, _.aPerms.BoostVehicle), { 
        onListChange = function(Index, Item)
            _.boost = Index;
           -- _Admin.Print("[^1".._.rank.name.." ^7- ^2"..GetPlayerName(PlayerId()).."^7] Véhicule Options → [^6Améliore le couple moteur^7]")
            _Admin.Vehicle:Options("couple-boost", true, {couplespeed = Index})
        end,
    })

    RageUI.Button("~r~Full Performance", nil, {RightLabel = "~c~→→→"}, _Admin:HaveAccess(_.rank, _.aPerms.FullPerf), {
        onSelected = function()
            _Admin.Vehicle:Options("fullperf", true)
        end
    });

end

function FullVehicleBoost(vehicle)
	if IsPedInAnyVehicle(PlayerPedId(), false) then
        SetVehicleModKit(veh, 0)
		SetVehicleModKit(vehicle, 0)
		SetVehicleMod(vehicle, 14, 0, true)
		ToggleVehicleMod(vehicle, 18, true)
		SetVehicleColours(vehicle, 62, 38)
		SetVehicleCustomPrimaryColour(vehicle, 0, 0, 0)
		SetVehicleModColor_2(vehicle, 5, 0)
		SetVehicleExtraColours(vehicle, 111, 111)
		SetVehicleWindowTint(vehicle, 2)
		SetVehicleWheelType(vehicle, 12) 
		SetVehicleWindowTint(vehicle, 3)
		ToggleVehicleMod(vehicle, 20, true)
		SetVehicleHasBeenOwnedByPlayer(vehicle, true)
		SetVehicleFixed(vehicle)
		SetVehicleNeonLightEnabled(vehicle, 0, true)
		SetVehicleNeonLightEnabled(vehicle, 1, true)
		SetVehicleNeonLightEnabled(vehicle, 2, true)
		SetVehicleNeonLightEnabled(vehicle, 3, true)
		SetVehicleNeonLightsColour(vehicle, 0, 0, 255)
		
		for i = 0, 49 do
			local custom = GetNumVehicleMods(veh, i)
			for j = 1,custom do
				SetVehicleMod(veh, i, math.random(1,j), 1)
			end
		end
	end
end