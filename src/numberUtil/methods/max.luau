--[=[
    @within numberUtil
    Returns the maximum value.

    ```lua
    print(numberUtil.max(10,9,8,7,6,5,4,3,2,1)) --> 10
    ```
]=]

local function max(...: number): number
	local numbers = { ... }
	local minNow = numbers[1]

	for _, number in numbers do
		if number > minNow then
			minNow = number
		end
	end

	return minNow
end

return max
