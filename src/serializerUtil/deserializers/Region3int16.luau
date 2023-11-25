return {
	run = function(serializedRegion3)
		local components = serializedRegion3.components
		local min = Vector3int16.new(table.unpack(components.min))
		local max = Vector3int16.new(table.unpack(components.max))

		return Region3int16.new(min, max)
	end,
}
