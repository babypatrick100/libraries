return {
	run = function(region3: Region3, intermediateSerializedData)
		intermediateSerializedData.components = {
			size = { region3.Size.X, region3.Size.Y, region3.Size.Z },
			position = {
				region3.CFrame.Position.X,
				region3.CFrame.Position.Y,
				region3.CFrame.Position.Z,
			},
		}
	end,
}
