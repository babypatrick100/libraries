return {
	run = function(serializedVector3int16)
		return Vector3int16.new(table.unpack(serializedVector3int16.components))
	end,
}
