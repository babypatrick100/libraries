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

return table.freeze(colorUtil)
