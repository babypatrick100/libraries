return {
	run = function(vector2init16: Vector2int16, intermediateSerializedData)
		intermediateSerializedData.components = {
			vector2init16.X,
			vector2init16.Y,
		}
	end,
}
