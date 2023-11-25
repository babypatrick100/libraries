--[=[
    @within numberUtil
    
    Returns the factorial of `number`.

    ```lua
    print(numberUtil.factorial(3)) --> 6
    ```
]=]

local function factorial(number: number): number
	if number == 0 then
		return 1
	end

	return number * factorial(number - 1)
end

return factorial
