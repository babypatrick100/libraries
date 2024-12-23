--[=[ 
	@class colorSequenceUtil
	
	A simple utility module for working with color sequences.
]=]

local colorSequenceUtil = {}

--[=[ 
	Returns a color based on where the percentage lies in the specified color sequence key points.
	(Credits; ToldFable)
]=]

function colorSequenceUtil.colorFromKeyPointsPercentage(
	percentage: number,
	colorSequenceKeyPoints: { ColorSequenceKeypoint }
)
	local closestToLeft = colorSequenceKeyPoints[1]
	local closestToRight = colorSequenceKeyPoints[#colorSequenceKeyPoints]
	local color = closestToLeft.Value

	for index = 1, #colorSequenceKeyPoints - 1 do
		if
			(colorSequenceKeyPoints[index].Time <= percentage)
			and (colorSequenceKeyPoints[index + 1].Time >= percentage)
		then
			closestToLeft = colorSequenceKeyPoints[index]
			closestToRight = colorSequenceKeyPoints[index + 1]
			local localPercentage = (percentage - closestToLeft.Time)
				/ (closestToRight.Time - closestToLeft.Time)
			color = closestToLeft.Value:Lerp(closestToRight.Value, localPercentage)
			return color
		end
	end

	return nil
end

return table.freeze(colorSequenceUtil)
