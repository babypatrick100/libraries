local MINUTES_IN_HOUR = 60

--[=[
    @within numberUtil

    Returns a number which is `minutes` converted to hours.

    ```lua
    print(numberUtil.minutesToHours(60)) --> 1
    ```
]=]

local function minutesToHours(minutes: number): number
	return minutes / MINUTES_IN_HOUR
end

return minutesToHours
