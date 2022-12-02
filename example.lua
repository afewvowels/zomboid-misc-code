local function checkFuel()
    local player = getPlayer()
    local cell = player:getCell()
    local x, y, z = player:getX(), player:getY(), player:getZ()
    local xx, yy, zz
    local rad = 1
    for xx = -rad, rad do
    for yy = -rad, rad do
    local square = cell:getGridSquare(x + xx, y + yy, z)
        for i=0, square:getObjects():size()-1 do
        local obj = square:getObjects():get(i)
            if obj:getProperties():Is("fuelAmount") and obj:getPipedFuelAmount() and obj:getPipedFuelAmount() > 0 then                        
            local fuelamt = obj:getPipedFuelAmount()     
            print(fuelamt)
            CheckFuelOff()

            -- Modified here to return the found value
            return fuelamt    
            end        
        end
    end
    end

    -- ...and modified here to return nil if nothing is found
    return nil
end
function CheckFuelOn()
    getPlayer():setHaloNote("CheckFuelOn") 
    Events.OnTick.Add(checkStuff);
    return true
end

function CheckFuelOff()
    getPlayer():setHaloNote("CheckFuelOff") 
    Events.OnTick.Remove(checkFuel);
end

-- Just a filler framework for the last context menu option
local function refuelPumpOption(arg1, arg2, arg3, arg4)
    print("Do stuff")
end

local function FuelContextMenu(player, context, worldObjects)
    local pump = nil

    for _, object in ipairs(worldObjects) do
        if object:getPipedFuelAmount() > 0 then
            pump = object
            local distance = pump:getSquare():DistToProper(playerObj)

            -- Here's that breaking out of a loop if the pump is too far away from the player to interact with (taken from "Pumps have Propane")
            if dist > 2 then break end

            -- Here I'm assigning the context menu to a variable since there will be a heirarchy of menus and sub menus, with just a single context menu option added I'd ignore the variable assignment and just call context:addOption()
            local parentMenu = context:addOption("Fuel Stuff Main Context Menu")

            -- Submenu also gets a variable assignment, I had to pick apart the "More Builds" mod to figure this one out, that mod has a crazy(!) number of menus and submenus for all the furniture it adds to the game
            local childMenu = ISContextMenu:getNew(context)

            -- Now we define the relationship of the parent (wrapper?) menu and the child submenu to one another (also parent/child is used in 3d animation heirarchies? not sure if its relevant in this context lol but it is used when describing animation rigs and linkages and whatnot)
            context:addSubMenu(parentMenu, childMenu)

            -- And now just adding options to the submenu. If you wanted another submenu inside the submenu you'd just repeat the above with something like:
            -- local grandchildMenu = ISContextMenu:getNew(childMenu)
            -- childMenu:addSubMenu(parentMenu, grandchildMenu)
            -- etc. etc.
            -- Uh, I guess, I haven't tried this yet but it sounds like it should work???
            childMenu:addOption("Submenu That Appears Inside the Main Context Menu")

            -- Now that those demos of how to add a context menu and make a submenu are done, here's some actual context menus that display info
            local fuelAmount = checkFuel()

            if fuelAmount == nil then fuelAmount = 0 end

            childMenu:addOption(fuelAmount)

            -- Or you could do something a little more descriptive like:
            local fuelString = "Fuel in tank: " .. fuelAmount
            childMenu:addOption(fuelString)

            -- So here is the thing for adding a context menu option that will call a function when clicked with several arguments. I've been checking over these reference mods and it looks like for sure these context menu function calls place arg1, then the function name, then all remaining arguments. No idea why it's out of order and good luck trying to find out with the current documentation O_o
            childMenu:addOption("Refill Pump Option", arg1, refuelPumpOption, arg2, arg3, arg4)
        end
    end

end

-- And then add the context menu generation here
Events.OnFillWorldObjectContextMenu.Add(FuelContextMenu)
