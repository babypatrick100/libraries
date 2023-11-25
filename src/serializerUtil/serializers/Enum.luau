return {
	run = function(enum: Enum, intermediateSerializedData)
		intermediateSerializedData.name = tostring(enum)
	end,
}
