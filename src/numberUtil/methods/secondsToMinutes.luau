local SECONDS_IN_MINUTE = 60

--[=[
    @within numberUtil

    Returns a number which is `seconds` converted to minutes.

    ```lua
    print(numberUtil.secondsToMinutes(60)) --> 1
    ```
]=]

local function secondsToMinutes(seconds: number): number
	return seconds / SECONDS_IN_MINUTE
end

return secondsToMinutes
