return {
	run = function(serializedRect)
		return Rect.new(table.unpack(serializedRect.components))
	end,
}
