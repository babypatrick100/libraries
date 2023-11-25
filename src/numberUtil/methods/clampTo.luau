--[=[
    @within numberUtil
    
    Clamps `number` to `clamp`, if `number` is greater than `max` or lower than `min`.

    ```lua
    print(numberUtil.clampTo(1, 2, 5, 150)) --> 150
    ```
]=]

local function clampTo(number: number, min: number, max: number, clamp: number): number
	if number > max or number < min then
		return clamp
	end

	return number
end

return clampTo
