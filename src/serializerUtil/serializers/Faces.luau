local FACES = {
	Enum.NormalId.Back.Name,
	Enum.NormalId.Front.Name,
	Enum.NormalId.Top.Name,
	Enum.NormalId.Bottom.Name,
	Enum.NormalId.Left.Name,
	Enum.NormalId.Right.Name,
}

return {
	run = function(faces: Faces, intermediateSerializedData)
		intermediateSerializedData.components = {}

		for _, normalIdName in FACES do
			if not faces[normalIdName] then
				continue
			end

			table.insert(intermediateSerializedData.components, normalIdName)
		end
	end,
}
