return {
	run = function(udim: UDim, intermediateSerializedData)
		intermediateSerializedData.components = { udim.Scale, udim.Offset }
	end,
}
