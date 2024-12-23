return {
	run = function(numberSequenceKeypoint: NumberSequenceKeypoint, intermediateSerializedData)
		intermediateSerializedData.components = {
			numberSequenceKeypoint.Time,
			numberSequenceKeypoint.Value,
			numberSequenceKeypoint.Envelope,
		}
	end,
}
