local MID_NIGHT_24_HOUR = 0
local NOON_HOUR = 12

--[=[
    @within numberUtil
    
    Returns the given hour formatted to the 12 hour clock.

    ```lua
    print(numberUtil.to24H(12, "am")) --> 0
    print(numberUtil.to24H(5, "pm")) --> 17
    print(numberUtil.to24H(12, "pm")) --> 12
    print(numberUtil.to24H(11, "pm")) --> 23
    print(numberUtil.to24H(11, "am")) --> 11
    ```
]=]

local function to24H(hour: number, preset: "am" | "pm"): number
	if preset == "am" then
		if hour == NOON_HOUR then
			return MID_NIGHT_24_HOUR
		end

		return hour
	else
		if hour == NOON_HOUR then
			return hour
		end

		return hour + NOON_HOUR
	end
end

return to24H
