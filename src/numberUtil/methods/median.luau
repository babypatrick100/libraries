--[=[
    @within numberUtil
    Returns the median of the set of numbers `...`.

    ```lua
    print(numberUtil.median(2, 2)) --> 4
    ```
]=]

local function median(...: number): number
	local sum = 0

	for _, number in { ... } do
		sum += number
	end

	return sum / 2
end

return median
