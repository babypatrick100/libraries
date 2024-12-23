--[=[
    @within numberUtil
    
    Returns the average of `...` numbers against `sum`.

    ```lua
    print(numberUtil.average(100, 50, 25)) --> 0.75
    ```
]=]

local function average(sum: number, ...: number): number
	local accumulatedSum = 0

	for _, number in { ... } do
		accumulatedSum += number
	end

	return accumulatedSum / sum
end

return average
