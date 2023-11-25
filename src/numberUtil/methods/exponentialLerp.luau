--[=[
    @within numberUtil
    Exponentially lerps `number` to `goal`, with `alpha` being the multiplier.

    ```lua
    print(numberUtil.exponentialLerp(1, 5, 3)) --> 125
    ```
]=]

function exponentialLerp(number: number, goal: number, alpha: number): number
	return number ^ (1 - alpha) * goal ^ alpha
end

return exponentialLerp