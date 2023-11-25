--[=[
    @within numberUtil
    
    Returns a string which is just `number` formatted to the HMS (Hour, Minutes, Seconds) format.

    ```lua
    print(numberUtil.toHMS(21600)) --> 06:00:00
    ```
]=]

local function toHMS(number: number): string
	return string.format("%02i:%02i:%02i", number / 60 ^ 2, number / 60 % 60, number % 60)
end

return toHMS
