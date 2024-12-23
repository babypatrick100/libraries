local AXES = {
	Enum.Axis.X.Name,
	Enum.Axis.Y.Name,
	Enum.Axis.Z.Name,
}

return {
	run = function(axes: Axes, intermediateSerializedData)
		intermediateSerializedData.components = {}

		for _, axesName in AXES do
			if axes[axesName] == nil then
				continue
			end

			table.insert(intermediateSerializedData.components, axesName)
		end
	end,
}
