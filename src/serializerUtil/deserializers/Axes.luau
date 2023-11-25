return {
	run = function(serializedFaces)
		local normalIds = {}

		for _, axesName in serializedFaces.components do
			table.insert(normalIds, Enum.Axis[axesName])
		end

		return Axes.new(table.unpack(normalIds))
	end,
}
