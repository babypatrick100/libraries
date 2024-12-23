return {
	run = function(rect: Rect, intermediateSerializedData)
		intermediateSerializedData.components = { rect.Min.X, rect.Min.Y, rect.Max.X, rect.Max.Y }
	end,
}
