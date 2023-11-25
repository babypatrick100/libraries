return {
	run = function(intermediateSerializedData)
		return CFrame.new(table.unpack(intermediateSerializedData.components))
	end,
}
