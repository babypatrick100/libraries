local AXES = {
	Enum.Axis.Back.Name,
	Enum.Axis.Front.Name,
	Enum.Axis.Top.Name,
	Enum.Axis.Bottom.Name,
	Enum.Axis.Left.Name,
	Enum.Axis.Right.Name,
}

return {
	run = function(axes: Axes, intermediateSerializedData)
		intermediateSerializedData.components = {}

		for _, axesName in AXES do
			if not axes[axesName] then
				continue
			end

			table.insert(intermediateSerializedData.components, axesName)
		end
	end,
}
