local factorial = require(script.Parent.factorial)

--[=[
    @within numberUtil
    
    Returns the number of ways picking `k` unordered outcomes from `number` possibilities, without repetition.

    :::note
    If the value of `k` is greater than `number`, then the method will return `0`.
    :::

    ```lua
    print(numberUtil.comb(2, 1)) --> 2
    ```
]=]

local function comb(number: number, k: number): number
	if k > number then
		return 0
	end

	return factorial(number) / (factorial(k) * factorial(number - k))
end

return comb
