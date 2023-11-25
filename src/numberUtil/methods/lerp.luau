--[=[
    @within numberUtil
    
    Interpolates `number` to `goal`, with `alpha` being the multiplier.

    ```lua
    print(numberUtil.lerp(2, 5, 0.7)) --> 4.1
    ```
]=]

local function lerp(number: number, goal: number, alpha: number): number
	return number + (goal - number) * alpha
end

return lerp
