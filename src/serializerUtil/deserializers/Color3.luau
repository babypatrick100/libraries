return {
	run = function(serializedColor3)
		return Color3.new(table.unpack(serializedColor3.components))
	end,
}
