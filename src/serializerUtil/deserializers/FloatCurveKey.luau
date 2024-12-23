return {
	run = function(serializedFloatCurveKey)
		local components = serializedFloatCurveKey.components

		return FloatCurveKey.new(
			components[1],
			components[2],
			Enum.KeyInterpolationMode[components[3]]
		)
	end,
}
