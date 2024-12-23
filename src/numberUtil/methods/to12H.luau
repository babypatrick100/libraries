--[=[
    @within numberUtil
    
    Returns the given hour formatted to the 12 hour clock.

    ```lua
    print(numberUtil.to12H(24)) --> 12
    print(numberUtil.to12H(17)) --> 5
    ```
]=]

local function to12H(hour: number)
	hour = hour % 24
	return (hour - 1) % 12 + 1
end

return to12H
