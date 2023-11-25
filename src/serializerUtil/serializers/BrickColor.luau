return {
	run = function(brickcolor: BrickColor, intermediateSerializedData)
		intermediateSerializedData.components = { brickcolor.r, brickcolor.g, brickcolor.b }
	end,
}
