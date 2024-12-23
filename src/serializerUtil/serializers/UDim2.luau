return {
	run = function(udim2: UDim2, intermediateSerializedData)
		intermediateSerializedData.components =
			{ udim2.X.Scale, udim2.X.Offset, udim2.Y.Scale, udim2.Y.Offset }
	end,
}
