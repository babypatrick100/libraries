local colorSequenceUtil = require(script.Parent.colorSequenceUtil)

--[=[ 
	@class colorUtil
	
	A simple utility module for working with colors.
]=]

local colorUtil = {}

--[=[
	Returns a darker version of the given color. `delta` is the amount by which the given color
	should be darkened.
]=]

function colorUtil.darkenColor(color: Color3, delta: number): Color3
	local hue, saturation, value = color:ToHSV()
	return Color3.fromHSV(hue, saturation, math.clamp(value - delta, 0, 1))
end

--[=[
	Returns a clamped version of the given `colorOrColorSequence`.
]=]

function colorUtil.clampColor(
	colorOrColorSequence: Color3 | ColorSequence,
	clampComponents: {
		minH: number,
		maxH: number,
		minS: number,
		maxS: number,
		minV: number,
		maxV: number,
	}
): Color3 | ColorSequence
	if typeof(colorOrColorSequence) == "ColorSequence" then
		return ColorSequence.new({
			ColorSequenceKeypoint.new(
				0,
				colorUtil.clampColor(
					colorSequenceUtil.colorFromKeyPointsPercentage(
						0,
						colorOrColorSequence.Keypoints
					),
					clampComponents
				) :: Color3
			),

			ColorSequenceKeypoint.new(
				1,
				colorUtil.clampColor(
					colorSequenceUtil.colorFromKeyPointsPercentage(
						1,
						colorOrColorSequence.Keypoints
					),
					clampComponents
				) :: Color3
			),
		})
	end

	local hue, saturation, value = colorOrColorSequence:ToHSV()

	return Color3.fromHSV(
		math.clamp(hue, clampComponents.minH, clampComponents.maxH),
		math.clamp(saturation, clampComponents.minS, clampComponents.maxS),
		math.clamp(value, clampComponents.minV, clampComponents.maxV)
	)
end

return table.freeze(colorUtil)
