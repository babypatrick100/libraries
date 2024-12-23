--[=[ 
	@class instanceTroveUtil

	An utility module for working with instance troves.
]=]

local Trove = require(script.Parent.Trove)

local instanceTroves = {}

local instanceTroveUtil = {}

--[=[
	@return Trove

	Returns the given `instance`'s trove. If one does not exist, it'll be created for the given `instance`. 
	This trove will be automatically cleaned up once `instance` is destroyed.

	:::warning 
	This method will throw an error if `instance` is not present in game.
	:::
]=]

function instanceTroveUtil.instanceTrove(instance: Instance): Trove.Trove
	assert(
		instance:IsDescendantOf(game),
		string.format("Given instance [%s] must be in game!", instance.Name)
	)

	if instanceTroves[instance] ~= nil then
		return instanceTroves[instance]
	end

	local instanceTrove = Trove.new()
	instanceTrove:AttachToInstance(instance)
	instanceTroves[instance] = instanceTrove

	instanceTrove:Add(function()
		instanceTroves[instance] = nil
	end)

	return instanceTrove
end

return table.freeze(instanceTroveUtil)
