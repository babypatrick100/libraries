--[=[
    @within numberUtil
    
    Returns an array of all factors of `number`.

    ```lua
    print(numberUtil.factors(2)) --> {1, 2}
    ```
]=]

local function factors(number: number): { number }
	local factors = {}

	for index = 1, number do
		if number % index == 0 then
			table.insert(factors, index)
		end
	end

	if number == 0 then
		table.insert(factors, 0)
	end

	return table.freeze(factors)
end

return factors
