return {
	run = function(color3: Color3, intermediateSerializedData)
		intermediateSerializedData.components = { color3.R, color3.G, color3.B }
	end,
}
