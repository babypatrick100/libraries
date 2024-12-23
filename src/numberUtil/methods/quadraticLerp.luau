--[=[
    @within numberUtil
    
    Quadraticly interpolates `number` to `goal`, with `alpha` being the multiplier.

    ```lua
    print(numberUtil.quadraticLerp(2, 5, 0.7)) --> 4.1
    ```
]=]

local function quadraticLerp(number: number, goal: number, alpha: number): number
	return (number - goal) * alpha * (alpha - 2) + number
end

return quadraticLerp
