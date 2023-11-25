--[=[
    @within numberUtil
    
    Returns a string which is just `number` formatted to the HM (Hour, Minutes) format.

    ```lua
    print(numberUtil.toHM(2 * 3600)) --> 02:00
    ```
]=]

local function toHM(number: number): string
	return string.format("%02i:%02i", number / 60 ^ 2, number / 60 % 60)
end

return toHM
