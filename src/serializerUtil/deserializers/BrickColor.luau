return {
	run = function(serializedBrickColor)
		return BrickColor.new(table.unpack(serializedBrickColor.components))
	end,
}
