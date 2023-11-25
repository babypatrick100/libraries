--[=[
    @within numberUtil

    Returns a boolean indicating if `number` is NaN (Not A Number). 

    ```lua
    print(numberUtil.nan(0 / 0)) --> true
    ```
]=]

local function nan(number: number): boolean
	if typeof(number) ~= "number" then
		return false
	end

	return number ~= number
end

return nan
