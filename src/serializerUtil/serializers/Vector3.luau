return {
	run = function(vector3: Vector3, intermediateSerializedData)
		intermediateSerializedData.components = { vector3.X, vector3.Y, vector3.Z }
	end,
}
