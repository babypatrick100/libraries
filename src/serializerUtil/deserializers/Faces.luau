return {
	run = function(serializedFaces)
		local normalIds = {}

		for _, normalIdName in serializedFaces.components do
			table.insert(normalIds, Enum.NormalId[normalIdName])
		end

		return Faces.new(table.unpack(normalIds))
	end,
}
