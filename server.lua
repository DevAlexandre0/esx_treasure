-- Function to give a random item to the player based on chances
RegisterServerEvent("giveRandomItem")
AddEventHandler("giveRandomItem", function()    
    -- Define the items and their chances
    local items = Config.item

    local random = math.random(1, 100)
    local totalChance = 0

    -- Determine which item the player gets based on the chance
    for _, item in ipairs(items) do
        totalChance = totalChance + item.chance
        if random <= totalChance then
            exports.ox_inventory:AddItem(source, item.name, item.amount)
            break
        end
    end
end)
