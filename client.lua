local AllVehiclesCreated = {}
local ramdomVehiclesValue = {}
local ActiveRandomVehicles = true;
local VehicleList = {"adder", "zentorno", "primo", "burrito"}
for i = 1, #VehicleList do
    table.insert(ramdomVehiclesValue, VehicleList[math.random(1, #VehicleList)])
end

local ConfigVehicleZones = {
    {
        position = vector3(65.1357, -1906.971, 21.67981), 
        distance = 100.0, 
        SpawnVehicle = {
            {
                model = "adder", 
                position = vector3(72.26274, -1898.255, 21.47905), 
                rotation = 34.923305511475,
                PrimaryColor = {98, 13, 255},
                SecondaryColor = {98, 13, 255}
            },
            {
                model = "zentorno", 
                position = vector3(63.02643, -1891.023, 21.54359), 
                rotation = 243.44830322266,
                PrimaryColor = {98, 13, 255},
                SecondaryColor = {98, 13, 255}
            },
            {
                model = "primo", 
                position = vector3(47.84706, -1901.047, 21.63253), 
                rotation = 354.68304443359,
                PrimaryColor = {98, 13, 255},
                SecondaryColor = {98, 13, 255}
            },
            {
                model = "primo", 
                position = vector3(56.79747, -1891.048, 21.56366), 
                rotation = 110.5731048584,
                PrimaryColor = {98, 13, 255},
                SecondaryColor = {98, 13, 255}
            },
        }
    },
    {
        position = vector3(321.3546, -2028.471, 20.76191), 
        distance = 100.0, 
        SpawnVehicle = {
            {
                model = "adder", 
                position = vector3(302.9121, -2007.439, 20.18778), 
                rotation = 194.98107910156,
                PrimaryColor = {227, 171, 16},
                SecondaryColor = {227, 171, 16}
            },
            {
                model = "zentorno", 
                position = vector3(297.1667, -2013.462, 19.88036), 
                rotation = 254.48986816406,
                PrimaryColor = {227, 171, 16},
                SecondaryColor = {227, 171, 16}
            },
        }
    }
}


local function spawnVehicleWithDoorClose(modelName, coords, heading, callback)
	local model = (type(modelName) == 'number' and modelName or GetHashKey(modelName))
	CreateThread(function()
		RequestModel(model)
		while not HasModelLoaded(model) do Wait(0) end
		local vehicle = CreateVehicle(model, coords, coords, coords, heading, true, false)
		local id = NetworkGetNetworkIdFromEntity(vehicle)
		SetNetworkIdCanMigrate(id, true)
		SetEntityAsMissionEntity(vehicle, true, false)
		SetVehicleHasBeenOwnedByPlayer(vehicle, true)
		SetVehicleNeedsToBeHotwired(vehicle, false)
        SetVehicleDoorsLocked(vehicle, 2)
		SetModelAsNoLongerNeeded(model)
		RequestCollisionAtCoord(coords, coords, coords)
		while not HasCollisionLoadedAroundEntity(vehicle) do
			RequestCollisionAtCoord(coords, coords, coords)
			Wait(0)
		end

		if (callback) then
			callback(vehicle)
		end
	end)
end

local EnteredGangZone = false
CreateThread(function()
    while true do
        local InGaaangZone = false
        local playerCoord = GetEntityCoords(PlayerPedId())
        for k, config in pairs(ConfigVehicleZones) do
            if #(playerCoord - config.position) <= config.distance then
                InGaaangZone = true;
                if not EnteredGangZone then
                    EnteredGangZone = true;
                    for index, vehicle in pairs (config.SpawnVehicle) do
                        if ActiveRandomVehicles then
                            spawnVehicleWithDoorClose(ramdomVehiclesValue[index], vehicle.position, vehicle.rotation, function(vehicleCreated) 
                                table.insert(AllVehiclesCreated, vehicleCreated)
                                SetVehicleCustomPrimaryColour(vehicleCreated, vehicle.PrimaryColor[1], vehicle.PrimaryColor[2], vehicle.PrimaryColor[3])
                                SetVehicleCustomSecondaryColour(vehicleCreated, vehicle.SecondaryColor[1], vehicle.SecondaryColor[2], vehicle.SecondaryColor[3])
                                SetEntityHeading(vehicleCreated, vehicle.rotation)
                                Wait(300)
                                FreezeEntityPosition(vehicleCreated, true)
                            end)
                        else
                            spawnVehicleWithDoorClose(GetHashKey(vehicle.model), vehicle.position, vehicle.rotation, function(vehicleCreated) 
                                table.insert(AllVehiclesCreated, vehicleCreated)
                                SetVehicleCustomPrimaryColour(vehicleCreated, vehicle.PrimaryColor[1], vehicle.PrimaryColor[2], vehicle.PrimaryColor[3])
                                SetVehicleCustomSecondaryColour(vehicleCreated, vehicle.SecondaryColor[1], vehicle.SecondaryColor[2], vehicle.SecondaryColor[3])
                                SetEntityHeading(vehicleCreated, vehicle.rotation)
                                Wait(300)
                                FreezeEntityPosition(vehicleCreated, true)
                            end)
                        end
                    end
                end
                break
            end
        end
        if InGaaangZone then
            Wait(100)
        else
            if EnteredGangZone then
                EnteredGangZone = false
                if #AllVehiclesCreated > 0 then
                    for index, vehicle in pairs (AllVehiclesCreated) do
                        DeleteEntity(vehicle)
                    end
                end
            end
            Wait(200)
        end
    end
end)

AddEventHandler("onResourceStart", function(resourceName)
    if resourceName == GetCurrentResourceName() then
        if #AllVehiclesCreated > 0 then
            for index, vehicle in pairs (AllVehiclesCreated) do
                DeleteEntity(vehicle)
            end
        end
    end
end)