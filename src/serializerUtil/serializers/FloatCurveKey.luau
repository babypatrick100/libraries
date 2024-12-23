return {
	run = function(floatCurveKey: FloatCurveKey, intermediateSerializedData)
		intermediateSerializedData.components = {
			floatCurveKey.Time,
			floatCurveKey.Value,
			floatCurveKey.Interpolation.Name,
		}
	end,
}
