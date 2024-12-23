return {
	run = function(serializedVector2int16)
		return Vector2int16.new(table.unpack(serializedVector2int16.components))
	end,
}
