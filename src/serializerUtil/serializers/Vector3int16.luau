return {
	run = function(vector3init16: Vector3int16, intermediateSerializedData)
		intermediateSerializedData.components = {
			vector3init16.X,
			vector3init16.Y,
			vector3init16.Z,
		}
	end,
}
