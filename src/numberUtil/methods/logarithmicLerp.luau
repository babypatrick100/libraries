--[=[
    @within numberUtil
    
    Logarithmicly lerps `number` to `goal`, with `alpha` being the multiplier.

    ```lua
    print(numberUtil.logarithmicLerp(1, 2, 3)) --> 0.125
    ```
]=]

local function logarithmicLerp(number: number, goal: number, alpha: number): number
	return number * math.pow(number / goal, alpha)
end

return logarithmicLerp
