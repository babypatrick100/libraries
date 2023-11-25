return {
	run = function(cframe: CFrame, intermediateSerializedData)
		intermediateSerializedData.components = { cframe:GetComponents() }
	end,
}
