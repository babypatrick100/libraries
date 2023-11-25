return {
	run = function(serializedVector2)
		return Vector2.new(table.unpack(serializedVector2.components))
	end,
}
