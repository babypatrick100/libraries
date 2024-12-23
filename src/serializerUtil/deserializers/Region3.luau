return {
	run = function(serializedRegion3)
		local components = serializedRegion3.components
		local size = Vector3.new(table.unpack(components.size))
		local position = Vector3.new(table.unpack(components.position))

		return Region3.new(position - (size / 2), position + (size / 2))
	end,
}
