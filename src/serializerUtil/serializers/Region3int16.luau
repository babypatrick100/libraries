return {
	run = function(region3init16: Region3int16, intermediateSerializedData)
		intermediateSerializedData.components = {
			min = { region3init16.Min.X, region3init16.Min.Y, region3init16.Min.Z },
			max = {
				region3init16.Max.X,
				region3init16.Max.Y,
				region3init16.Max.Z,
			},
		}
	end,
}
