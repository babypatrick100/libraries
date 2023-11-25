return {
	run = function(colorSequenceKeypoint: ColorSequenceKeypoint, intermediateSerializedData)
		intermediateSerializedData.components = {
			colorSequenceKeypoint.Time,
			{
				colorSequenceKeypoint.Value.R,
				colorSequenceKeypoint.Value.G,
				colorSequenceKeypoint.Value.B,
			},
		}
	end,
}
