--[=[
    @within numberUtil
    
    Returns a string which is just `number` formatted to the MS (Minutes, Seconds) format.

    ```lua
    print(numberUtil.toMS(21600)) --> 10:00
    ```
]=]

local function toMS(number: number): string
	return string.format("%02i:%02i", number / 60 % 60, number % 60)
end

return toMS
