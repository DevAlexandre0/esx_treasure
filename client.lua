local spawnLocations = Config.location
local spawnedObjects = {}  -- Table to store spawned objects

-- Function to draw 3D text
local function DrawText3D(x, y, z, text)
    SetDrawOrigin(x, y, z, 0)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end

-- Function to spawn multiple random objects
local function spawnRandomObjects(numObjects)
    local model = Config.object  -- Object model from config

    -- Validate locations
    if not spawnLocations or #spawnLocations == 0 then
        if Config.Debug then
            print("No valid spawn locations found in Config!")
        end
        return
    end

    RequestModel(model)
    local timeout = 100 -- 5 seconds max (100 * 50ms)
    while not HasModelLoaded(model) and timeout > 0 do
        Wait(50)
        timeout = timeout - 1
    end
    if timeout == 0 then
        if Config.Debug then
            print("Model loading timed out!")
        end
        return
    end

    local usedLocations = {}
    for i = 1, numObjects do
        local location
        repeat
            location = spawnLocations[math.random(1, #spawnLocations)]
        until not usedLocations[location]
        usedLocations[location] = true

        local object = CreateObjectNoOffset(model, location.x, location.y, location.z - 1, false, true, false)
        SetEntityHeading(object, math.random(0, 360))
        PlaceObjectOnGroundProperly(object)
        FreezeEntityPosition(object, true)
        SetModelAsNoLongerNeeded(model)

        table.insert(spawnedObjects, object)  -- Store spawned object
        if Config.Debug then
            print("Object spawned at: " .. location.x .. ", " .. location.y .. ", " .. location.z)
        end
    end
end

-- Function to play an animation
local function playAnimation(dict, anim, duration)
    RequestAnimDict(dict)
    local timeout = 100 -- 5 seconds max
    while not HasAnimDictLoaded(dict) and timeout > 0 do
        Wait(50)
        timeout = timeout - 1
    end
    if timeout == 0 then
        if Config.Debug then
            print("Animation dictionary loading timed out!")
        end
        return
    end

    TaskPlayAnim(PlayerPedId(), dict, anim, 8.0, 8.0, duration, 49, 0, false, false, false)
end

-- Function to check if the player is near an object and handle interaction
local function handlePlayerInteraction()
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed)

    for _, object in ipairs(spawnedObjects) do
        local objectPos = GetEntityCoords(object)
        local distance = #(playerPos - objectPos)

        if distance < 3 then
            -- Draw 3D text prompt
            DrawText3D(objectPos.x, objectPos.y, objectPos.z + 1.0, "[E] Open Crate")

            if IsControlJustPressed(0, 38) then  -- E key pressed
                playAnimation("amb@medic@standing@kneel@base", "base", 2000)
                Wait(2000)  -- Wait for animation
                TriggerServerEvent("giveRandomItem")
                DeleteObject(object)
            end
            break
        end
    end
end

local function despawnObjects()
    for _, object in ipairs(spawnedObjects) do
        if DoesEntityExist(object) then
            DeleteObject(object)  -- Delete the object
        end
    end
    spawnedObjects = {}  -- Clear the table of spawned objects
end

-- Main thread to spawn objects and handle interactions
Citizen.CreateThread(function()
    local spawnInterval = Config.respawnTime * 60 * 1000
    local lastSpawnTime = GetGameTimer()
    spawnRandomObjects(Config.ObjectAmount)

    while true do
        local currentTime = GetGameTimer()
        
        if currentTime - lastSpawnTime >= spawnInterval then
            despawnObjects()
            spawnRandomObjects(Config.ObjectAmount)
            lastSpawnTime = currentTime
        end
        handlePlayerInteraction()
        Citizen.Wait(0)
    end
end)

-- Cleanup spawned objects on resource stop
AddEventHandler("onResourceStop", function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    despawnObjects()
end)
