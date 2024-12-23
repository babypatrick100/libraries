return {
	run = function(serializedPhysicalProperties)
		return PhysicalProperties.new(table.unpack(serializedPhysicalProperties.components))
	end,
}
