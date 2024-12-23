--[=[
    @within numberUtil
    
    Returns a string which is just `number` formatted to the HMS (Hour, Minutes, Seconds) format.

    ```lua
    print(numberUtil.hms(21660)) --> 6, 1, 0 
    ```
]=]

local function hms(number: number): (number, number, number)
	return number / 60 ^ 2, number / 60 % 60, number % 60
end

return hms
