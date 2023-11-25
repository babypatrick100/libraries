return {
	run = function(serializedColorSequenceKeypoint)
		local components = serializedColorSequenceKeypoint.components
		return ColorSequenceKeypoint.new(components[1], Color3.new(table.unpack(components[2])))
	end,
}
