return {
	run = function(serializedVector3)
		return Vector3.new(table.unpack(serializedVector3.components))
	end,
}
