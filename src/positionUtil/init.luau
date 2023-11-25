--[=[
	@class positionUtil

	An utility module for working with positions.
]=]

local random = Random.new(os.clock() + os.time())

local positionUtil = {}

--[=[
	Returns a random position from the given position and the size. A third argument (`specifiedRandom`)
	can be passed which will be used in calculating the random position.
]=]

function positionUtil.randomPosition(position: Vector3, size: Vector3, specifiedRandom: Random?)
	specifiedRandom = specifiedRandom or random
	size = size / 2

	return position
		+ Vector3.new(
			specifiedRandom:NextNumber(-size.X, size.X),
			specifiedRandom:NextNumber(-size.Y, size.Y),
			specifiedRandom:NextNumber(-size.Z, size.Z)
		)
end

return table.freeze(positionUtil)
