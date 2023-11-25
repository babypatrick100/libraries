return {
	run = function(numberRange: NumberRange, intermediateSerializedData)
		intermediateSerializedData.components = {
			numberRange.Min,
			numberRange.Max,
		}
	end,
}
