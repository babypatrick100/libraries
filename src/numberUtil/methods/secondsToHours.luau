local SECONDS_IN_HOUR = 3600

--[=[
    @within numberUtil
  
    Returns a number which is `seconds` converted to hours.

    ```lua
    print(numberUtil.secondsToHours(3600)) --> 1
    ```
]=]

local function secondsToHours(seconds: number): number
	return seconds / SECONDS_IN_HOUR
end

return secondsToHours
