local MINUTES_IN_HOUR = 60

--[=[
    @within numberUtil
    
    Returns a number which is `hours` converted to minutes.

    ```lua
    print(numberUtil.hoursToMinutes(1)) --> 60
    ```
]=]

local function hoursToMinutes(hours: number): number
	return hours * MINUTES_IN_HOUR
end

return hoursToMinutes
