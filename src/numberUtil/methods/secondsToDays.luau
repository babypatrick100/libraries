local SECONDS_IN_DAY = 24 * 3600

--[=[
    @within numberUtil

    Returns a number which is `seconds` converted to days.

    ```lua
    print(numberUtil.secondsToDays(86400)) --> 1
    ```
]=]

local function secondsToDays(seconds: number): number
	return seconds / SECONDS_IN_DAY
end

return secondsToDays
