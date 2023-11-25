local SECONDS_IN_MINUTE = 60

--[=[
    @within numberUtil

    Returns a number which is `minutes` converted to seconds.

    ```lua
    print(numberUtil.minutesToSeconds(1)) --> 60
    ```
]=]

local function minutesToSeconds(minutes: number): number
	return minutes * SECONDS_IN_MINUTE
end

return minutesToSeconds
