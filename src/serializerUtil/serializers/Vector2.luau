return {
	run = function(vector2: Vector2, intermediateSerializedData)
		intermediateSerializedData.components = { vector2.X, vector2.Y }
	end,
}
