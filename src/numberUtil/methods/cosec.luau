--[=[
    @within numberUtil
    
    Returns the reciprocal of `math.sign(number)`.

    ```lua
    print(numberUtil.cosec(1)) --> 1.1883951057781212
    ```
]=]

local function cosec(number: number): number
	return 1 / math.sin(number)
end

return cosec
