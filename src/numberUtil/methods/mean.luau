--[=[
    @within numberUtil
    Returns the mean of the set of numbers `...`.

    ```lua
    print(numberUtil.mode(1, 2, 4)) --> 2.3
    ```
]=]

local function mean(...: number): number
	local sum = 0
	local numbers = { ... }

	for _, number in numbers do
		sum += number
	end

	return sum / #numbers
end

return mean
