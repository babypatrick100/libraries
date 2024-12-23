--[=[ 
	@class lightingUtil

	A simple utility for working with [Lighting](https://create.roblox.com/docs/reference/engine/classes/Lighting).
]=]

local Lighting = game:GetService("Lighting")

local lightingUtil = {}

--[=[
	Sets the sky of [Lighting](https://create.roblox.com/docs/reference/engine/classes/Lighting)
	by first destroying all [Sky](https://create.roblox.com/docs/reference/engine/classes/Sky) objects in it and then cloning `sky` into it.
]=]

function lightingUtil.setSky(sky: Sky)
	-- Destroy all skies first to ensure the new sky is applied correctly:
	for _, child in Lighting:GetChildren() do
		if child:IsA("Sky") then
			child:Destroy()
		end
	end

	sky:Clone().Parent = Lighting
end

return table.freeze(lightingUtil)
