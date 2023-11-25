return {
	run = function(serializedUDim2)
		return UDim2.new(table.unpack(serializedUDim2.components))
	end,
}
