--[=[
    @within numberUtil
    
    Returns a read only array of all factors of `number`.

    ```lua
    print(numberUtil.factors(2)) --> {1, 2}
    ```
]=]

local function factors(number: number): { number }
	local numberFactors = {}

	for index = 1, number do
		if number % index == 0 then
			table.insert(numberFactors, index)
		end
	end

	if number == 0 then
		table.insert(numberFactors, 0)
	end

	return table.freeze(numberFactors)
end

return factors
